from modality_agnostic.test_support.common import \
        listener_and_emissions_simplified_for as listener_and_emissions_for, \
        dangerous_memoize_in_child_classes as shared_subject_in_child_classes, \
        lazy
from unittest import TestCase as unittest_TestCase, main as unittest_main


class CommonCase(unittest_TestCase):

    # == Used in tests

    def first_end_state_emission_of_category(self, cat):
        for emi in self.all_end_state_emissions_of_category(cat):
            return emi
        n = len(self.end_state_emissions)
        self.fail("did not find emission of type {cat!r} in {n} emission(s)!")

    def all_end_state_emissions_of_category(self, cat):
        for emi in self.end_state_emissions:
            if cat == emi[2]:
                yield emi

    @property
    def end_state_emissions(self):
        return self.end_state[1]

    @property
    def end_state_result(self):
        return self.end_state[0]

    @property
    @shared_subject_in_child_classes
    def end_state(self):
        coll = collection(self.recfile, 'Note')
        listener, emis = listener_and_emissions_for(self)
        params = self.given_parameters
        if (dct := self.given_additional_options):
            use_opts = dct
        else:
            use_opts = {}
        res = coll.create_entity(params, listener, **use_opts)
        return (res, tuple(emis))

    # Set-up for invocation

    @property
    def recfile(self):
        return the_main_main_recfile()

    @property
    def given_additional_options(_):
        pass

    do_debug = False


class Case2920_extra(CommonCase):

    def test_010_fails(self):
        assert self.end_state_result is None

    def test_020_expresses_special_emission(self):
        emi = self.first_end_state_emission_of_category(
                'unrecognized_or_malformed_parameters')
        line, = emi[-1]
        assert "parameter(s) unrecognized: ('one', 'three')" == line

    @property
    def given_parameters(_):
        return {'one': 'two', 'three': 'four'}


class Case2922_missing(CommonCase):

    def test_010_fails(self):
        assert self.end_state_result is None

    def test_020_errors_about_fields_have_field_name_in_channel(self):
        emis = tuple(self.all_end_state_emissions_of_category('error_about_field'))
        fields = []
        lines = []
        for emi in emis:
            fields.append(emi[3])
            lines.append(emi[-1][0])
        assert 2 == len(emis)
        self.assertSequenceEqual(('parent_EID', 'body_lines'), fields)
        # NOTE we use the names from storage because friendlier yikes
        assert 'parent is required.' == lines[0]
        assert 'body is required.' == lines[1]

    @property
    def given_parameters(_):
        return {}


class Case2924_ok(CommonCase):

    def test_010_result_is_sanitized_params_FOR_NOW(self):
        dct = self.end_state_result
        act = tuple(dct.keys())
        self.assertSequenceEqual(('parent_EID', 'ordinal', 'body_lines'), act)
        assert 332211 == dct['ordinal']

    def test_020_because_it_was_dry_it_wrote_to_STDOUT(self):
        emi = self.first_end_state_emission_of_category('would_have_written_these_lines')
        exp = ('%', '\n', 'P', 'O', 'B', '+')
        act = tuple(line[0] for line in emi[-1])
        self.assertSequenceEqual(exp, act)

    @property
    def given_parameters(_):
        return {
            'body_lines': "HELLO line 1\nHELLO line 2\n",
            'parent_EID': "Not Valid EID meh",
        }

    @property
    def given_additional_options(_):
        return {'is_dry': True}
        # (NOTE you can change is_dry to False to visually test the write!)
        # (but it will fail that one test)


# == Support

def collection(main_recfile, formal_entity_name):
    return lazy_collections(main_recfile)[formal_entity_name]


def lazy_collections(main_recfile):
    def dataclasserer(collections):
        return build_datamodel(collections).__getitem__  # EXPERIMENTAL

    def renames(fent_name):
        if 'Note' == fent_name:
            return (None, {'body_lines': 'Body', 'parent_EID': 'Parent'})

    func = subject_module().LAZY_COLLECTIONS
    return func(main_recfile, 'Capability', dataclasserer, renames)


def build_datamodel(collections):
    from dataclasses import dataclass

    def _derive_next_ordinal(colz, listener):
        # Will do it live!
        return 332211

    @dataclass
    class Note:
        parent_EID: str
        ordinal: int
        body_lines: tuple[str]

        VALUE_FACTORIES = {'ordinal': _derive_next_ordinal}

    return {'Note': Note}


# == END

@lazy
def the_main_main_recfile():
    from os.path import dirname as dn, join
    top_test_dir = dn(dn(__file__))
    return join(
        top_test_dir,
        'fixture-directories', '2969-rec', '0175-enter-join.rec')


def subject_module():
    import kiss_rdb.storage_adapters_.rec as mod
    return mod


if __name__ == '__main__':
    unittest_main()

# #born
