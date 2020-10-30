from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subj_in_child_classes


class CLI_Case:

    # Assertion support

    def exits_with_success_returncode(self):
        self.assertEqual(self.end_state.returncode, 0)

    def expect_expected_output_lines(self):
        self.expect_expected_lines('stdout', 'expected_output_lines')

    def expect_expected_errput_lines(self):
        self.expect_expected_lines('stderr', 'expected_errput_lines')

    def expect_expected_lines(self, which, attr):
        es = self.end_state
        act_lines = es.only_line_run(which).lines
        exp_lines = tuple(getattr(self, attr)())
        self.assertSequenceEqual(act_lines, exp_lines)

    # Performance

    @property
    @shared_subj_in_child_classes
    def end_state(self):
        from script_lib.test_support.expect_STDs import \
            build_end_state_passively_for as func
        return func(self)

    def given_CLI(_):
        from data_pipes.cli import _CLI as func
        return func

    def given_stdin(self):
        itr = self.given_input_lines()
        if itr is None:
            return
        from modality_agnostic.test_support.mock_filehandle import \
            mock_filehandle as func
        return func(itr, '<stdin>')

    def given_input_lines(_):
        pass

    def expected_output_lines(_):
        pass

    def expected_errput_lines(_):
        pass

# #abstracted
