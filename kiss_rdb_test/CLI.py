"""DISCUSSION :[#817]: :#here2:

  - this identifier marks a spot in the support library where is described
    the component architecture from which IO facades (test spies) can be made.
  - here we do a lot of gross bandaid code to accommodate the fact that Click
    is not made testing friendly #[#867.L]
  - here we do our own highly experimental construction of a write-only IO
    listener as proposed in the aforementioned support file.
  - here we have an interface for turning on the debugging form of this
  - any/all of the above will be abstracted when appropriate

"""


from ._common_state import (
        fixture_directories_path,
        )
from script_lib.test_support import expect_STDs as es
from modality_agnostic.memoization import memoize


class CLI_Test_Case_Methods:

    # -- expecters

    def expect_common_entity_screen(self):
        # (see #HERE3 in the first CLI test file)

        qualified_lines_itr = self.end_state().lines

        which, stderr_line = next(qualified_lines_itr)

        self.assertEqual(which, 'serr')

        stdout_lines = []

        for (which, stdout_line) in qualified_lines_itr:
            self.assertEqual(which, 'sout')
            stdout_lines.append(stdout_line)

        return _CommonEntityScreen(stderr_line, tuple(stdout_lines))

    def expect_exit_code_for_bad_request(self):
        self.expect_exit_code(400)

    def expect_exit_code_is_the_success_exit_code(self):
        self.assertEqual(self.end_state().exit_code, _success_exit_code)

    def expect_exit_code(self, which):
        self.assertEqual(self.end_state().exception.exit_code, which)

    # -- end state builder

    def build_end_state(self, which_IO, which_e):
        if 'stdout' == which_IO:
            yes_stdout = True
            yes_stderr = False
        elif 'stderr' == which_IO:
            yes_stdout = False
            yes_stderr = True
        elif 'stdout and stderr':
            yes_stdout = True
            yes_stderr = True

        return self.MY_BIG_FLEX(
                allow_stdout_lines=yes_stdout,
                allow_stderr_lines=yes_stderr,
                exception_category=which_e,
                )

    def build_end_state_FOR_DEBUGGING(self, exe_cat='anything experiment'):

        o = self.MY_BIG_FLEX(
                allow_stdout_lines=True,
                allow_stderr_lines=True,
                exception_category=exe_cat,
                )

        if hasattr(o, 'exception'):
            e = o.exception
            print(f'WAS EXCEPTION: {type(e)} {str(e)}')

        if hasattr(o, 'filesystem_recordings'):
            a = o.filesystem_recordings
            if a is not None:
                print(f'HAD NUM RECORDINGS: {len(a)}')

        for line in o.lines:
            cover_me('hi')
        cover_me('hey')

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
            given_args=self.given_args(),
            allow_stdout_lines=allow_stdout_lines,
            allow_stderr_lines=allow_stderr_lines,
            exception_category=exception_category,
            injections_dictionary=injections_dict,
            might_debug=self.might_debug,
            do_debug_f=lambda: self.do_debug,
            debug_IO_f=lambda: _sys().stderr,
            )


# == BEGIN stdout capture and support #here2

def BIG_FLEX(
        given_args,
        allow_stdout_lines,
        allow_stderr_lines,
        exception_category,
        injections_dictionary,
        might_debug,
        do_debug_f,
        debug_IO_f,
        ):

    mixed_writes = []
    is_complicated = False

    if allow_stdout_lines:
        if allow_stderr_lines:
            is_complicated = True

            def receive_sout_write(s):
                mixed_writes.append(('sout', s))

            def receive_serr_write(s):
                mixed_writes.append(('serr', s))
            out_WR = _write_receiver_via_function(receive_sout_write)
            err_WR = _write_receiver_via_function(receive_serr_write)
        else:
            def receive_sout_write(s):
                mixed_writes.append(s)
            out_WR = _write_receiver_via_function(receive_sout_write)
            err_WR = _no_WR
    else:
        def receive_serr_write(s):
            mixed_writes.append(s)
        out_WR = _no_WR
        err_WR = _write_receiver_via_function(receive_serr_write)

    if might_debug:
        _odwr = es.DebuggingWriteReceiver('sout', do_debug_f, debug_IO_f)
        _edwr = es.DebuggingWriteReceiver('serr', do_debug_f, debug_IO_f)
        out_WR = es.MuxingWriteReceiver((_odwr, out_WR))
        err_WR = es.MuxingWriteReceiver((_edwr, err_WR))

    def invoke_CLI():
        return _invoke_CLI(given_args, injections_dictionary)

    def clean_up_writes():
        if is_complicated:
            return __clean_up_writes_complicatedly(mixed_writes)
        return __lines_via_writes(mixed_writes)

    if exception_category is None:

        with OPEN_HORRIBLE_VENDOR_HACK(out_WR, err_WR):
            fs_finish, exit_code = invoke_CLI()

        if fs_finish is None:
            fsr = None
        else:
            fsr = fs_finish()

        _lines = clean_up_writes()
        return _BigFlexEndStateWithLala(
                filesystem_recordings=fsr,
                lines=_lines,
                exit_code=exit_code)

    def these(s):
        if 'click exception' == s:
            yield ce('ClickException')
        elif 'system exit' == s:
            yield SystemExit
        elif 'usage error' == s:
            yield ce('UsageError')
        elif 'anything experiment' == s:
            yield ce('ClickException')
            yield ce('UsageError')
            yield SystemExit
        else:
            cover_me(f'uncoded for exception category: {s}')

    def ce(s):  # ce="click exception"
        import click.exceptions as _
        return getattr(_, s)

    _exception_class_expression = tuple(these(exception_category))

    did_throw = False
    try:
        with OPEN_HORRIBLE_VENDOR_HACK(out_WR, err_WR):
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


