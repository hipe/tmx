"""helper for testing CLI in a generic, magnetic-agnostic way
"""


class CLI_Canon_Case_Methods:

    # -- assertion methods

    def invokes(self):
        self.assertIsNotNone(self.end_state)

    def invocation_fails(self):
        self.assertFalse(self.end_state.OK)

    def invocation_results_in_this_exitstatus(self, es):
        self.assertEqual(self.end_state.exitstatus, es)

    @property
    def first_line(self):
        return self.end_state.first_line

    @property
    def second_line(self):
        return self.end_state.second_line

    # -- these

    def invoke_expecting(self, line_count, which):

        def f(sout, serr):
            return _invoke_CLI(sout, serr, self)

        return _invocation_via(f, line_count, which, self)

    # --


# --

def _invoke_CLI(stdout, stderr, tc):

    _argv = (tc.long_program_name, *tc.given_argv_tail())
    _children = tc.given_children_CLI_functions()

    from script_lib.cheap_arg_parse_branch import cheap_arg_parse_branch
    return cheap_arg_parse_branch(
            stdin=None, stdout=stdout, stderr=stderr, argv=_argv,
            children_CLI_functions=_children)


def _invocation_via(run, num_lines, which, tc):

    s_a, f_a = __recording_and_recorders(num_lines)

    from script_lib.test_support import expect_STDs
    _expectation = expect_STDs.expect_lines(f_a, which)
    perf = _expectation.to_performance_under(tc)

    _sout, _serr = __stdout_and_stderr(perf, tc)

    es = run(_sout, _serr)
    assert(isinstance(es, int))

    perf.finish()
    return _EndState(es, s_a)


def __stdout_and_stderr(perf, tc):
    if not tc.do_debug:
        return perf.stdout, perf.stderr

    _sout = _debugging_IO(perf.stdout, '%sohai stdout: %s')
    _serr = _debugging_IO(perf.stderr, '%sohai stderr: %s')
    return _sout, _serr


def _debugging_IO(upstream_IO, fmt):
    def write(s):
        sys.stderr.write(fmt % (_eol, s))
        upstream_IO.write(s)
    import sys
    from modality_agnostic.io import write_only_IO_proxy
    return write_only_IO_proxy(write)


def __recording_and_recorders(num_lines):
    def f(line):
        s_a.append(line)  # hi.
    s_a = []
    return s_a, tuple(f for _ in range(0, num_lines))


class _EndState:

    def __init__(self, es, s_a):
        self._lines = s_a
        self.exitstatus = es

    @property
    def second_line(self):
        return self._line(1)

    @property
    def first_line(self):
        return self._line(0)

    def _line(self, offset):
        return self._lines[offset]

    @property
    def number_of_lines(self):
        return len(self._lines)

    @property
    def OK(self):  # retro-fitting this idiom for posterity (#history-A.1)
        assert(isinstance(self.exitstatus, int))
        return 0 == self.exitstatus


def THESE_TWO_CHILDREN_CLI_METHODS():

    def _the_foo_bar_CLI(stdin, stdout, stderr, argv):
        long_prog_name, *argv_tail = argv
        assert(' ' in long_prog_name)
        head, tail = long_prog_name.split(' ', 1)
        _basename = head[(head.rindex('/')+1):]
        _use_pn = f'{_basename} {tail}'
        stdout.write(f"hello from '{_use_pn}'. args: {repr(argv_tail)}\n")
        return 4321

    yield 'foo-bar', lambda: _the_foo_bar_CLI

    def _the_biff_baz_CLI(*a):
        xx()

    yield 'biff-baz', lambda: _the_biff_baz_CLI


def xx():
    raise Exception('write me')


_eol = '\n'

# #history-A.1
# #born.
