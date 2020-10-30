from data_pipes_test.cli_support import CLI_Case
from modality_agnostic.test_support.common import \
        dangerous_memoize as shared_subject
import unittest


class Case1730_integrate_filter_by_tags(unittest.TestCase):

    def test_100_result(self):
        self.my_case.expect_these_two_entities(self)

    def test_200_statistics(self):
        self.my_case.expect_the_appropriate_statistics(self)

    def given_collection(self):
        lines = unindent("""
        [item.ENA.attributes]
        hi_one = "this is #red"

        [item.ENB.attributes]
        hi_two = "this is #green"

        [item.ENC.attributes]
        hi_three = "this is #blue"
        """)
        itr = block_stream_via_file_lines(lines)
        head_block = next(itr)
        head_block.hello_head_block__
        return tuple(itr)

    @shared_subject
    def end_state(self):
        return self.my_case.build_end_state(self)

    @property
    def my_case(self):
        from data_pipes_test.filter_canon import \
            case_of_one_column_match_two_out_of_three as my_case
        return my_case


class CommonCase(CLI_Case, unittest.TestCase):

    def given_argv(self):
        return '[me]', 'filter-by-tags', * self.given_argv_tail()

    do_debug = False


class Case1733_filter_by_tags_help(CommonCase):

    def test_100_expect_requires_these_particular_arguments(self):
        exp = '<query> [<query> [..]]'
        self.assertIn(exp, self.end_state.lines[0])

    def test_200_expect_this_string_in_first_line_of_description(self):
        exp = 'hashtag-like'
        self.assertIn(exp, self.end_state.lines[2])

    @shared_subject
    def command_help_screen(self):
        return self.build_command_help_screen_subtree()

    def given_argv_tail(self):
        return ('-h',)


class Case1735_minimally_illustrative(CommonCase):

    def test_050_return_code_is_good(self):
        self.exits_with_success_returncode()

    def test_100_outputs_only_the_matched_entities(self):
        self.expect_expected_output_lines()

    def test_200_summary_lines(self):
        self.expect_expected_errput_lines()

    def expected_errput_lines(self):
        yield '(2 match(es) of 3 item(s) seen.)\n'

    def expected_output_lines(self):
        yield '[{\n'
        yield '  "aa": "BB #choo-chii",\n'
        yield '  "cc": "DD"\n'
        yield '},\n'
        yield '{\n'
        yield '  "ii": "JJ",\n'
        yield '  "kk": "#choo-chii LL"\n'
        yield '}]\n'

    def given_argv_tail(self):
        return '-', '#choo-chii'

    def given_stdin(self):
        lines = self.given_input_lines()
        from modality_agnostic.test_support.mock_filehandle import \
            mock_filehandle as func
        return func(lines, '<stdin>')

    def given_input_lines(self):
        yield '[{\n'
        yield '  "aa": "BB #choo-chii",\n'
        yield '  "cc": "DD"\n'
        yield '},\n'
        yield '{\n'
        yield '  "ee": "FF",\n'
        yield '  "gg": "HH"\n'
        yield '},\n'
        yield '{\n'
        yield '  "ii": "JJ",\n'
        yield '  "kk": "#choo-chii LL"\n'
        yield '}]\n'


def block_stream_via_file_lines(lines):
    from kiss_rdb.storage_adapters_.toml.blocks_via_file_lines import \
        block_stream_via_file_lines as func
    return func(lines, None)


def unindent(lines):
    from text_lib.magnetics.via_words import unindent
    return unindent(lines)


if __name__ == '__main__':
    unittest.main()

# #extracted
