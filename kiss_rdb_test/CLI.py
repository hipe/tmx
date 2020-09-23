"""DISCUSSION :#here2:
  - we use the [#605.1] component architecture to make IO façades
  - here we do a lot of gross bandaid code to accommodate the fact that Click
    is not made testing friendly #[#867.L]
  - here we do our own highly experimental construction of a write-only IO
    listener as proposed in the aforementioned support file.
  - here we have an interface for turning on the debugging form of this
  - any/all of the above will be abstracted when appropriate

"""

from script_lib.test_support import expect_STDs as es


class CLI_Test_Case_Methods:

    # -- expecters

    def expect_common_entity_screen(self):
        # (see #HERE3 in the first CLI test file)

        # partition the lines into stdout vs stderr, counting how many times it

        sout_lines = []
        serr_lines = []
        which_lines = {'sout': sout_lines, 'serr': serr_lines}

        qualified_lines_itr = self.end_state.lines

        which, line = next(qualified_lines_itr)
        curr_lines = which_lines[which]
        curr_lines.append(line)

        order = [which]
        prev_which = which

        for which, line in qualified_lines_itr:
            if prev_which != which:
                if 1 < len(order):
                    raise Exception("screen flipped between sout & serr > 1x")
                order.append(which)
                curr_lines = which_lines[which]
                prev_which = which
            curr_lines.append(line)

        # assert that both were expressed, and stderr came before stdout

        self.assertSequenceEqual(order, ('serr', 'sout'))

        # assert max two stderr lines, hackishly

        if 1 == len(serr_lines):
            serr_lines.append(None)

        first_stderr_line, second_stderr_line = serr_lines

        #

        return _CommonEntityScreen(
                first_stderr_line, second_stderr_line, tuple(sout_lines))

    def expect_exit_code_for_bad_request(self):
        self.expect_exit_code(400)

    def expect_exit_code_is_the_success_exit_code(self):
        self.assertEqual(self.end_state.exit_code, _success_exit_code)

    def expect_exit_code(self, which):
        self.assertEqual(self.end_state.exit_code, which)

    # -- end state builder

    def build_end_state(self, which_IO, which_e):
        if 'stdout' == which_IO:
            yes_stdout = True
            yes_stderr = False
        elif 'stderr' == which_IO:
            yes_stdout = False
            yes_stderr = True
        else:
            assert('stdout_and_stderr' == which_IO)
            yes_stdout = True
            yes_stderr = True

        return self.MY_BIG_FLEX(
                allow_stdout_lines=yes_stdout,
                allow_stderr_lines=yes_stderr,
                exception_category=which_e)

    def build_end_state_FOR_DEBUGGING(self, exe_cat='anything experiment'):

        o = self.MY_BIG_FLEX(
                allow_stdout_lines=True,
                allow_stderr_lines=True,
                exception_category=exe_cat)

        if hasattr(o, 'exception'):
            e = o.exception
            print(f'WAS EXCEPTION: {type(e)} {str(e)}')

        if hasattr(o, 'filesystem_recordings'):
            a = o.filesystem_recordings
            if a is not None:
                print(f'HAD NUM RECORDINGS: {len(a)}')

        for line in o.lines:
            xx('hi')
        xx('hey')

    def MY_BIG_FLEX(
            self,
            allow_stdout_lines,
            allow_stderr_lines,
            exception_category):

        fs = self.filesystem()
        if fs is None:
            injections_dict = None
        else:
            injections_dict = {
                    'filesystem': fs,
                    'random_number': self.random_number(),
                    }

        return BIG_FLEX(
                given_stdin=None,  # not faked here but faked elsewhere
                given_args=self.given_args(),
                allow_stdout_lines=allow_stdout_lines,
                allow_stderr_lines=allow_stderr_lines,
                exception_category=exception_category,
                injections_dictionary=injections_dict,
                might_debug=self.might_debug,
                do_debug_f=lambda: self.do_debug)


# == BEGIN stdout capture and support #here2