def _write_receiver_via_function(receive_write):
    return es.ProxyingWriteReceiver(receive_write)


def _expecting_no_emissions(x):
    assert(False)


_no_WR = _write_receiver_via_function(_expecting_no_emissions)


def _invoke_CLI(given_args, injections_dictionary):

    from kiss_rdb.magnetics_.collection_via_directory import (
            INJECTIONS as INJECTIONS)

    from kiss_rdb.cli import cli

    _NASTY_HACK_once()

    if injections_dictionary is None:
        injections_obj = None
        filesystem_finish = None
    else:
        random_number, filesystem = __flatten_these(**injections_dictionary)
        _random_number_generator = __rng_via(random_number)
        filesystemer, filesystem_finish = __these_two_via_filesystem(filesystem)  # noqa: E501

        injections_obj = INJECTIONS(
                random_number_generator=_random_number_generator,
                filesystemer=filesystemer)

    _exit_code = cli.main(
                args=given_args,
                prog_name='ohai-mami',
                standalone_mode=False,  # see.
                complete_var='___hope_this_env_var_is_never_set',
                obj=injections_obj,
            )

    return filesystem_finish, _exit_code


@memoize
def _NASTY_HACK_once():
    # OCD for tests (this is a common OCD we run into when testing CLI):
    # don't ever parse the same schema file more than once
    # (at writing it saves from 4 extranous constructons)

    from kiss_rdb.magnetics_ import schema_via_file_lines as mod

    real_function = mod.SCHEMA_VIA_COLLECTION_PATH

    cache = {}

    def use_function(path, listener):

        if path in cache:
            return cache[path]
        res = real_function(path, listener)
        if res is not None:
            cache[path] = res
        return res

    mod.SCHEMA_VIA_COLLECTION_PATH = use_function


def __rng_via(random_number):
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


def OPEN_HORRIBLE_VENDOR_HACK(sout_write_receiver, serr_write_receiver):
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

    sout_iof = _write_only_facade(sout_write_receiver)
    serr_iof = _write_only_facade(serr_write_receiver)

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
    from script_lib.test_support.expect_treelike_screen import (
            tree_via_line_stream as _)
    return _(lines)


def common_args_head():
    return '--collections-hub', fixture_directories_path()


def build_filesystem_expecting_num_file_rewrites(expected_num):
    from kiss_rdb_test import filesystem_spy as fs_lib
    return fs_lib.build_filesystem_expecting_num_file_rewrites(expected_num)


# == private models

class _CommonEntityScreen:

    def __init__(self, aa, bb):
        self.stderr_line = aa
        self.stdout_lines = bb


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


def _write_only_facade(receiver):
    from modality_agnostic import io as io_lib
    return io_lib.write_only_IO_proxy(
            write=lambda s: receiver.receive_write(s),
            flush=lambda: receiver.receive_flush(),
            )


def _lines_via_big_string_as_is(big_string):
    import kiss_rdb.magnetics_.CUD_attributes_via_request as lib
    return lib.lines_via_big_string_(big_string)


def _sys():
    import sys as _
    return _


def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')


_success_exit_code = 0


# == END support for stdout capture

# #abstracted.
