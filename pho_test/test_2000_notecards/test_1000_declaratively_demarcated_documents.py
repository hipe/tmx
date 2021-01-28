from pho_test.common_initial_state import \
        read_only_business_collection_two as notecards_two
from modality_agnostic.test_support.common import \
        listener_and_emissions_for, \
        dangerous_memoize_in_child_classes as shared_subject_in_child_classes
import unittest


class CommonCase(unittest.TestCase):

    def expect_expected_sequence_of_nodes(self):
        yields, _ = self.end_state
        assert isinstance(yields, tuple)

        act_eids, act_depths = [], []
        for node, depth in yields:
            act_eids.append(node.identifier_string)
            act_depths.append(depth)

        exp_eids, exp_depths = [], []
        for eid, depth in self.expected_sequence_of_nodes():
            exp_eids.append(eid)
            exp_depths.append(depth)

        self.assertSequenceEqual(act_eids, exp_eids)
        self.assertSequenceEqual(act_depths, exp_depths)

    def expect_failed(self):
        yields, emis = self.end_state
        assert yields is None
        assert len(emis)
        assert 'error' == emis[-1].severity

    def expect_succeeded(self):
        yields, emis = self.end_state
        assert emis is None
        assert len(yields)

    @property
    def emissions(self):
        return self.end_state[1]

    @property
    @shared_subject_in_child_classes
    def end_state(self):
        yields, emis = self.perform()
        return yields, emis

    def perform(self):
        start_eid = self.given_start_node()
        listener, emis = listener_and_emissions_for(self)
        ncs = self.given_notecards_collection()
        nodes = nodes_in_order_via(start_eid, ncs, listener)
        return (nodes and tuple(nodes)), (tuple(emis) if emis else None)

    def given_notecards_collection(_):
        return notecards_two()

    do_debug = False


class Case0990_when_not_in_document(CommonCase):

    def test_100_expect_failed(self):
        self.expect_failed()

    def test_150_explains(self):
        emi, = self.emissions
        exp = 'error', 'expression', 'node_not_in_document'
        self.assertSequenceEqual(emi.channel, exp)

    def given_start_node(_):
        return 'CDF'


class Case0993_when_yes_document(CommonCase):

    def test_100_expect_succeeded(self):
        self.expect_succeeded()

    def test_150_expect_expected_sequence_of_nodes(self):
        self.expect_expected_sequence_of_nodes()

    def expected_sequence_of_nodes(self):
        n, m = 0, 1
        yield 'FGH', n
        yield 'CDE', n
        yield 'JKH', m  # (this part is central: children before next)
        yield 'JKG', m
        yield 'JKL', n  # (and this: pop out of children

    def given_start_node(_):
        return 'FGH'


def nodes_in_order_via(start_eid, coll, listener):
    from pho.notecards_.abstract_document_via_notecards import \
            document_notecards_in_order_via_any_arbitrary_start_node_ as func
    return func(start_eid, coll, listener)


if __name__ == '__main__':
    unittest.main()

# #pending-rename: this & many others: consider following asset file structure
# #born
