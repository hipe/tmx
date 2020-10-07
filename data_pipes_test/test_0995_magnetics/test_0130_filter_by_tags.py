from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subj_in_child_classes, \
        dangerous_memoize as shared_subject
import unittest


class Case0130_integrate_filter_by_tags(unittest.TestCase):

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


class CLI_Case(unittest.TestCase):

    @property
    @shared_subj_in_child_classes
    def end_state(self):
        from script_lib.test_support.expect_STDs import \
                build_end_state_passively_for as func
        return func(self)

    def given_stdin(_):
        pass

    def given_argv(self):
        return 'ohai mami', * self.given_argv_tail()

    def given_CLI(_):
        from data_pipes.cli import _CLI as func
        return func

    do_debug = False


class Case0133_filter_by_tags_help(CLI_Case):

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
        return 'filter-by-tags', '-h'


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
