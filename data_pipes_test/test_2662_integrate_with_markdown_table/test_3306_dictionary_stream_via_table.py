"""
at the birth commit of this file there are several comments explaning the
origin story of the counterpart asset in its particular current implementation.

this test file's name does not currently isomorph with a magnetic, but its
name is by design: the test file is named as if a magnetic exists that is a
counterpart to the magnetic that *does* actually exist for the html format
adapter.

currently there is no such magnetic in the subject format adapter
  - because we have not yet abstracted any [#410.J] adaptation
    for this format adapter,
  - because we are letting it incubate
      - because of how fresh it is, and
      - because to do so would seem like early abstraction.
"""


from data_pipes_test.common_initial_state import markdown_fixture
from data_pipes_test.disjoint_small_support import (
        build_state_the_bernstein_way)
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject)
import unittest


class _CommonCase(unittest.TestCase):

    def _field_names(self):
        return self._end_state().head_dictionary['field_names']

    def _record(self, k):
        return self._end_state().business_object_dictionary[k]


class Case3306DP_hello(_CommonCase):
    """the interesting tests here (towards the end) are (at writing)..

    ..a sub-slice of tests in our "mentor" test file (Case1640DP). we have
    carried over only a sub-slice of those tests, having the sole intention
    of covering only our format adapter's implementation of [#410.J] record
    mapping in most of its directives:
      - `rename_to`
      - `split_to`
      - (but not `string_via_cel`, for reasons explained below.)

    however, we are not interested in testing what amounts to perhaps the
    main "value proposition" of the actual producer script, which is the
    trick (explained in a comment at length) of .. the field split we do.
    we don't cover it here because it's covered by the mentor test file
    for circumstantial reasons.

    we have not covered this adaptation of `string_via_cel` because currently
    the use of this directive in this adapation is set to the identity
    function, which:
      - exists as a contact exercise, to broadcast its existence as an option
      - is not really testable here (identity function = same values out)

    with #wish [#021] coverage testing we can see what (if any) parts of
    our (not yet formal, housed) adaptation we may have missed.
    """

    def test_100_loads(self):
        self.assertIsNotNone(_subject_module())

    def test_200_runs(self):
        self.assertIsNotNone(self._end_state())

    @shared_subject
    def _end_state(self):
        return build_state_the_bernstein_way(
            fixture_document_path=markdown_fixture('0150-bernstein-subtree.md'),  # noqa: E501
            producer_module=_subject_module(),
        )

    def test_300_the_rename_is_reflected_in_the_field_names(self):
        act = self._field_names()
        self.assertIn('grammar', act)
        self.assertNotIn('parses', act)

    def test_350_the_split_is_reflected_in_the_field_names(self):
        act = self._field_names()
        self.assertIn('updated', act)
        self.assertIn('version', act)


def _subject_module():
    from script.producer_scripts import (
            script_180618_22_parser_generators_via_bernstein as mod)
    return mod


if __name__ == '__main__':
    unittest.main()

# #born (mentored).