def BIG_FLEX(
        given_stdin,
        given_args,
        allow_stdout_lines,
        allow_stderr_lines,
        exception_category,
        injections_dictionary,
        might_debug,
        do_debug_f):

    mixed_writes = []
    is_complicated = False

    if allow_stdout_lines:
        if allow_stderr_lines:
            is_complicated = True

            def receive_sout_write(s):
                mixed_writes.append(('sout', s))

            def receive_serr_write(s):
                mixed_writes.append(('serr', s))
        else:
            def receive_sout_write(s):
                mixed_writes.append(s)

            def receive_serr_write(s):
                assert()
    else:
        def receive_sout_write(s):
            assert()

        def receive_serr_write(s):
            mixed_writes.append(s)

    sout_recvs = [receive_sout_write]
    serr_recvs = [receive_serr_write]

    if might_debug:
        import script_lib.test_support.expect_STDs as lib
        sout_recvs.append(lib.build_write_receiver_for_debugging('DBG SOUT: ', do_debug_f))  # noqa: E501
        serr_recvs.append(lib.build_write_receiver_for_debugging('DBG SERR: ', do_debug_f))  # noqa: E501

    def invoke_CLI():
        return _invoke_CLI(given_stdin, given_args, injections_dictionary)

    def clean_up_writes():
        if is_complicated:
            return __clean_up_writes_complicatedly(mixed_writes)
        return __lines_via_writes(mixed_writes)

    if exception_category is None:

        with OPEN_HORRIBLE_VENDOR_HACK(sout_recvs, serr_recvs):
            fs_finish, exit_code = invoke_CLI()

        fsr = None if fs_finish is None else fs_finish()

        _lines = clean_up_writes()
        return _BigFlexEndStateWithLala(
                filesystem_recordings=fsr,
                lines=_lines,
                exit_code=exit_code)

    def these(s):
        if 'click_exception' == s:
            yield ce('ClickException')
        elif 'system_exit' == s:
            yield SystemExit
        elif 'usage_error' == s:
            yield ce('UsageError')
        elif 'anything_experiment' == s:
            yield ce('ClickException')
            yield ce('UsageError')
            yield SystemExit
        else:
            xx(f'uncoded for exception category: {s}')

    def ce(s):  # ce="click exception"
        import click.exceptions as _
        return getattr(_, s)

    _exception_class_expression = tuple(these(exception_category))

    did_throw = False
    try:
        with OPEN_HORRIBLE_VENDOR_HACK(sout_recvs, serr_recvs):
            invoke_CLI()
    except _exception_class_expression as e_:
        did_throw = True
        e = e_

    if not did_throw:
        raise Exception("this used to throw but it doesn't any more")

    _ = clean_up_writes()
    return _BigFlexEndStateWithException(_, e)


class _BigFlexEndStateWithException:
    def __init__(self, lines, e):
        self.lines = lines
        self.exception = e


class _BigFlexEndStateWithLala:
    def __init__(self, filesystem_recordings, lines, exit_code):
        self.filesystem_recordings = filesystem_recordings
        self.lines = lines
        self.exit_code = exit_code


def _invoke_CLI(given_stdin, given_args, injections_dictionary):
    from kiss_rdb.cli import cli

    """:[#867.U] "why we inject": There are two aspects of testing that would
    be difficult or impossible without exposing these points of dependency
    injection: 1) The psuedo-randomness behind identifier allocation 2)
    interactions with the filesystem.

    Corraling our interactions with the filesystem into a unified (and small!)
    abstraction layer will also assist us in moving to containerized hosting..

    Not every operation needs every facility, so if you know before you build
    the collecton which operation(s) you need from it, you may avoid some
    unnecessary coupling and overhead by not injecting those facilities.
    (Although this is not as relevant from #history-A.1 when we mock read-only)
    """

    # stdin is kept out of the injections dictionary because of how we
    # might want it to be exposed way upstream to override in vendor like
    # we do for sout & serr. (we don't currently for 2 reasons)

    rng, opn, here = None, None, __file__
    filesystem_finish = None
    if injections_dictionary is not None:
        random_number, FS = __flatten_these(**injections_dictionary)
        rng = _rng_via(random_number)
        use_FSer, filesystem_finish = __these_two_via_filesystem(FS)
        opn = _hacked_open_function(use_FSer) if use_FSer else None

    _exit_code = cli.main(
                args=given_args,
                prog_name='ohai-mami',
                standalone_mode=False,  # see.
                complete_var='___hope_this_env_var_is_never_set',
                obj={'stdin': given_stdin, 'rng': rng, 'opn': opn, 'hi': here})

    return filesystem_finish, _exit_code


