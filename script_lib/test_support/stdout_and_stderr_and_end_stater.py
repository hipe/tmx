"""the idea of 'end states' is one with a prominent history in our testing

here (and elsewhere) but one that has never gotten much formal treatment or
been known by this name.

as its own module, this emerged out of necessity because the support code
for making these got too overblown not to live in its own file.

the pattern is always something like this:

    sout, serr, end_stater = this_lib.for_foo_fah()
    _cli = your_whatever_CLI(some_stdin, sout, serr, some_argv)
    _exitstatus = _cli.execute()
    return end_stater(_exitstatus)

(stdin xxx)

(note about the module name: the names of the functions were getting too
long to fit on one line, having every function named xxxxx)
"""


def for_DEBUGGING():
    """this simply shows you what is being written to your STDOUT and STDERR

    by your client by echoing it back to you (with some annotation so you can
    tell easily which is which). (note that perhaps counter-intuitively, we
    write the annotated versions of both STDOUT and STDERR to the real STDERR,
    so, for example, you can divide the annotation out from test runner output
    that (hopefully) is written to real STDOUT.)

    because we echo it but we don't store it, you won't be able to do content
    validation on the resulting end state, so always this is used during
    developmemnt and not committed (hence the all caps) and typically this is
    used under a test that just tests the exitstatus of the invocation.
    """

    def sout_f(s):
        return same('O', s)

    def serr_f(s):
        return same('E', s)

    def same(which, s):
        s2 = s.strip()
        _thing = ' (no newline)' if s2 is s else ''
        return serr.write('({}: {}{})\n'.format(which, s2, _thing))

    def finish(exitstatus):
        _ = 'remember - debugging mode on (exitstatus: {}).\n'.format(
                exitstatus)
        serr.write(_)
        return _ExitstatusOnly(exitstatus)

    from sys import stderr as serr

    _sout_proxy = _write_only_IO_proxy(sout_f)
    _serr_proxy = _write_only_IO_proxy(serr_f)

    return _sout_proxy, _serr_proxy, finish


def three_for_line_runner():
    """this recorder does no real-time assertion.

    vaguely similar to [#603] the help screen parser, this partitions
    contiguous lines into groupings based on which channel the line is
    on. the `line_runs` of the resulting end state will either be the
    empty tuple, or have `which` of the form

        stderr [stdout [stderr [stdout [stderr [..]]]]]
    or:
        stdout [stderr [stdout [stderr [stdout [..]]]]]

    each line run will also have a `lines`.
    """

    class _StatefulFellow:

        def __init__(self):
            self._current_state = 'closed'
            self._current_lines = None
            self._line_runs = []

        def receive_stdout_write(self, s):
            return self._receive_write('stdout', s)

        def receive_stderr_write(self, s):
            return self._receive_write('stderr', s)

        def _receive_write(self, which, s):
            self._maybe_close_current_line_run(which)
            self._current_lines.append(s)
            return len(s)  # you have to be like write, e.g [#607.B]

        def finish(self, actual_exitstatus):
            self._maybe_close_current_line_run('closed')
            del(self._current_lines)  # sanity
            return _LineRuns(actual_exitstatus, tuple(self._line_runs))

        def _maybe_close_current_line_run(self, which):
            if self._current_state != which:
                if self._current_lines is None:
                    # the first state change you have is from the closed state
                    self._current_lines = []
                else:
                    self.__close_current_line_run(which)
                self._current_state = which

        def __close_current_line_run(self, which):
            a = self._current_lines
            self._line_runs.append(LineRun(self._current_state, tuple(a)))
            a.clear()

    class LineRun:
        def __init__(self, which, lines):
            self.which = which
            self.lines = lines

    stateful_fellow = _StatefulFellow()

    _sout_proxy = _write_only_IO_proxy(stateful_fellow.receive_stdout_write)
    _serr_proxy = _write_only_IO_proxy(stateful_fellow.receive_stderr_write)

    return _sout_proxy, _serr_proxy, stateful_fellow.finish


def for_expect_on_which_this_many_under(which, num, test_context):
    """this one leverages the fancy real-time mocking facilities of our

    sibling module. expects a particular number of writes to happen on the
    indicated IO ('stdout' or 'stderr'). if the actual number of writes
    exceeds or falls short of that target number or if the other IO is
    written to, a focused failure is raised (at the time (where sensiscal)
    it occurs).
    """

    actual_lines, itr = __recording_list_and_expectation_functions_via_count(num)  # noqa: E501
    from . import expect_STDs as lib
    if 'stderr' == which:
        exp = lib.expect_stderr_lines(itr)
        offset = 1
    elif 'stdout' == which:
        exp = lib.expect_stdout_lines(itr)
        offset = 0

    def finish(actual_exitstatus):
        perfo_finish()
        two = [None for _ in range(0, 2)]  # must be mutable
        two[offset] = tuple(actual_lines)
        return _EndState(actual_exitstatus, *two)

    perfo = exp.to_performance_under(test_context)
    perfo_finish = perfo.finish

    return perfo.stdout, perfo.stderr, finish


def for_recording_all_stderr_lines():
    """will barf crudely if anything is written to STDOUT. every line that

    is written to STDERR will be available in the end state under
    `stderr_lines`.
    """

    def finish(actual_exitstatus):
        return _EndState(actual_exitstatus, None, tuple(lines))
    lines = []
    _serr = _write_only_IO_proxy(lines.append)
    return None, _serr, finish


def for_recording_all_stdout_lines():
    """will barf crudely if anything is written to STDERR. every line that

    is written to STDOUT will be available in the end state under
    `stdout_lines`.
    """

    def finish(actual_exitstatus):
        return _EndState(actual_exitstatus, tuple(lines), None)
    lines = []
    _sout = _write_only_IO_proxy(lines.append)
    return _sout, None, finish


def __recording_list_and_expectation_functions_via_count(num):

    actual_lines = []

    def f(line):
        actual_lines.append(line)

    _line_expectations = (f for _ in range(0, num))

    return actual_lines, _line_expectations


class _LineRuns:

    def __init__(self, d, line_runs):
        self.exitstatus = d
        self.line_runs = line_runs

    def first_line_run(self, which):
        return self._first(False, which)

    def last_line_run(self, which):
        return self._first(True, which)

    def _first(self, do_reverse, which):
        a = self.line_runs
        r = range(0, len(a))
        if do_reverse:
            r = reversed(r)
        did_find = False
        for offset in r:
            if which == a[offset].which:
                did_find = True
                found_offset = offset
                break
        if did_find:
            return a[found_offset]
        else:
            raise Exception(f'no {which} output ({len(a)} line_runs of output)')


class _EndState:

    def __init__(self, d, sout_line_tup, serr_line_tup):
        self.exitstatus = d
        self.stdout_lines = sout_line_tup
        self.stderr_lines = serr_line_tup


class _ExitstatusOnly:
    def __init__(self, d):
        self.exitstatus = d


class STDERR_CRAZYTOWN:

    def __init__(self, *lines):
        self._lines = lines

    def isatty(self):
        return False

    def __iter__(self):
        return iter(self._lines)


class MINIMAL_NON_INTERACTIVE_IO:  # as namespace only

    def isatty():
        return False


class MINIMAL_INTERACTIVE_IO:  # as namespace only

    def isatty():
        return True


def _write_only_IO_proxy(f):
    from modality_agnostic import io as io_lib
    return io_lib.write_only_IO_proxy(f)

# #abstracted
