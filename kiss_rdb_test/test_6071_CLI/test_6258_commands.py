from kiss_rdb_test.common_initial_state import functions_for
from kiss_rdb_test import CLI as CLI_support
from kiss_rdb_test.CLI import build_filesystem_expecting_num_file_rewrites
import unittest
from modality_agnostic.test_support.common import \
        dangerous_memoize as shared_subject


class CommonCase(CLI_support.CLI_Test_Case_Methods, unittest.TestCase):

    might_debug = False


class Case6248_schema_parse_error(CommonCase):

    def test_100_fails(self):
        self.assertEqual(self.end_state.exit_code, 400)

    def test_200_expresses(self):
        # == BEGIN normalize a long path into a short path
        from os import path as os_path
        lines = list(self.end_state.lines)  # ..
        line = lines[1]
        head, tail = line.split(' ', 1)
        tail = os_path.basename(tail)
        lines[1] = ' '.join((head, tail))
        # == END

        _expected = tuple(unindent('''
        input error: expecting colon
        in schema.rec
           3:    xx yy zz
                 --^
        '''))
        self.assertSequenceEqual(lines, _expected)

    @shared_subject
    def end_state(self):
        return self.build_end_state('stderr',  None)

    def given_args(self):
        return (*common_args_head(), 'traverse', '040-schema-parse-error')

    def filesystem(self):
        return None  # use real filesystem


class Case6250_modality_specific_whiner(CommonCase):

    def test_100_exit_code_reflects_failure(self):
        self.expect_exit_code_for_bad_request()

    def test_200_main_message_is_in_there(self):
        self.assertIn('multi-line strings must have', self.message)

    def test_300_qualifies_it_as_about_this_name_and_value(self):
        self.assertIn(
            "Could not set 'qq' to 'foo\\nbar' because for now, ",
            self.message)

    def test_400_we_added_our_own_punctuaton_to_the_end(self):
        self.assertEqual(self.message[-5:], 'ter.\n')

    @shared_subject
    def message(self):
        line, = self.end_state.lines
        return line

    @shared_subject
    def end_state(self):
        return self.build_end_state('stderr',  None)

    def given_args(self):
        return (*common_args_head(), 'create', _common_collection,
                '-val', 'qq', 'foo\nbar')

    def random_number(self):
        return 123

    def filesystem(self):
        return build_filesystem_expecting_num_file_rewrites(0)  # ..


class Case6258_multi_line_create(CommonCase):  # #midpoint

    def test_100_succeeds(self):
        self.expect_exit_code_is_the_success_exit_code()

    def test_200_announces_created(self):
        _actual, line2 = self.common_entity_screen.stderr_lines_one_and_two
        self.assertEqual(_actual, "created '2HF' with 1 attribute\n")
        self.assertIsNone(line2)

    def test_300_outputs_created(self):
        _actual = self.common_entity_screen.stdout_lines

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
        return self.build_end_state('stdout_and_stderr', None)

    def given_args(self):
        return (*common_args_head(), 'create', _common_collection,
                '-val', 'qq', 'foo\nbar\n')

    def random_number(self):
        return 493  # our 2HF
        # this is so gross, we used to use 123 (our 25V) but it would create
        # an empty file. ich muss sein. the above uses an existng file.

    def filesystem(self):
        return build_filesystem_expecting_num_file_rewrites(2)


def unindent(big_s):
    from script_lib.test_support import unindent
    return unindent(big_s)


common_args_head = functions_for('toml').common_args_head


_common_collection = '050-rumspringa'


if __name__ == '__main__':
    unittest.main()

# #born.
