from modality_agnostic.test_support.common import \
        dangerous_memoize as shared_subject
import unittest


# (history & description of "big index" buried at #history-B.7)


class CommonCase(unittest.TestCase):
    do_debug = False


# [Case1505-Case1610)


def higher_level_end_state(attr):  # #decorator
    def decorator(orig_f):
        def use_f(self):
            two_tup_plus = getattr(self, attr)
            return {k: v for k, v in two_tup_plus.to_node_tree_index_items()}
        return use_f
    return decorator


def fake_collection(orig_f):
    def use_f(tc):
        from pho_test.fake_collection import omg_fake_bcoll_via_lines as func
        return func(orig_f(tc))
    return shared_subject(use_f)


class Case1505_the_only_New_Way_case(CommonCase):

    def test_010_expanded_children_from_one(self):
        es = self.end_state_for_one
        pool = es.children_of  # SINFUL we are about to mutate a shared subject
        for parent_eid, cx_eids in self.expected_expanded_children():
            act = pool.pop(parent_eid)
            self.assertSequenceEqual(act, cx_eids)
        assert 0 == len(pool)

    def test_020_overall_depth_from_one(self):
        act = self.end_state_for_one.overall_depth
        assert 5 == act

    def test_030_this_document_depth_minmax_from_the_one(self):
        act = self.end_state_for_one.document_depth_minmax
        self.assertSequenceEqual(act, (1, 2))

    def expected_expanded_children(_):
        yield 'A', ('E', 'Gd')
        yield 'E', ('Hd', 'Jd')
        yield 'Hd', ('K',)
        yield 'Gd', ('P', 'Q')
        yield 'P', ('U', 'V')
        yield 'Q', ('W', 'X')
        yield 'X', ('Y',)

    def test_310_if_you_wanted_all_unaffiliated_trees(self):
        def condition(tree_index):
            return tree_index.document_depth_minmax is None
        act = self.trees_via_condition(condition)
        exp = 'B', 'F', 'L', 'N'
        self.assertSequenceEqual(act, exp)

    def test_320_if_you_wanted_all_unaffiliated_terminal_notecards(self):
        def condition(tree_index):
            yes1 = tree_index.document_depth_minmax is None
            yes2 = 1 == tree_index.overall_depth
            return yes1 and yes2
        act = self.trees_via_condition(condition)
        exp = 'F', 'L'
        self.assertSequenceEqual(act, exp)

    def test_330_if_you_wanted_all_document_trees(self):
        act = self.trees_via_condition(lambda ti: ti.document_depth_minmax)
        exp = '1d', 'A', 'M', 'Zd'
        self.assertSequenceEqual(act, exp)

    def test_340_each_document_tree_knows_the_range_of_depths_of_its_documents(self):  # noqa: E501
        this = self.end_state_for_all_higher_level
        o = {k: this[k].document_depth_minmax for k in ('1d', 'A', 'M', 'Zd')}
        self.assertSequenceEqual(o['1d'], (0, 0))
        self.assertSequenceEqual(o['Zd'], (0, 0))
        self.assertSequenceEqual(o['M'], (1, 1))
        self.assertSequenceEqual(o['A'], (1, 2))

    def trees_via_condition(self, test):
        this = self.end_state_for_all_higher_level
        return tuple(sorted(k for k, v in this.items() if test(v)))

    def test_610_PIECEMEAL(self):
        # The main thing here is that it worked (because it exercises a thing)
        built, cache = self.end_state_for_piecemeal
        act = tuple(sorted(built.keys()))
        self.assertSequenceEqual(act, ('E', 'Gd'))
        assert 12 == len(cache)

    @shared_subject
    def end_state_for_piecemeal(self):
        """As disvoered in the below endstate, we have to have the identifiers
        be *not* of the whole collection so we hit reassignment.
        """

        bcoll = self.fake_collection
        eids = 'Q', 'Gd', 'K', 'E'
        return subject_function_for_many()(eids, bcoll, None)

    @shared_subject
    @higher_level_end_state('end_state_for_all')
    def end_state_for_all_higher_level(self):
        pass

    @shared_subject
    def end_state_for_all(self):
        # Reverse the order of the EID's so you tend to get non-roots before
        # roots (longer explanation & justification buried at #history-B.7)
        bcoll = self.fake_collection
        eids = bcoll._coll.TO_EIDS_FOR_TEST()

        peek = tuple(reversed(eids))
        eids = iter(peek)
        return subject_function_for_many()(eids, bcoll, None)

    @shared_subject
    def end_state_for_one(self):
        ncs = self.fake_collection
        itr = subject_function_for_one()('A', ncs, None)
        func = subject_module().higher_level_functions().tree_index_via
        return func('A', itr)

    @fake_collection
    def fake_collection(_):
        yield r"                  A               "
        yield r"     B           / \              "
        yield r"    / \         /   \      Zd     "
        yield r"   C   D       /     E            "
        yield r"              /     / \           "
        yield r"     F       Gd    Hd  Jd         "
        yield r"            / \    |              "
        yield r"           /   \   K   L   M      "
        yield r"    N     /     \         / \     "
        yield r"   /     P       Q       Rd  Sd   "
        yield r"  T     / \     / \               "
        yield r"       U   V   W   X              "
        yield r"                    \             "
        yield r"                     Y    1d      "


class Case1515_NEW_WAY(CommonCase):

    def test_010_yes_fam(self):
        bcoll = self.fake_collection
        wow = bcoll.build_big_index_()
        hey = {k: v for k, v in wow.to_node_tree_index_items()}
        key, = hey.keys()
        assert 'INDEXd' == key
        ti = hey['INDEXd']
        assert (0, 2) == ti.document_depth_minmax

    @fake_collection
    def fake_collection(_):
        yield r"      INDEXd     "
        yield r"     /  |   \     "
        yield r"    /   |    \     "
        yield r" ABOUTd |     \     "
        yield r"        |      \      "
        yield r"       BOOKSd  TOOLSd "
        yield r"              /|\  \  "
        yield r"             / | \  \  "
        yield r"           Ed  F Gd  H  "


def subject_function_for_many():
    func = subject_module().big_index_for_many
    return func


def subject_function_for_one():
    func = subject_module().big_index_for_one
    return func


def subject_module():
    import pho.notecards_.big_index_via_collection as module
    return module


def xx(*aa):
    leng = len(aa)
    if 0 == leng:
        msg = None
    elif 1 == leng:
        msg, = aa
    else:
        msg = repr(aa)
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))


if __name__ == '__main__':
    unittest.main()

# #history-B.7 sunset hand-made ersatz blinker and long doc
# #history-B.6
# #history-B.5 insert/spike for new big index via hierarchical container type
# #history-B.4
# #history-A.1
# #born.
