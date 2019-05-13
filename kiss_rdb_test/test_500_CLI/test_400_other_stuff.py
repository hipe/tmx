from _common_state import (
        unindent,
        )
from kiss_rdb_test import CLI as CLI_support
from kiss_rdb_test.CLI import (
    common_args_head,
    build_filesystem_expecting_num_file_rewrites,
    )
import unittest
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        )


# 830-840


class _CommonCase(CLI_support.CLI_Test_Case_Methods, unittest.TestCase):

    might_debug = False


class Case830_modality_specific_whiner(_CommonCase):

    def test_100_exit_code_reflects_failure(self):
        self.expect_exit_code_for_bad_request()

    def test_200_main_message_is_in_there(self):
        self.assertIn('multi-line strings must have', self._message())

    def test_300_qualifies_it_as_about_this_name_and_value(self):
        self.assertIn(
            "Could not set 'qq' to 'foo\\nbar' because for now, ",
            self._message())

    def test_400_we_added_our_own_punctuaton_to_the_end(self):
        self.assertEqual(self._message()[-5:], 'ter.\n')

    @shared_subject  # necessary
    def _message(self):
        line, = self.end_state().lines
        return line

    @shared_subject
    def end_state(self):
        return self.build_end_state('stderr', 'click exception')

    def given_args(self):
        return (
                *common_args_head(), 'create', _common_collection,
                '-val', 'qq', 'foo\nbar',
                )

    def random_number(self):
        return 123

    def filesystem(self):
        return build_filesystem_expecting_num_file_rewrites(0)  # ..


class Case831_multi_line_create(_CommonCase):

    def test_100_succeeds(self):
        self.expect_exit_code_is_the_success_exit_code()

    def test_200_announces_created(self):
        _actual = self.common_entity_screen().stderr_line
        self.assertEqual(_actual, 'created:\n')

    def test_300_outputs_created(self):
        _actual = self.common_entity_screen().stdout_lines

        _expected = tuple(unindent('''
        [item.2HF.attributes]
        qq = """
        foo
        bar
        """
        '''))

        self.assertSequenceEqual(_actual, _expected)

    @shared_subject
    def common_entity_screen(self):
        return self.expect_common_entity_screen()

    @shared_subject
    def end_state(self):
        return self.build_end_state('stdout and stderr', None)

    def given_args(self):
        return (
                *common_args_head(), 'create', _common_collection,
                '-val', 'qq', 'foo\nbar\n',
                )

    def random_number(self):
        return 493  # our 2HF
        # this is so gross, we used to use 123 (our 25V) but it would create
        # an empty file. ich muss sein. the above uses an existng file.

    def filesystem(self):
        return build_filesystem_expecting_num_file_rewrites(2)


_common_collection = '050-rumspringa'


if __name__ == '__main__':
    unittest.main()


# #pending-rename: decide later the defining doo-hah of this file
# #born.
