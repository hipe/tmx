from data_pipes_test.common_initial_state import html_fixture
from modality_agnostic.test_support.common import \
        dangerous_memoize as shared_subject
import unittest


class Case0810DP_khong(unittest.TestCase):
    # this exists only to assert that we don't break this complicated
    # production producer script

    def test_010_loads(self):
        self.assertIsNotNone(_subject_module())

    def test_020_three_sections(self):
        _act = len(self.end_state.sections)
        self.assertEqual(_act, 3)

    def test_030_this_many_objects_in_each_section(self):
        _act = [len(x.item_strings) for x in self.end_state.sections]
        self.assertSequenceEqual(_act, (3, 3, 3))

    def test_040_said_seen_N_of_same(self):
        emissions = self.end_state.emissions
        msg, = emissions[3].to_messages()
        exp = '(first was subset of second (3 were same))'
        self.assertEqual(msg, exp)

    @shared_subject
    def end_state(self):
        import modality_agnostic.test_support.common as em
        use_listener, emissions = em.listener_and_emissions_for(self, limit=None)

        sections = []

        def store_previous_initially():
            state.store_previous = store_previous_normally

        class state:  # #class-as-namespace
            store_previous = store_previous_initially

        def store_previous_normally():
            sections.append(section)

        class _Section:
            def __init__(self, s):
                self.item_strings = []
                self.header_content = s

        _cm = _subject_module().open_traversal_stream(
                listener=use_listener,
                html_document_path=html_fixture('0120-real-subtree.html'))
        with _cm as dcts:
            for dct in dcts:
                if 'header_level' in dct:
                    state.store_previous()
                    section = _Section(dct['header_content'])
                else:
                    section.item_strings.append(dct['text'])

        store_previous_normally()

        class _State:
            def __init__(self, em_tup, sect_tup):
                self.emissions = em_tup
                self.sections = sect_tup

        return _State(tuple(emissions), tuple(sections))

    do_debug = False


def _subject_module():
    import script.producer_scripts.script_180421_khong_lessons as x
    return x


if __name__ == '__main__':
    unittest.main()

# #born.
