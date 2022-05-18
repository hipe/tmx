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
        coll = collection(self.recfile, 'Capability')
        listener, emis = listener_and_emissions_for(self)
        param_direcs = self.given_parameter_directives
        if self.given_IS_DRY:
            use_opts = {'is_dry': True}
        else:
            use_opts = {}
        EID = self.given_EID
        res = coll.update_entity(EID, param_direcs, listener, **use_opts)
        return (res, tuple(emis))

    # Set-up for invocation

    @property
    def recfile(self):
        return the_main_main_recfile()

    given_IS_DRY = False
    do_debug = True


class Case2932_not_found_AND_strange_params(CommonCase):

    def test_010_fails(self):
        assert self.end_state_result is None

    def test_020_expresses_special_emission(self):
        emi = self.first_end_state_emission_of_category('unrecognized_or_malformed_parameters')
        line, = emi[-1]
        assert "parameter(s) unrecognized: ('onez', 'threez')" == line

    @property
    def given_parameter_directives(_):
        return {'onez': ('no_see',), 'threez': ('no_see',)}

    given_EID = 'QQ'
    do_debug = True


class Case2934_entity_not_found_BUT_good_params(CommonCase):

    def test_010_fails(self):
        assert self.end_state_result is None

    def test_020_expresses_special_emission(self):
        emi = self.first_end_state_emission_of_category('integrity_error')
        line, = emi[-1]
        assert "expecting one had none from Capability {'EID': 'QQ'}" == line

    @property
    def given_parameter_directives(_):
        return {'implementation_status': ('CREATE_ATTRIBUTE', 'new impl status')}

    given_EID = 'QQ'


class Case2938_these_directive_preconditions_not_met(CommonCase):

    def test_010_fails(self):
        assert self.end_state_result is None

    def test_020_errors_about_fields_have_field_name_in_channel(self):
        emi = self.first_end_state_emission_of_category('unrecognized_or_malformed_parameters')
        line1, line2 = emi[-1]
        assert 'native URL' in line1
        assert "must already be set but wasn't" in line1
        assert 'implementation status' in line2
        assert 'cannot delete because not currently set' in line2

    @property
    def given_parameter_directives(_):
        return {
            'native_URL': ('UPDATE_ATTRIBUTE', 'old value', 'new URL value'),
            'implementation_status': ('DELETE_EXISTING_ATTRIBUTE',),
        }

    given_EID = 'AA'


class Case2942_lets_go(CommonCase):
    """(we tested this visually then set it to dry. es muss sein)"""

    def test_010_succeeds(self):
        res = self.end_state_result
        assert res is True

    def test_020_these_kinds_of_emissions(self):
        counts = {}
        for emi in self.end_state_emissions:
            cat = emi[2]
            if cat not in counts:
                counts[cat] = 0
            counts[cat] += 1
        assert counts.pop('recutils_command') == 3  # sad but necessary
        assert counts.pop('caution_thrown_to_wind') == 2  # for now
        assert not counts

    @property
    def given_parameter_directives(_):
        return {
            'native_URL': ('UPDATE_ATTRIBUTE', 'existing://val', 'new URL value'),
            'implementation_status': ('DELETE_EXISTING_ATTRIBUTE',),
        }

    given_EID = 'MM'
    given_IS_DRY = True


# == Support

def collection(main_recfile, formal_entity_name):
    return lazy_collections(main_recfile)[formal_entity_name]


def lazy_collections(main_recfile):
    def dataclasserer(collections):
        return build_datamodel(collections).__getitem__  # EXPERIMENTAL

    def renames(fent_name):
        if 'Capability' == fent_name:
            return ('NativeCapability', {'EID': 'ID', 'children_EIDs': 'Child'})

    func = subject_module().LAZY_COLLECTIONS
    return func(main_recfile, 'Capability', dataclasserer, renames)


def build_datamodel(collections):
    from dataclasses import dataclass

    @dataclass
    class Capability:
        label: str
        EID: str
        implementation_status: str = None
        native_URL: str = None
        children_EIDs: tuple = ()

    return {'Capability': Capability}


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
