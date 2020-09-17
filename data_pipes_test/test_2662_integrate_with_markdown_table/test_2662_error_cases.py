from data_pipes_test.common_initial_state import (
        build_end_state_commonly,
        FakeProducerScript,
        markdown_fixture,
        executable_fixture,
        fixture_files_directory)
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject)
import unittest
from os import path as os_path


class CommonCase(unittest.TestCase):

    # -- assertion support

    def _outputs_no_lines(self):
        self.assertEqual(len(self.end_state.outputted_lines), 0)

    def _build_two_sentences_commonly(self):
        msg, = self._emission('first_error').to_messages()
        return msg.split('. ')  # copy-paste of modality-specific

    def _channel_tail_component(self):
        return self._emission('first_error').channel[-1]

    def _emission(self, name):
        return self.end_state.actual_emission_index[name]

    # -- build state hook-ins & other support

    build_end_state = build_end_state_of_sync

    def expect_emissions(self):
        # (by default, we expect no emissions)
        return iter(())



class Case2557DP_strange_format_adapter_name(CommonCase):
    """(this is the other end of getting us "over the wall" - this has

    two copy-pasted tests that appear the same in the modality-specific
    tests to demonstrate the lower-level way to test such things..
    """

    def test_100_outputs_no_lines(self):
        self._outputs_no_lines()

    def test_150_this_particular_terminal_channel_name(self):
        self.assertEqual(self._channel_tail_component(), 'unrecognized_format_name')  # noqa: E501

    def test_200_says_not_found(self):  # COPY-PASTED
        _ = self.two_sentences[0]
        self.assertEqual(_, "unrecognized format name 'zig-zag'")

    def test_300_says_did_you_mean(self):  # COPY-PASTED
        _ = self.two_sentences[1]  # #here (next line)
        self.assertRegex(_, r"\bknown format name\(s\): \('[a-z_]+', '")

    @shared_subject
    def two_sentences(self):
        return self._build_two_sentences_commonly()

    @shared_subject
    def end_state(self):
        return self.build_end_state()

    def expect_emissions(self):
        yield 'error', '?+', 'as', 'first_error'

    def given(self):
        return {
                'producer_script_path': 'no see 324ujerie09heoiw',
                'near_collection': None,
                'near_format': 'zig-zag',
                }


class Case2559_strange_file_extension(CommonCase):

    def test_100_outputs_no_lines(self):
        self._outputs_no_lines()

    def test_150_this_particular_terminal_channel_name(self):
        self.assertEqual(self._channel_tail_component(), 'unrecognized_extname')  # noqa: E501

    def test_200_says_not_found(self):
        _ = self.two_sentences[0]
        self.assertEqual(_, "unrecognized extension '.zongo'")

    def test_300_says_did_you_mean(self):
        _ = self.two_sentences[1]  # #here (next line)
        self.assertRegex(_, r"\bknown extension\(s\): \('\.[a-z]+', '")

    @shared_subject
    def two_sentences(self):
        return self._build_two_sentences_commonly()

    @shared_subject
    def end_state(self):
        return self.build_end_state()

    def expect_emissions(self):
        yield 'error', '?+', 'as', 'first_error'

    def given(self):
        _near_path = os_path.join(fixture_files_directory(), '080-strange-extension.zongo')  # noqa: E501
        return {
                'producer_script_path': 'no see 23os093w3hw33',
                'near_collection': _near_path,
                }


class Case2660DP_no_functions(CommonCase):
    # The point of this case changed once at #history-A.1 and then once again
    # at #history-A.2. Currently its only purpose is to cover what happens
    # when the collection implementation doesn't have the requisite [#873.12]
    # collection capabilities.

    def test_100_outputs_no_lines(self):
        self._outputs_no_lines()

    def test_200_says_not_found(self):
        act = self.two_sentences[0]
        rxs = r"^the 'rec' fo.+ has no .+ 'SYNC_AGENT_FOR_DATA_PIPES'"
        self.assertRegex(act, rxs)

    def test_300_says_did_you_mean(self):
        act = self.two_sentences[1]
        self.assertIn("there's 'collection_path'", act)

    @shared_subject
    def two_sentences(self):
        msg, = self._emission('first_error').to_messages()
        return msg.split('. ')

    @shared_subject
    def end_state(self):
        return self.build_end_state()

    def expect_emissions(self):
        yield 'error', 'expression', 'as', 'first_error'

    def given(self):
        from kiss_rdb_test.common_initial_state import top_fixture_directories_directory  # noqa: E501
        _near_path = os_path.join(
                top_fixture_directories_directory(),
                '2969-rec', '0100-example-from-documentation.rec')
        return {
                'producer_script_path': 'no see 32o4iu32boiwr3si',
                'near_collection': _near_path,
                }


