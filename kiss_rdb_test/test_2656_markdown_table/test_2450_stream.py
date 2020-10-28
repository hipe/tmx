from kiss_rdb_test.markdown_storage_adapter import collection_via_real_path
from kiss_rdb_test.common_initial_state import functions_for
import modality_agnostic.test_support.common as em
from modality_agnostic.test_support.common import \
        dangerous_memoize as shared_subject
import unittest


fixture_path = functions_for('markdown').fixture_path


class CommonCase(unittest.TestCase):

    def build_state_expecting_some_emssions(self, path):
        listener, emissions = em.listener_and_emissions_for(self, limit=1)
        attr_dcts, k = self.my_run(path, listener)
        emi, = emissions
        return EndState(attr_dcts, k, ((emi.channel, emi.payloader),))

    def build_state_expecting_no_emissions(self, path):
        attr_dcts, k = self.my_run(path, failey_listener)
        return EndState(attr_dcts, k)

    def my_run(self, path, listener):
        coll = collection_via_real_path(path, listener)
        if coll is None:
            return (), None  # (Case2449)
        with coll.open_entity_traversal(listener) as ents:
            return _signature_via_ents(ents)

    do_debug = False


def _signature_via_ents(ents):
    if True:
        dcts, k = [], None
        for first_ent in ents:
            def p(ent):
                dct = ent.core_attributes_dictionary
                dct[k] = ent.nonblank_identifier_primitive  # ..
                return dct
            k = first_ent.identifier_key__
            dcts.append(p(first_ent))
            for ent in ents:
                dcts.append(p(ent))
        return tuple(dcts), k


class Case2449_fail(CommonCase):

    def test_200_fails(self):
        (chan, payloader), = self.end_state.emissions
        expected = ('error', 'structure', 'cannot_load_collection', 'file_has_no_extname')  # noqa: E501
        self.assertSequenceEqual(chan, expected)
        _reason = payloader()['reason']
        self.assertRegex(_reason, r'^cannot infer .+om file with no extension')

    @shared_subject
    def end_state(self):
        md = fixture_path('0080-no-extension')
        return self.build_state_expecting_some_emssions(md)


# Case2450  #midpoint


class Case2451_work(CommonCase):

    def test_200_runs(self):
        self.assertIsNotNone(self.end_state)

    def test_300_sparse_is_sparse(self):
        dcts = self.end_state.attribute_dictionaries
        self.assertIn('stamina', dcts[0])
        self.assertNotIn('stamina', dcts[1])

    def test_400_empty_values_dict_is_possible_but_identifiers_necessary(self):
        """(NOTE easy to change if you don't want to skip non-entities..)"""

        es = self.end_state
        dcts, k = es.attribute_dictionaries, es.identifier_key
        ks = tuple(dct[k] for dct in dcts)
        self.assertSequenceEqual(ks, ('x0', 'y0', 'z0'))

    @shared_subject
    def end_state(self):
        md = fixture_path('0115-stream-me.md')
        return self.build_state_expecting_no_emissions(md)


class EndState:
    def __init__(self, attribute_dcts, k, emissions=()):
        self.emissions = emissions
        self.attribute_dictionaries = attribute_dcts
        self.identifier_key = k


def failey_listener(*a):
    raise Exception('expecting no emissions')


if __name__ == '__main__':
    unittest.main()

# #born.
