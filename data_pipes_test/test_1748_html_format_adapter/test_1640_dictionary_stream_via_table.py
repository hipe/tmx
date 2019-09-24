"""
this script-test has a particularly nifty origin story:

we felt reasonably certain when reaching the end of developing the
counterpart asset of this of what we had suspected by around the middle:
that it's weird and awkward that we're taking data that "starts as"
markdown, taking its expression in HTML, and parsing that only to convert it
back to markdown (in effort to get back to what it started as).

like, although it can be done it doesn't future-proof well: we can, for
example, try to recognize and convert links (anchor tags), but this isn't
out-of-the-box future-proof against any future features we might want
to carry over from source to destination. since an imagined #html2markdown
is a nontrivial undertaking that certainly wouldn't "write itself" in a
very straightforward way, it's a potential future problem we want to
sidestep now if we can.

ok but having said that, the development of this producer script was what
pioneered the creation of [#459.E] the record mapper thing. we then exercised
all of its available directives in the coverage for this producer script.
(of course we did, because the abstract thing was abstracted entirely from
the concrete thing).

as such, we have since refactored the producer script to pioneer our direct-
from-markdown scraping (still *thru* our new record mapping facility, but
with a newly built adaptation of it *for* markdown); but we keep this
script-test and its underlying support infrastructure in place:

  - for any extent that it alone covers features of the record mapper

  - because it's the only thing that covers the html adaptaton of same
    (a thing we certainly want to keep around for later, and because it's
    still used in the producer script that came before this (whose source
    content "lives in" (#wish [#459.H]) moin moin.

(this whole big change discussed above happened at #history-A.1.)
"""

from data_pipes_test.common_initial_state import html_fixture
from data_pipes_test.disjoint_small_support import (
        build_state_the_bernstein_way)
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        lazy)
import unittest


class _CommonCase(unittest.TestCase):

    def _field_names(self):
        return self._end_state().sync_keys_seen

    def _record(self, k):
        return self._end_state().entity_dictionary_via_sync_key[k]


class Case1640DP_hello(_CommonCase):

    def test_100_loads(self):
        self.assertIsNotNone(_subject_module())

    def test_200_runs(self):
        self._end_state()

    def test_300_the_rename_is_reflected_in_the_field_names(self):
        act = self._field_names()
        self.assertIn('grammar', act)
        self.assertNotIn('parses', act)

    def test_350_the_split_is_reflected_in_the_field_names(self):
        act = self._field_names()
        self.assertIn('updated', act)
        self.assertIn('version', act)

    def test_410_a_typical_version_and_date_parse(self):
        dct = self._record('pyparsing')
        self.assertEqual('2014-08', dct['updated'])
        self.assertEqual('v2.0.3', dct['version'])

    def test_420_date_but_no_version(self):
        dct = self._record('plex3')
        self.assertIn('updated', dct)
        self.assertNotIn('version', dct)

    def test_430_gap_after_v_IS_NORMALIZED(self):
        dct = self._record('lepl')
        self.assertEqual('v5.1.3', dct['version'])

    def test_440_version_that_is_just_integer_no_dot(self):
        dct = self._record('berkeleyyacc')
        self.assertEqual(dct['version'], 'v20141128')

    def test_450_complicated_version_with_spaces(self):
        dct = self._record('spark')
        self.assertEqual(dct['version'], 'v0.7 pre-alpha 7')

    def test_460_currently_these_links_are_flattened(self):
        dct = self._record('pyparsing')
        self.assertEqual(dct['used_by'], 'twill')

    @shared_subject
    def _end_state(self):
        return build_state_the_bernstein_way(
                fixture_document_path=html_fixture('0140-bernstein-subtree.html'),  # noqa: E501
                producer_module=_subject_module(),
                )


@lazy
def _subject_module():
    from data_pipes_test.fixture_executables import (
            exe_150_json_stream_via_bernstein_html as x)
    return x


if __name__ == '__main__':
    unittest.main()

# #history-A.1: as referenced
# #born.