class Case2662DP_near_file_not_found(CommonCase):

    # this is the first code to rustle up a lot of stuff

    def test_100_channel(self):
        _em = self._emission('first_error')
        self.assertSequenceEqual(
                _em.channel[2:],
                ('collection_not_found', 'no_such_file_or_directory'))

    def test_200_message(self):
        sct = self._emission('first_error').flush_payloader()
        self.assertEqual(sct['errno'], 2)
        self.assertEqual(sct['reason'], 'No such file or directory')
        self.assertIn('0000-no-such-file', sct['filename'])

    @shared_subject
    def end_state(self):
        return self.build_end_state()

    def expect_emissions(self):
        yield 'error', '?+', 'as', 'first_error'

    def given(self):
        return {
                'producer_script_path': executable_fixture('exe_110_extra_cel.py'),  # noqa: E501
                'near_collection': markdown_fixture('0000-no-such-file.md'),
                }


class Case2664DP_duplicate_key(CommonCase):

    def test_100_says_this_thing(self):
        actual, = self._emission('erx').to_messages()
        expected = "duplicate key in far traversal: 'qux'"
        self.assertEqual(actual, expected)

    def test_200_gets_as_far_as_the_example_line(self):
        act = self.end_state.outputted_lines
        exp = (
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
    def end_state(self):
        return self.build_end_state()

    def expect_emissions(self):
        yield 'error', 'expression', 'duplicate_key', 'as', 'erx'

    def given(self):
        _dictionaries = (
            {'col_a': 'qux'},
            {'col_a': 'xx'},
            {'col_a': 'qux'},
        )
        _producer_script = FakeProducerScript(
                stream_for_sync_is_alphabetized_by_key_for_sync=False,
                stream_for_sync_via_stream=sync_stream_using_column_A,
                dictionaries=dictionaries,
                near_keyerer=near_keyerer_minimal)
        return {
                'producer_script_path': _producer_script,
                'near_collection': markdown_fixture('0110-endcap-yes-no.md'),
        }


class Case2665DP_preserve_endcappiness_here(CommonCase):
    """this is the proof of bugfix - we want that a row that didn't
    have an endcap before, DOESN'T have an endcap after (even though
    the last cel's value changed.

    (ACTUALLY we WOULD want the endcap to be added here but, as long
    as we don't detect ineffective updates; that is, as long as we go
    through with no-effect updates, we want them to be truly no-effect...)

    NOTE the original has stochastic whitespace. the updated cel loses
    this whitespace. we presume it is that the new is using the whitespacing
    of the [#458.D] example row. but at this point, we neither know or care.
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
    def end_state(self):
        return self.build_end_state()

    def given(self):
        _dictionaries = (
                {'col_a': 'thing B', 'col_b': 'thing two'},
                )
        _producer_script = FakeProducerScript(
                stream_for_sync_is_alphabetized_by_key_for_sync=False,
                stream_for_sync_via_stream=sync_stream_using_column_A,
                dictionaries=_dictionaries,
                near_keyerer=near_keyerer_minimal,
                )
        return {
                'producer_script_path': _producer_script,
                'near_collection': markdown_fixture('0110-endcap-yes-no.md'),
                }


class Case2667DP_ADD_end_cappiness_here(CommonCase):
    """this is kind of an edge case as a corollary of the above thing,
    and it reveals something about the idea of "endcap" - here, the
    endcap gets added because we are lengthening the number of cels.

    broadly, endcaps are what we want, and we support their absense
    for historic reasons.
    """

    def test_100_win(self):
        act = self.end_state.outputted_lines[2:]
        exp = (
                same_row_1,
                '|thing B| thing one\n',  # exactly as in file
                '|thing C|yerp|\n')  # note yes encap
        self.assertSequenceEqual(act, exp)

    @shared_subject
    def end_state(self):
        return self.build_end_state()

    def given(self):
        _dictionaries = (
                {'col_a': 'thing C', 'col_b': 'yerp'},
                )
        producer_script = FakeProducerScript(
                stream_for_sync_via_stream=sync_stream_using_column_A,
                stream_for_sync_is_alphabetized_by_key_for_sync=False,
                dictionaries=_dictionaries,
                near_keyerer=near_keyerer_minimal,
                )
        return {
                'producer_script_path': _producer_script,
                'near_collection': markdown_fixture('0110-endcap-yes-no.md'),
                }


same_row_1 = '|thing A|x|\n'


def sync_stream_using_column_A(dcts):
    for dct in dcts:
        yield (dct['col_A'], dct)


def near_keyerer_minimal(key_via_native, schema, listener):
    def near_keyer(native):
        return native.cell_at_offset(0).value_string
    return near_keyer


def _same_existent_markdown_file():
    return markdown_fixture('0080-cel-underflow.md')


if __name__ == '__main__':
    unittest.main()

# #history-A.2
# #history-A.1
# #born.
