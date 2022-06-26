from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subject_in_children
from unittest import TestCase as unittest_TestCase, main as unittest_main

"""NOTE We really don't love depending on a working recutils installation
for these tests; but we tried alternatives and it was nasty (because to
get it to work we would need to mock multiple recsel commands against the
same file (one for one record type, one for another)

Ultimately we decided it was better to cover something than nothing at all.
Later we can try to add flags etc to conditionally turn these tests off.
"""


class CommonCase(unittest_TestCase):

    @property
    def end_state_stdout_lines(self):
        return self.end_state[0]

    @property
    def end_state_stderr_lines(self):
        return self.end_state[1]

    @property
    def end_state_return_code(self):
        return self.end_state[2]

    @property
    @shared_subject_in_children
    def end_state(self):
        from script_lib.test_support.expect_STDs import \
                    pretend_STDIN_via_mixed, \
                    spy_on_write_and_lines_for as spy_for
        use_stdin = pretend_STDIN_via_mixed('FAKE_STDIN_INTERACTIVE')
        use_stdout, sout_lines = spy_for(self, 'SOUT: ', isatty=True)
        use_stderr, serr_lines = spy_for(self, 'SERR: ', isatty=True)
        use_recfile = self.given_recfile
        use_argv = ('ohai', 'viz', use_recfile)
        rc = subject_module()._CLI(
            sin=use_stdin, sout=use_stdout, serr=use_stderr, argv=use_argv)
        return sout_lines, serr_lines, rc

    do_debug = False


class Case1255_everything(CommonCase):

    def test_010_executes(self):
        assert self.end_state

    def test_020_return_code_is_success(self):
        assert 0 == self.end_state_return_code

    def test_030_output_lines_look_good(self):
        lines = self.end_state_stdout_lines
        assert 'digraph g {\n' == lines[0]
        assert '}\n' == lines[-1]
        assert '/* Nodes */' in lines[2]
        assert len(lines) >= 7

    def test_040_errput_lines_look_good(self):
        lines = self.end_state_stderr_lines
        assert 'recsel ' == lines[0][:7]  # ick/meh
        assert len(lines) < 3  # or whatever

    given_recfile = 'app_flow_test/fixture-files/case-1255-minimal.rec'


def subject_module():
    # XXX not sure if will come in thru CLI
    import app_flow.cli as mod
    return mod


if __name__ == '__main__':
    unittest_main()

# #born
