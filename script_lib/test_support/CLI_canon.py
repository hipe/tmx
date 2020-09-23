"""helper for testing CLI in a generic, magnetic-agnostic way
"""


def _delegate_to_end_state(orig_f):  # #decorator
    def use_f(self):
        return getattr(self.end_state, attr)
    attr = orig_f.__name__
    return property(use_f)


class CLI_Canon_Assertion_Methods:

    # -- assertion methods

    def invokes(self):
        self.assertIsNotNone(self.end_state)

    def invocation_fails(self):
        self.assertFalse(self.end_state.OK)

    def invocation_results_in_this_exitstatus(self, es):
        self.assertEqual(self.end_state.exitstatus, es)

    @_delegate_to_end_state
    def first_line():
        pass

    @_delegate_to_end_state
    def second_line():
        pass

    @_delegate_to_end_state
    def last_line():
        pass

    # -- these

    def build_end_state_using_line_expectations(self):
        return _build_end_state_using_line_expectations(self)


def _build_end_state_using_line_expectations(tc):  # tech demo

    from . import expect_STDs as lib
    rcv1 = lib.build_write_receiver_for_debugging('DBG: ', lambda: tc.do_debug)
    rcv2, lines = lib.build_write_receiver_for_recording_and_lines()

    def recv(s):
        rcv1(s)
        rcv2(s)

    def wild_hack_of_tup(tup):
        if isinstance(tup, str):
            tup = (tup,)
        assert(all((k in _keywords) for k in tup))
        return (*tup, recv)

    exps = tuple(wild_hack_of_tup(tup) for tup in tc.expected_lines())
    sout, serr, done = lib.stdout_and_stderr_and_done_via(exps, tc)

    argv = tc.long_program_name, *tc.given_argv_tail()
    children = tc.given_children_CLI_functions()
    from script_lib.cheap_arg_parse import cheap_arg_parse_branch as func
    es = func(None, sout, serr, argv, children)
    assert(isinstance(es, int))
    done()
    return _EndState(es, tuple(lines))


_keywords = {'STDERR', 'STDOUT', 'zero_or_one'}


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

    @property
    def last_line(self):
        return self._lines[-1]

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

    def _the_foo_bar_CLI(stdin, stdout, stderr, argv, enver):  # #[#605.3]
        prog_name, *argv_tail = argv
        assert ' ' in prog_name
        if '/' in prog_name:
            head, tail = prog_name.split(' ', 1)
            if '/' in head:
                head = head[(head.rindex('/')+1):]
                prog_name = ' '.join((head, tail))
        stdout.write(f"hello from '{prog_name}'. args: {repr(argv_tail)}\n")
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
