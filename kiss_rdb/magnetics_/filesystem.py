"""
the main thing the "filesystem" offers is what we're calling
"semi-atomic filesystem transactions" ..



## transactions and rewrites

- every act of persisting the modified state of a collection is here
  conceived of as an *atomic* *set* of one or more file-operations where
  each operation is a CREATE, "rewrite", or DELETE of that file (path)
  (and each path is unique in any given set). whew!



## the user-supplied file rewrite function

- a file rewrite is realized by passing the filesystem a function.
- the function will receive some pertinent arguments and
- *must* result in an iterator that yields each line of the rewritten
  file's target end state (more below).
- i.e the function *cannot* indicate failure by (e.g) resulting in None/False.
- we expect that most such functions will be implemented as iterators that
  use the `yield` construct to yield out each next line of the new file,
  but this is user's choice.
- at any point during its execution (or at multiple points), the function
  may signal failure, which is to say that the function is saying it cannot
  complete producing the list of lines for the modified file.
- the only way the function may signal such a failure is by emitting one
  or more `error`s into *the provided* listener.
- if the iterator yields no lines (and no errors are emitted),
  this amounts to a request to truncate the file to zero bytes.
- later we'll deal with deleting (or not) and creating files



## transactions in theory

- again, an act of persisting state can involve more than one file.
- it's possible that while effecting an act of persistence, the user may
  finish procuring new lines for one file but then, midway through preparing
  the new lines for another file, need to fail.
- for a hypothetical-but-not-contrived example, imagine implementing CREATE:
  there's a function for making the new lines of the entity. this function
  takes an IID and zero or more name-value pairs. the new IID must be
  provisioned, and doing so modifies the index (file). but when calling the
  lines function, there may be a validation failure from the name-value pairs.
  in such a case we would need to roll-back the modification of the index file.
- one main intention of transactions is that, for those operations that
  involve multiple files, the user can structure their logic (and code!)
  so they don't have to worry about rolling back changes to such files in
  the case of failing part-way through.



## transactions in implemention

- as a platform-idiom-appropriate interface for transactions, the `with`
  construct ("context managers") feels like a no-brainer. however, this
  language construct is *not* an expression; which is to say it does not have
  a return value. as such, in order for us to be able to get a return value
  back from our transaction, we use our awkward `finish` function. :#here2
- the filesystem returns the result of such an attempted transaction always
  as either True or None (not True/False); indicating whether the transaction
  was seen through to its completion. :[#867.R]
- failure is reflected by None not False so that we can employ the more
  horizontally-sparse `return` rather than the noisier `return _not_OK` (e.g).
  however this specification is EXPERIMENTAL.
- despite all this, transactions are not totally fail-safe (see #here3).



## file-locking

- see #here4
"""


class Filesystem_EXPERIMENTAL:  # #testpoint

    def __init__(self, commit_file_rewrite):
        self._commit_file_rewrite = commit_file_rewrite

    def FILE_REWRITE_TRANSACTION(self, listener):
        return _FILE_REWRITE_TRANSACTION(self._commit_file_rewrite, listener)

    def CREATE_AND_OPEN_LOCKED_FILE(self, path):
        return _LockedFile(path, 'a+')  # create file (since not exist)..

    def open_locked_file_in_wrapper(self, path, wrp):
        return _LockedFile(path, 'r+', wrp)  # not create if doesn't exist

    def open_locked_file(self, path):
        return _LockedFile(path, 'r+')  # not create if doesn't exist


