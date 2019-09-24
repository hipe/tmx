"""
multi-axis coverage from this script-test:

  - cover the particular producer script (used for business) and
  - provide limited coverage to the HTML format adapter's particular
    adaption of [#459.E] record mapping.

we say "limited" because this particular exercise of record mapping is a
simpler case. we don't use typical inspiration features like field splitting
or field renaming. yet still our use of record mapping is justifed:

  - we have a means of stringifying content from cels that is different
    whether we're doing table header cels or table body cels.

  - we have a means of stringifying content from the cels in the `name`
    column that is different than our means for stringifying other cels.

a possible issue (and a #wish :[#459.H]):

the producer script under test may suffer from the #html2markdown problem.
we solved that same problem in #history-A.1 this commit for another producer
script by instead sourcing raw markdown, but from a moin moin wiki (our
source) we probably don't have that same luxury (i.e we don't expect that
moin moin magically uses github-flavored markdown for its markup format for
expressing tables). this all leans into a wish (not literally a wish) of a
moin moin format adapter, but we simply don't know/care at moment how
strongly we want to explore that avenue, or whether (alternately) to pursue
a heuristic sub-slice of #html2markdown or (finally) to just simply lose the
links..

(fortunately because of "field sovereignty" we may be able to defer finding
a solution to this possible problem (first mentioned in commit comment
at #history-A.1 minus three weeee).)
"""


from data_pipes_test.common_initial_state import html_fixture
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject)
import unittest


_CommonCase = unittest.TestCase


class Case1855DP_hello(_CommonCase):

    def test_100_loads(self):
        self.assertIsNotNone(_subject_module())

    def test_200_runs(self):
        self._shared_state()

    def test_300_new_in_this_thing_field_names_in_schema_record(self):
        _act = self._shared_state().seen_attribute_keys
        _exp = ('comment', 'grammar', 'module', 'name', 'python')
        self.assertSequenceEqual(_act, _exp)

    def test_400_url_with_tail_only_is_qualified(self):
        row = self._business_row(1)
        self.assertIn('wiki.python', row['name'])

    def test_410_full_url_are_left_alone(self):
        row = self._business_row(0)
        self.assertNotIn('wiki.python', row['name'])

    def test_420_dicts_are_sparse(self):
        row1 = self._business_row(0)
        row2 = self._business_row(1)

        names1 = [k for k in row1]
        names2 = [k for k in row2]

        self.assertIn('grammar', names2)
        self.assertNotIn('grammar', names1)

    def _business_row(self, offset):
        return self._shared_state().business_objects[offset]

    def test_500_emits_one_thing(self):
        """emits one thing - #fragile"""

        one, = self._shared_state().emissions
        _exp = ('info', 'expression', 'reading_from_filesystem')
        self.assertSequenceEqual(one.channel, _exp)

    @shared_subject
    def _shared_state(self):

        seen_attribute_keys = {}
        entity_dcts = []
        emissions = []

        import modality_agnostic.test_support.listener_via_expectations as lib

        # listener = lib.for_DEBUGGING (works)
        listener = lib.listener_via_emission_receiver(emissions.append)

        _ = _subject_module().open_traversal_stream(
                listener=listener,
                html_document_path=html_fixture('0130-tag-subtree.html'))

        with _ as dcts:
            for dct in dcts:
                for k in dct.keys():
                    seen_attribute_keys[k] = None
                entity_dcts.append(dct)

        # (we can't assine lvars to lvalues of the same name in a class)
        seen_attribute_keys_ = tuple(sorted(seen_attribute_keys.keys()))
        emissions_ = tuple(emissions)  # can't re-assign to same name inside

        class State:  # #class-as-namespace
            seen_attribute_keys = seen_attribute_keys_
            business_objects = tuple(entity_dcts)
            emissions = emissions_

        return State


def _subject_module():
    from script.producer_scripts import (
            script_180618_03_parser_generators_via_python_wiki as mod)
    return mod


if __name__ == '__main__':
    unittest.main()

# #history-A.1: the birth of our expression "field sovereignty" in comments
# #history-A.1: when we first started sourcing "raw" (remote, native) markdown
# #born.
