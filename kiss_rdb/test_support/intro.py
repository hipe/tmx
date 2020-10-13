from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subj_in_child_classses, \
        debugging_listener
from collections import namedtuple as _nt


class CommonestCase:

    # == This One (assertions, performance)

    def expect_expected_schema_field_name_keys(self):
        act_tup = self.end_state_schema_end_entities().schema.field_name_keys
        exp_tup = self.expected_field_name_keys()
        self.assertSequenceEqual(act_tup, exp_tup)

    def expect_expected_entities_given_lines(self):
        act_ents = self.end_state_schema_end_entities().entity_STREAM

        # Prepare the expectation for assertion
        exp_ents = (_JustEnoughEntity(d) for d in self.expected_entities())
        scnlib = _scnlib()
        act_scn = scnlib.scanner_via_iterator(act_ents)
        exp_scn = scnlib.scanner_via_iterator(exp_ents)

        # Assert
        _my_assert_sequence_equal(self, act_scn, exp_scn)

    @shared_subj_in_child_classses
    def end_state_schema_end_entities(self):

        # Prepare the givens for the performance
        lsn = debugging_listener() if self.do_debug else None
        given_lines = self.given_lines()  # iterator, probably

        # Perform
        mod = self.given_module()
        schema, act_ents = mod.SCHEMA_AND_ENTITIES_VIA_LINES(given_lines, lsn)

        return _EndStateSchemaAndEntitySTREAM(schema, act_ents)

    # == This One (performance, assertion)

    def expect_expected_lines_given_entities(self):

        # Prepare the givens for the performance
        schema = _schema_via_sexp(self.given_schema())
        given_ents = (_JustEnoughEntity(d) for d in self.given_entities())

        # Perform
        mod = self.given_module()
        act_itr = mod.LINES_VIA_SCHEMA_AND_ENTITIES(schema, given_ents, None)

        # Prepare the expectation for assertion
        scnlib = _scnlib()
        act_scn = scnlib.scanner_via_iterator(act_itr)
        exp_scn = scnlib.scanner_via_iterator(self.expected_lines())

        # Assert
        _my_assert_sequence_equal(self, act_scn, exp_scn)

    do_debug = False


def _schema_via_sexp(sx):
    stack = list(reversed(sx))
    assert 'schema' == stack.pop()
    kwargs = {}
    while stack:
        k = stack.pop()
        kwargs[k] = stack.pop()
    return _Schema(**kwargs)


_EndStateSchemaAndEntitySTREAM = _nt('ES01', ('schema', 'entity_STREAM'))


_Schema = _nt('MinimalSchema', ('field_name_keys',))


class _JustEnoughEntity:

    def __init__(self, dct):
        self.core_attributes_dictionary_as_storage_adapter_entity = dct

    def __eq__(self, otr):
        od = otr.core_attributes_dictionary_as_storage_adapter_entity
        return self.core_attributes_dictionary_as_storage_adapter_entity == od


# == Low-level and likely to abstract

def _my_assert_sequence_equal(tc, act_scn, exp_scn):  # #[#612.2] assert sequen
    def fail(fmt, scn):
        tc.fail(fmt.format(item=repr(scn.peek)))

    act_started_empty = act_scn.empty
    exp_started_empty = exp_scn.empty

    while act_scn.more:
        if exp_scn.empty:
            if exp_started_empty:
                fmt = "Expected no output. Had {item}"
            else:
                fmt = "Extra item when expected output to end: {item}"
            fail(fmt, act_scn)
        act = act_scn.next()
        exp = exp_scn.next()

        # NOTE normally we put the expected on the right side (hotter args
        # to the left) but here we want to trip whatever custom logic we
        # have for "equals" (if any) in our (if any) mocked business objects
        tc.assertEqual(exp, act)

    if exp_scn.empty:
        return
    if act_started_empty:
        fmt = "Outputted nothing but was expecting {item}"
    else:
        fmt = "Expecting this at end of output: {item}"
    fail(fmt, exp_scn)


def _scnlib():
    from text_lib.magnetics import scanner_via as module
    return module

# #born
