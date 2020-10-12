class CommonestCase:

    # == Test Assertion Methods

    def output_lines_look_right(self):
        mod = self.given_module()
        exp = tuple(self.expected_lines())

        schema = _schema_via_sexp(self.given_schema())
        given_ents = (_JustEnoughEntity(d) for d in self.given_entities())

        itr = mod.LINES_VIA_SCHEMA_AND_ENTITIES(schema, given_ents, None)

        exp_stack = list(reversed(exp))
        itr = iter(itr)

        for act in itr:
            exp = exp_stack.pop()  # ..
            self.assertEqual(act, exp)

        assert not exp_stack


def _schema_via_sexp(sx):
    stack = list(reversed(sx))
    assert 'schema' == stack.pop()
    kwargs = {}
    while stack:
        k = stack.pop()
        kwargs[k] = stack.pop()
    return _Schema(**kwargs)


class _Schema:
    def __init__(self, field_name_keys):
        self.field_name_keys = field_name_keys


class _JustEnoughEntity:
    def __init__(self, dct):
        self.core_attributes_dictionary_as_storage_adapter_entity = dct

# #born
