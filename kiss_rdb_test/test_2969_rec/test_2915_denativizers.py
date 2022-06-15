"""Nominally this test module covers "deantivizers" because that was the
rubric and over-arching umbrella of this last leg of effort. But as it works
out, this is also the introductory test module for several other key
architectural points:

- "lazy collections" (each collection (one per record type)) auto-vivified lazily
- something resembling LEFT_JOINs - as it turns out we didn't need the
  recsel facility for this yet
- `abstract_schema_via_dataclass` has a dedicated file, but this works it
"""

from modality_agnostic.test_support.common import \
        listener_and_emissions_simplified_for as listener_and_emissions_for, \
        dangerous_memoize_in_child_classes as shared_subject_in_child_classes
from unittest import TestCase as unittest_TestCase, main as unittest_main


class CommonCase(unittest_TestCase):

    def expect_failure(self, needle):
        ent, emissions = self.do_retrieve_capability()
        assert not ent

    @property
    @shared_subject_in_child_classes
    def notes(self):
        listener, emissions = listener_and_emissions_for(self)
        res = tuple(self.capability.retrieve_notes(listener))
        assert not next((emi for emi in emissions if 'info' != emi[0]), None)
        return res

    @property
    def capability(self):
        ent, emissions = self.do_retrieve_capability()
        assert not next((emi for emi in emissions if 'info' != emi[0]), None)
        assert ent
        return ent

    def do_retrieve_capability(self):
        listener, emissions = listener_and_emissions_for(self)
        ent = self.collection.retrieve_entity(self.EID, listener)
        return ent, emissions

    @property
    def collection(self):
        return collection(self.recfile, self.fent_name)

    @property
    def recfile(self):
        from os.path import dirname as dn, join
        top_test_dir = dn(dn(__file__))
        return join(
            top_test_dir,
            'fixture-directories', '2969-rec', '0175-enter-join.rec')

    fent_name = 'Capability'
    EID = 'AA'
    do_debug = False


class Case2914_no_file(CommonCase):

    def test_010_fails_softly(self):
        ent, emis = self.do_retrieve_capability()
        assert not ent
        err_lines = (emi[-1][0] for emi in emis if emi[0] == 'error')
        _1st_err_line = next(err_lines, None)
        assert "recsel: error: cannot read file " in _1st_err_line

    fent_name = 'HasNoFile'


class Case2916_no_entity(CommonCase):

    def test_010_fails_softly(self):
        exp = "expecting one had none from Capability {'EID': 'ZZ'}"
        self.expect_failure(exp)

    EID = 'ZZ'


class Case2918_main(CommonCase):

    def test_010_retrieves_all_the_notes(self):
        assert 2 == len(self.notes)

    def test_020_map_attribute_names_to_something_more_locally_suitable(self):
        lines = self.note.body_lines  # `body_lines` here, `body` in storage
        assert len(lines) in range(3, 5)
        assert isinstance(lines[0], str)
        assert '\n' == lines[0][-1]

    def test_030_converts_from_string_to_platform_type_in_some_cases(self):
        x = self.note.ordinal
        assert isinstance(x, int)

    def test_040_used_vendor_option_to_sort(self):
        act = tuple(note.ordinal for note in self.notes)
        self.assertSequenceEqual(act, (0, 1))

    @property
    def note(self):
        return self.notes[-1]


# == BEGIN

def collection(main_recfile, formal_entity_name):
    return lazy_collections(main_recfile)[formal_entity_name]


def lazy_collections(main_recfile):
    def bridger(collections):
        return build_datamodel_bridge(collections)  # EXPERIMENTAL

    def renames(fent_name):
        if 'Capability' == fent_name:
            return ('NativeCapability', {'EID': 'ID', 'children_EIDs': 'Child'})
        if 'Note' == fent_name:
            return (None, {'body_lines': 'Body'})

    func = subject_module().LAZY_COLLECTIONS
    return func(main_recfile, 'Capability', bridger, renames)


def build_datamodel_bridge(collections):
    from dataclasses import dataclass

    @dataclass
    class Capability:
        label: str
        EID: str
        native_URL: str = None
        children_EIDs: tuple = ()

        def retrieve_notes(self, listener):
            return collections['Note'].where(
                {'parent': self.EID}, order_by='ordinal', listener=listener)

    @dataclass
    class Note:
        parent: str
        ordinal: int
        body_lines: tuple[str]

    @dataclass
    class HasNoFile:
        thing: str

    return {'Capability': Capability, 'Note': Note, 'HasNoFile': HasNoFile}
    # behavior is undefined if you don't match the names

# == END


def subject_module():
    import kiss_rdb.storage_adapters_.rec as mod
    return mod


if __name__ == '__main__':
    unittest_main()

# #born
