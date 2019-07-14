# #covers: script.sync

from _init import (
        build_end_state_commonly,
        fixture_executable_path,
        fixture_file_path,
        )
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        lazy)
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

    # -- build state hook-ins & other support

    _build_end_state = build_end_state_commonly

    def expect_emissions(self):
        # (by default, we expect no emissions)
        return iter(())


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

    you're posing it as a far collection or near for the synchronization,
    it uses the same machinery (and language production) to complain about
    how it's can't do a thing.

    this test is #fragile - it fails to fail when we add features to the f.a
    """

    def test_100_outputs_no_lines(self):
        self._outputs_no_lines()

    def test_200_says_not_found(self):
        _ = self._two_sentences()[0]
        _exp = "the 'json_script' format adapter has no modality functions for 'CLI'"  # noqa: E501
        self.assertEqual(_, _exp)

    def test_300_says_did_you_mean(self):
        _ = self._two_sentences()[1]
        self.assertIn("there's 'modality_agnostic'", _)

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
                'near_collection': _far_script_exists(),
                'far_collection': _same_existent_markdown_file(),
                }


class Case040_near_file_not_found(_CommonCase):

    # #coverpoint5.2 - this is the first code to rustle up a lot of stuff

    def test_100_raises_this_one_exception(self):
        def f():
            self._build_end_state()
        _rx = r"\bNo such file or directory: '.+\bno-such-file\.md'$"
        self.assertRaisesRegex(FileNotFoundError, _rx, f)

    def given(self):
        return {
                'near_collection': fixture_file_path('0075-no-such-file.md'),
                'far_collection': fixture_executable_path('exe_110_extra_cel.py'),  # noqa: E501
                }


class Case050_duplicate_key(_CommonCase):  # #coverpoint5.3

    def test_100_gets_as_far_as_the_schema_lines_and_a_couple_recs_WHY(self):
        _act = self._end_state().outputted_lines
        _exp = (
                '|col A|col B|\n',
                '|:--|--:|\n',
                '|thing A|x|\n',
                '|qux    | |\n',
                )
        self.assertSequenceEqual(_act, _exp)

    def test_200_said_this_thing(self):
        _act = self._emission('erx').to_string()
        _exp = "duplicate key in far traversal: 'qux'"
        self.assertEqual(_act, _exp)

    @shared_subject
    def _end_state(self):
        return self._build_end_state()

    def expect_emissions(self):
        yield ('error', 'expression', 'duplicate_key', 'as', 'erx')

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


class Case060_preserve_endcappiness_here(_CommonCase):  # #coverpoint5.4
    """this is the proof of bugfix - we want that a row that didn't
    have an endcap before, DOESN'T have an endcap after (even though
    the last cel's value changed.

    (ACTUALLY we WOULD want the endcap to be added here but, as long
    as we don't detect ineffective updates; that is, as long as we go
    through with no-effect updates, we want them to be truly no-effect...)

    NOTE the original has stochastic whitespace. the updated cel loses
    this whitespace. we presume it is that the new is using the whitespacing
    of the [#418.D] example row. but at this point, we don't know nore care.
    that is a bridge to cross when we get to it.
    """

    def test_100_win(self):
        _act = self._end_state().outputted_lines[2:]
        _exp = (
                _same_row_1,
                '|thing B|thing two\n',  # NOTE still no endcap
                '|thing C|\n',  # exactly as in file
                )
        self.assertSequenceEqual(_act, _exp)

    @shared_subject
    def _end_state(self):
        return self._build_end_state()

    def given(self):

        _far = (
                _same_this(),
                {'col_a': 'thing B', 'col_b': 'thing two'},
                )
        return {
            'near_collection': fixture_file_path('0110-endcap-yes-no.md'),
            'far_collection': _far,
        }


class Case070_ADD_end_cappiness_here(_CommonCase):  # #coverpoint5.5
    """this is kind of an edge case as a corollary of the above thing,
    and it reveals something about the idea of "endcap" - here, the
    endcap gets added because we are lengthening the number of cels.

    broadly, endcaps are what we want, and we support their absense
    for historic reasons.
    """

    def test_100_win(self):
        _act = self._end_state().outputted_lines[2:]
        _exp = (
                _same_row_1,
                '|thing B| thing one\n',  # exactly as in file
                '|thing C|yerp|\n',  # note yes encap
                )
        self.assertSequenceEqual(_act, _exp)

    @shared_subject
    def _end_state(self):
        return self._build_end_state()

    def given(self):

        _far = (
                _same_this(),
                {'col_a': 'thing C', 'col_b': 'yerp'},
                )
        return {
            'near_collection': fixture_file_path('0110-endcap-yes-no.md'),
            'far_collection': _far,
        }


_same_row_1 = '|thing A|x|\n'


@lazy
def _same_this():
    return {'_is_sync_meta_data': True, 'natural_key_field_name': 'col_a'}


def _far_script_exists():
    return fixture_executable_path('exe_100_bad_natural_key.py')


def _same_existent_markdown_file():
    return fixture_file_path('0080-cel-underflow.md')


if __name__ == '__main__':
    unittest.main()

# #history-A.1
# #born.