class _FILE_REWRITE_TRANSACTION:

    def __init__(self, commit_file_rewrite, listener):
        from kiss_rdb.storage_adapters_.toml import (
                identifiers_via_file_lines as lib)
        self._monitor = lib.ErrorMonitor_(listener)
        self._commit_file_rewrite = commit_file_rewrite
        self._units_of_work = []
        self._exit_me = []
        self._OK = True
        self._enter_mutex = None

    def __enter__(self):
        del(self._enter_mutex)
        tc = _FileRewriteTransactionController(
                receive_rewrite_file=self._receive_rewrite_file,
                receive_finish=self._receive_finish,
                register_cleanup_function=self._register_cleanup_function,
                receive_ask_OK=lambda: self._OK,
                )
        return tc

    def _register_cleanup_function(self, f):
        def use_f(_1, _2, _3):
            f(self)  # pass it the filesystem (maybe the rest if needed)
        self._exit_me.append(use_f)

    def _receive_rewrite_file(self, filehandle, lines_function):
        """flush the new lines of the file to a temporary file"""

        if not self._OK:
            return

        import tempfile

        tmp_cm = tempfile.NamedTemporaryFile(mode='w+')
        """we keep flip-flopping between two ways:

        one way is you construct the above as default which is in 'w+b'
        (binary mode) and it behaves consistently on all platforms. the cost
        of this way the cost to this is that we convert each string (line) we
        we write to the file back to binary #here1.

        the other way is you construct the above explicitly *not* in binary
        (so, 'w+'). the cost of this is..

        .#[#867.P]
        """

        self._exit_me.append(tmp_cm.__exit__)

        tmp_fh = tmp_cm.__enter__()

        # feed the lines function the original lines (filehandle), and
        # get back from it what the new lines are

        _ = lines_function(filehandle, self._monitor.listener)

        # write the new lines to the

        for line in _:
            # _bytes = bytearray(line, 'utf-8')  # YUCK #here1
            tmp_fh.write(line)

        # if something failed..

        if not self._monitor.ok:
            self._OK = False
            return

        _uow = _UnitOfWork(from_file=tmp_fh, to_file=filehandle)
        self._units_of_work.append(_uow)

    def _receive_finish(self):
        if not self._OK:
            return _not_OK

        a = self._units_of_work
        del(self._units_of_work)

        for uow in a:
            """if one of these uow's fails to commit here, we're beyond the
            point where we can do anything about it so such a case likely
            effects "catastrophic" corruption which is beyond our scope (unless
            you were lucky and the first one threw an exception) :#here3
            """

            from_fh = uow.from_file
            to_fh = uow.to_file

            from_fh.flush()  # (could do this after last write too)

            self._commit_file_rewrite(from_fh, to_fh)
        return _OK

    def __exit__(self, *_3):
        a = self._exit_me
        del(self._exit_me)
        for f in a:
            f(*_3)
        return False  # ignore responses from cx?


class _FileRewriteTransactionController:

    def __init__(
            self, receive_rewrite_file,
            receive_finish, register_cleanup_function,
            receive_ask_OK,
            ):

        self._receive_rewrite_file = receive_rewrite_file
        self._receive_finish = receive_finish
        self._register_cleanup_function = register_cleanup_function
        self._receive_ask_OK = receive_ask_OK

    def REGISTER_CLEANUP_FUNCTION(self, f):
        return self._register_cleanup_function(f)

    def rewrite_file(self, filehandle, lines_function):
        return self._receive_rewrite_file(filehandle, lines_function)

    def finish(self):  # #here2
        return self._receive_finish()

    @property
    def OK(self):
        return self._receive_ask_OK()


class _UnitOfWork:

    def __init__(self, from_file, to_file):
        self.from_file = from_file
        self.to_file = to_file


class _LockedFile:
    """EXPERIMENTAL:

    it's certainly possible that multiple processes try to write to the same
    file at the same time. at best this could lead to data loss. worse, it
    could mean arbitrarily corrupted files or something else unimagined.

    for the time being, our answer to this problem is filesystem file locking.

    depending on the operating system's filesystem, locking will behave to
    varying degrees of strictness in terms of what other processes it actually
    locks out.

    so this won't prevent all imaginable scenarios. a human could, for example,
    "press save" on their text editor just as a non-human process is also
    writing (maybe, depending on the system).

    this seems unlikely that it will endure in its current form all the way
    out to some kind of production (BUT MAYBE!)

    to do something more robust that this would seem out of scope of our whole
    mandate; but we may have to some how dumb it down, and who knows what we
    will do when we [#867.T] "top secret crazy plan"..

    ideally we would like this to be more abstract than it is now; integrated
    in to some rewrite file idiom (BUT LATER!)

    this may be related to the idea of "eventual consistency" etc

    :#here4
    """

    def __init__(self, path, mode, wrapper=None):
        self._path = path
        self._mode = mode
        self._wrapper = wrapper
        import fcntl as _
        self._fcntl = _

    def __enter__(self):
        fcntl = self._fcntl
        path = self._path
        del(self._path)
        mode = self._mode
        del(self._mode)
        self._child = open(path, mode)
        fh = self._child.__enter__()
        self._filehandle = fh
        fcntl.flock(fh, fcntl.LOCK_EX | fcntl.LOCK_NB)

        if self._wrapper is None:
            return fh
        else:
            return self._wrapper(fh)

    def __exit__(self, *_):
        fcntl = self._fcntl
        fcntl.flock(self._filehandle, fcntl.LOCK_UN)
        del(self._filehandle)
        self._child.__exit__(*_)
        del(self._child)
        return False


_not_OK = None  # [#867.R] provision: None (not False) signifies failure
_OK = True


# #born.
