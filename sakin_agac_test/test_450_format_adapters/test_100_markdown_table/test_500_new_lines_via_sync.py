# #covers: script.sync

from _init import (
        cover_me,
        )
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        )
import unittest


class _CommonCase(unittest.TestCase):

    # -- assertion support

    def _outputs_no_lines(self):
        self.assertEqual(len(self._end_state().outputted_lines), 0)

    def _emission(self, name):
        return self._end_state().actual_emission_index.actual_emission_via_name(name)  # noqa: E501

    # --

    def _build_end_state(self):

        import modality_agnostic.test_support.listener_via_expectations as lib

        exp = lib(self._emissions())

        _d = self._given()

        import script.sync as lib
        _guy = lib._OpenNewLines_via_Sync(
                ** _d,
                listener=exp.listener,
                )
        with _guy as lines:
            for line in lines:
                print('wahoo: %s' % line)
                cover_me('wahoo')

        _ = exp.actual_emission_index_via_finish()
        return _EndState((), _)


class Case010_strange_format_adapter_name(_CommonCase):
    """(this is the other end of getting us "over the wall" - this has

    two copy-pasted tests that appear the same in the modality-specific
    tests to demonstrate the lower-level way to test such things..
    """

    def test_100_outputs_no_lines(self):
        self._outputs_no_lines()

    def test_200_says_not_found(self):  # COPY-PASTED
        _ = self._two_sentences()[0]
        self.assertEqual(_, "no format adapter for 'zig-zag'")

    def test_300_says_did_you_mean(self):  # COPY-PASTED
        _ = self._two_sentences()[1]
        self.assertRegex(_, r"\bthere's '[a-z_]+' and '")

    @shared_subject
    def _two_sentences(self):
        _em = self._emission('first_error')
        _hi = _em.to_string()
        return _hi.split('. ')  # copy-paste of modality-specific

    @shared_subject
    def _end_state(self):
        return self._build_end_state()

    def _emissions(self):
        yield 'error', '?+', 'as', 'first_error'

    def _given(self):
        return {
                'near_collection': None,
                'far_collection': None,
                'far_format': 'zig-zag',
                }


class _EndState:
    def __init__(self, outputted_lines, aei):
        self.outputted_lines = outputted_lines
        self.actual_emission_index = aei


if __name__ == '__main__':
    unittest.main()

# #born.
