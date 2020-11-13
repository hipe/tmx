"""helper for testing CLI in a generic, magnetic-agnostic way

:[#601.5]. Mentee of [#459.6]. When you want to add more, see that one.
"""

from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subj_in_child_classes


def _delegate_to_end_state(orig_f):  # #decorator
    def use_f(self):
        return getattr(self.end_state, attr)
    attr = orig_f.__name__
    return property(use_f)


class CLI_Canon_Assertion_Methods:

    # -- assertion methods

    def expect_failure_returncode(self):
        self.assertNotEqual(self.end_state.returncode, 0)

    def expect_success_returncode(self):
        self.expect_returncode(0)

    def expect_returncode(self, exp):
        act = self.returncode_checked()
        self.assertEqual(act, exp)

    def returncode_checked(self):
        act = self.end_state.returncode
        self.assertIsInstance(act, int)
        return act

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

    def help_screen_via_lines(_, lines):
        from .expect_help_screen import parse_help_screen as func
        return func(lines)

    @property
    @shared_subj_in_child_classes
    def end_state(self):
        return self.build_end_state()

    def build_end_state(self):
        return self.build_end_state_using_line_expectations()

    def build_end_state_using_line_expectations(self):
        from .expect_STDs import build_end_state_actively_for as func
        return func(self)


def THESE_TWO_CHILDREN_CLI_METHODS():

    def _the_foo_bar_CLI(stdin, stdout, stderr, argv, efx):  # #[#605.3]
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