def _hacked_open_function(use_FSer):
    def opn(path):
        return fs.open_file_for_reading(path)
    fs = use_FSer()
    opn.THE_WORST_HACK_EVER_FILESYSTEM_ = fs
    return opn


def _rng_via(random_number):
    if random_number is None:
        return

    def random_number_generator(pool_size):
        return random_number
    return random_number_generator


def __these_two_via_filesystem(filesystem):
    if filesystem is None:
        return (None, None)

    def filesystem_finish():
        return filesystem.FINISH_AS_HACKY_SPY()

    def filesystemer():
        return filesystem

    return filesystemer, filesystem_finish


def __flatten_these(random_number, filesystem):
    return random_number, filesystem


def OPEN_HORRIBLE_VENDOR_HACK(sout_recvs, serr_recvs):
    """.#open [#867.L] this so bad:

    click is not written to be test-friendly in any injection-sense, so
    we have to awfully, hackishly rewrite these functions to be other
    functions, and then (for each invocation under test) pop things back
    into place and hope our execution context works alright and hope that
    this doesn't break actual CLI that's being used during the running of
    tests. so bad.

    also:
      - don't let the "default" in the name fool you below.
    """

    from click import utils as EEK_click_utils

    sout_iof = es.spy_on_write_via_receivers(sout_recvs)
    serr_iof = es.spy_on_write_via_receivers(serr_recvs)

    dtso = getattr(EEK_click_utils, '_default_text_stdout')
    dtse = getattr(EEK_click_utils, '_default_text_stderr')

    setattr(EEK_click_utils, '_default_text_stdout', lambda: sout_iof)
    setattr(EEK_click_utils, '_default_text_stderr', lambda: serr_iof)

    def f():
        setattr(EEK_click_utils, '_default_text_stdout', dtso)
        setattr(EEK_click_utils, '_default_text_stderr', dtse)

    return _Ensure(f)


class _Ensure:

    def __init__(self, f):
        self._function = f

    def __enter__(self):
        # we could have put set-up code here, but why?
        pass

    def __exit__(self, _, _2, _3):
        f = self._function
        del self._function
        f()


# == PUBLICOS

def tree_via_lines(lines):
    from script_lib.test_support.expect_treelike_screen import tree_via_lines
    return tree_via_lines(lines)


def build_filesystem_expecting_num_file_rewrites(expected_num):
    from kiss_rdb_test import filesystem_spy as fs_lib
    return fs_lib.build_filesystem_expecting_num_file_rewrites(expected_num)


# == private models

class _CommonEntityScreen:

    def __init__(self, aa, bb, cc):
        self.stderr_lines_one_and_two = (aa, bb)
        self.stdout_lines = cc


# ==

def __clean_up_writes_complicatedly(writes):
    if not len(writes):
        return ()

    for which, big_s in writes:
        for line in _lines_via_big_string_as_is(big_s):
            yield which, line


def __lines_via_writes(writes):
    """DISCUSSION

    we tried this with the equivalent of `re.split('(?<=\n)', write)` but
    that adds a trailing *empty* string
    """

    for write in writes:
        for line in _lines_via_big_string_as_is(write):
            yield line


def _lines_via_big_string_as_is(big_string):
    import kiss_rdb.storage_adapters_.toml.CUD_attributes_via_request as lib
    return lib.lines_via_big_string_(big_string)


def xx(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')


_success_exit_code = 0


# == END support for stdout capture

# #history-A.1
# #abstracted.
