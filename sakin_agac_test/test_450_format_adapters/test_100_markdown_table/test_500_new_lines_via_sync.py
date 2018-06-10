# #covers: script.sync

from _init import (
        build_end_state_commonly,
        fixture_executable_path,
        fixture_file_path,
        )
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        )
import unittest


class _CommonCase(unittest.TestCase):

    # -- assertion support

    def _outputs_no_lines(self):
        self.assertEqual(len(self._end_state().outputted_lines), 0)

    def _build_two_sentences_commonly(self):
        _em = self._emission('first_error')
        _hi = _em.to_string()
        return _hi.split('. ')  # copy-paste of modality-specific

    def _channel_tail_component(self):
        return self._emission('first_error').channel[-1]

    def _emission(self, name):
        return self._end_state().actual_emission_index.actual_emission_via_name(name)  # noqa: E501

    # --

    _build_end_state = build_end_state_commonly


class Case010_strange_format_adapter_name(_CommonCase):
    """(this is the other end of getting us "over the wall" - this has

    two copy-pasted tests that appear the same in the modality-specific
    tests to demonstrate the lower-level way to test such things..
    """

    def test_100_outputs_no_lines(self):
        self._outputs_no_lines()

    def test_150_this_particular_terminal_channel_name(self):
        self.assertEqual(self._channel_tail_component(), 'format_adapter_not_found')  # noqa: E501

    def test_200_says_not_found(self):  # COPY-PASTED
        _ = self._two_sentences()[0]
        self.assertEqual(_, "no format adapter for 'zig-zag'")

    def test_300_says_did_you_mean(self):  # COPY-PASTED
        _ = self._two_sentences()[1]
        self.assertRegex(_, r"\bthere's '[a-z_]+' and '")

    @shared_subject
    def _two_sentences(self):
        return self._build_two_sentences_commonly()

    @shared_subject
    def _end_state(self):
        return self._build_end_state()

    def expect_emissions(self):
        yield 'error', '?+', 'as', 'first_error'

    def given(self):
        return {
                'near_collection': None,
                'far_collection': None,
                'far_format': 'zig-zag',
                }


class Case020_strange_file_extension(_CommonCase):

    def test_100_outputs_no_lines(self):
        self._outputs_no_lines()

    def test_150_this_particular_terminal_channel_name(self):
        self.assertEqual(self._channel_tail_component(), 'file_extension_not_matched')  # noqa: E501

    def test_200_says_not_found(self):
        _ = self._two_sentences()[0]
        self.assertEqual(_, "no format adapter that recognizes filename extension for '.zongo'")  # noqa: E501

    def test_300_says_did_you_mean(self):
        _ = self._two_sentences()[1]
        self.assertRegex(_, r"\bthere's '\*\.[a-z_]+' and '\*\.")

    @shared_subject
    def _two_sentences(self):
        return self._build_two_sentences_commonly()

    @shared_subject
    def _end_state(self):
        return self._build_end_state()

    def expect_emissions(self):
        yield 'error', '?+', 'as', 'first_error'

    def given(self):
        return {
                'near_collection': None,
                'far_collection': 'ziffy-zaffy.zongo',
                }


class Case030_no_functions(_CommonCase):  # #coverpoint5.1
    """discussion - the point here (new in #history-A.1) is that whether

    you're posing it as a far collection or near for the syncrhonization,
    it uses the same machinery (and language production) to complain about
    how it's can't do a thing.
    """

    def test_100_outputs_no_lines(self):
        self._outputs_no_lines()

    def test_200_says_not_found(self):
        _ = self._two_sentences()[0]
        self.assertEqual(_, "the 'markdown_table' format adapter has no sub-section for 'modality_agnostic'")  # noqa: E501

    def test_300_says_did_you_mean(self):
        _ = self._two_sentences()[1]
        self.assertIn("there's 'CLI'", _)

    @shared_subject
    def _two_sentences(self):
        _ = self._emission('first_error').to_string()
        return _.split('. ')

    @shared_subject
    def _end_state(self):
        return self._build_end_state()

    def expect_emissions(self):
        yield 'error', 'expression', 'as', 'first_error'

    def given(self):
        return {
                'near_collection': _same_existent_markdown_file(),
                'far_collection': fixture_file_path('chimi-churry.md'),
                }


class Case040_near_file_not_found(_CommonCase):

    # #coverpoint5.2 - this is the first code to rustle up a lot of stuff

    def test_100_raises_this_one_exception(self):
        def f():
            self._build_end_state()
        _rx = r"\bNo such file or directory: '.+\.md'$"
        self.assertRaisesRegex(FileNotFoundError, _rx, f)

    def expect_emissions(self):
        return iter(())

    def given(self):
        return {
                'near_collection': fixture_file_path('0075-no-such-file.md'),
                'far_collection': _far_script_exists(),
                }


class Case050_duplicate_key(_CommonCase):  # #coverpoint5.3

    def test_100_gets_two_lines_in(self):
        _act = self._end_state().outputted_lines
        _exp = ('|col A|col B|\n', '|:--|--:|\n')
        self.assertSequenceEqual(_act, _exp)

    def test_200_said_this_thing(self):
        _act = self._emission('erx').to_string()
        _exp = "duplicate human key value in far collection ('qux')"
        self.assertEqual(_act, _exp)

    @shared_subject
    def _end_state(self):
        return self._build_end_state()

    def expect_emissions(self):
        yield ('error', 'expression', 'duplicate_human_key_value', 'as', 'erx')

    def given(self):

        _these = (
            {'_is_sync_meta_data': True, 'natural_key_field_name': 'col_a'},
            {'col_a': 'qux'},
            {'col_a': 'xx'},
            {'col_a': 'qux'},
        )
        return {
            'near_collection': fixture_file_path('0110-endcap-yes-no.md'),
            'far_collection': _these,
        }


class Case060_UPDATE(_CommonCase):  # #coverpoint5.4

    def test_100_HI(self):
        _act = self._end_state().outputted_lines[2:]
        _exp = ('|thing A|x|\n', '|thing B|win|\n')  # NOTE - 
        self.assertSequenceEqual(_act, _exp)

    @shared_subject
    def _end_state(self):
        return self._build_end_state()

    def expect_emissions(self):
        return iter(())
        yield ('error', 'expression', 'duplicate_human_key_value', 'as', 'erx')

    def given(self):

        _these = (
            {'_is_sync_meta_data': True, 'natural_key_field_name': 'col_a'},
            {'col_a': 'thing B', 'col_b': 'win'},
        )
        return {
            'near_collection': fixture_file_path('0110-endcap-yes-no.md'),
            'far_collection': _these,
        }


def _far_script_exists():
    return fixture_executable_path('100_chimi_churri.py')


def _same_existent_markdown_file():
    return fixture_file_path('0080-too-few-rows.md')


if __name__ == '__main__':
    unittest.main()

# #history-A.1
# #born.
