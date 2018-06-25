"""
.:#coverpoint12: multi-axis coverage from this script-test:

  - cover the particular producer script (used for business) and
  - provide limited coverage to the HTML format adapter's particular
    adaption of [#410.J] record mapping.

we say "limited" because this particular exercise of record mapping is a
simpler case. we don't use typical inspiration features like field splitting
or field renaming. yet still our use of record mapping is justifed:

  - we have a means of stringifying content from cels that is different
    whether we're doing table header cels or table body cels.

  - we have a means of stringifying content from the cels in the `name`
    column that is different than our means for stringifying other cels.

a possible issue (and a #wish :[#410.P]):

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


from _init import (
        fixture_file_path,
        )
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        memoize,
        )
import unittest


_CommonCase = unittest.TestCase


class Case100_hello(_CommonCase):

    def test_100_loads(self):
        self.assertIsNotNone(_subject_module())

    def test_200_runs(self):
        self._shared_state()

    def test_300_new_in_this_thing_field_names_in_schema_record(self):
        # coverpoint [#708.2.2]
        _act = self._shared_state().head_dictionary['field_names']
        _exp = ('name', 'grammar', 'module', 'python', 'comment')
        self.assertSequenceEqual(_act, _exp)

    def test_400_url_with_tail_only_is_qualified(self):  # coverpt [#708.2.3]
        row = self._business_row(1)
        self.assertIn('wiki.python', row['name'])

    def test_410_full_url_are_left_alone(self):
        row = self._business_row(0)
        self.assertNotIn('wiki.python', row['name'])

    def test_420_dicts_are_sparse(self):  # coverpoint [#708.2.4]
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

        emissions = []

        import modality_agnostic.test_support.listener_via_expectations as lib

        # use_listener = lib.for_DEBUGGING (works)
        use_listener = lib.listener_via_emission_receiver(emissions.append)

        _eek = _subject_module().open_dictionary_stream(
                html_document_path=fixture_file_path('0130-tag-subtree.html'),
                listener=use_listener,
                )

        with _eek as dcts:
            head_dct = next(dcts)
            objs = [dct for dct in dcts]

        class _State:
            def __init__(self, _1, _2, _3):
                self.head_dictionary = _1
                self.business_objects = _2
                self.emissions = _3

        return _State(head_dct, tuple(objs), tuple(emissions))


@memoize
def _subject_module():
        import script.tag_lyfe.json_stream_via_python_wiki as x
        return x


if __name__ == '__main__':
    unittest.main()

# #history-A.1: the birth of our expression "field sovereignty" in comments
# #history-A.1: when we first started sourcing "raw" (remote, native) markdown
# #born.
