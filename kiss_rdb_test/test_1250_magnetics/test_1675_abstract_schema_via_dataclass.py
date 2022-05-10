from modality_agnostic.test_support.common import \
        dangerous_memoize as shared_subject
from unittest import TestCase as unittest_TestCase, main as unittest_main


def memoize_trueish_value(func):
    def use_func():
        if not func.value:
            func.value = func()
        return func.value
    func.value = None
    return use_func


@memoize_trueish_value
def schema_one():
    export = build_class_exporter()
    from dataclasses import dataclass

    @export
    @dataclass
    class Capability:
        label: str
        EID: str
        children: tuple[str]
        native_URL: str = None

    @export
    @dataclass
    class Note:
        parent: str
        ordinal: int
        body: tuple[str]

    return export.dictionary


class CommonCase(unittest_TestCase):
    pass


class Case1672_intro(CommonCase):

    def test_010_selftest_exporter_works(self):
        act = tuple(self.schema.keys())
        self.assertSequenceEqual(act, ('Capability', 'Note'))

    def test_020_the_name_of_the_abstract_one_is_the_same_FOR_NOW(self):
        assert self.abstract_entity.table_name == 'Note'

    def test_030_obvious_python_types_map_to_type_macros_unsurprisingly(self):
        absent = self.abstract_entity
        assert 'int' == absent['ordinal'].type_macro_string

    def test_040_a_tuple_of_a_string_does_this_EXPERIMENTALLY(self):
        absent = self.abstract_entity
        assert 'tuple[str]' == absent['body'].type_macro_string

    def test_050_EXPERIMENTALLY_requirednes_derives_from_defaultedness(self):
        absent = subject_function()(schema_one()['Capability'])
        assert absent['native_URL'].null_is_OK
        assert not absent['EID'].null_is_OK

    @shared_subject
    def abstract_entity(self):
        return subject_function()(schema_one()['Note'])

    @property
    def schema(self):
        return schema_one()


class build_class_exporter:
    def __init__(self):
        self.dictionary = {}

    def __call__(self, cls):
        k = cls.__name__
        assert k not in self.dictionary
        self.dictionary[k] = cls
        return cls


def subject_function():
    return subject_module().abstract_entity_via_dataclass


def subject_module():
    import kiss_rdb.magnetics_.abstract_schema_via_definition as mod
    return mod

if __name__ == '__main__':
    unittest_main()

# #born
