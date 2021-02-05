from modality_agnostic.test_support.common import \
        listener_and_emissions_for, \
        dangerous_memoize as shared_subject
import unittest


class CommonCase(unittest.TestCase):
    do_debug = True


class Case1610_ASCII_tree_intro(CommonCase):

    @shared_subject
    def end_state(self):
        listener, emissions = listener_and_emissions_for(self)
        bcoll = self.fake_collection
        big_index = bcoll.build_big_index_(listener)
        output_lines_via_big_index = subject_function_for_ASCII()
        olines = output_lines_via_big_index(big_index)
        return tuple(olines), tuple(emissions)

    @property
    def fake_collection(self):
        from pho_test.fake_collection import omg_fake_bcoll_via_lines as func
        return func(self.given_collection())

    CAN_BE_USED_BY_VISUAL_TEST = True
    COLLECTION_FOR_VISUAL_TEST = fake_collection

    def test_010_first_few_lines_look_OK(self):
        olines, emis = self.end_state
        exp = tuple(self.expected_first_few_lines())
        act = olines[:len(exp)]
        self.assertSequenceEqual(act, exp)

    def test_020_last_few_lines_look_OK(self):
        olines, emis = self.end_state
        exp = tuple(self.expected_last_few_lines())
        act = olines[-len(exp):]
        self.assertSequenceEqual(act, exp)

    def test_030_emits_nothing(self):
        olines, emis = self.end_state
        assert 0 == len(emis)  # oops we initially developed this test against

    def expected_first_few_lines(_):
        yield 'collection\n'
        yield '├──A "Hello I am the heading for \'A\'"\n'
        yield '|  ├──E "Hello I am the heading for \'E\'"\n'
        yield '|  |  ├──Hd [document] "Hello I am the heading for \'Hd\'"\n'
        yield '|  |  |  └──K "Hello I am the heading for \'K\'"\n'

    def expected_last_few_lines(_):
        yield '├──M "Hello I am the heading for \'M\'"\n'
        yield '|  ├──Rd [document] "Hello I am the heading for \'Rd\'"\n'
        yield '|  └──Sd [document] "Hello I am the heading for \'Sd\'"\n'
        yield '├──N "Hello I am the heading for \'N\'"\n'
        yield '|  └──T "Hello I am the heading for \'T\'"\n'
        yield '├──1d [document] "Hello I am the heading for \'1d\'"\n'
        yield '├──F "Hello I am the heading for \'F\'"\n'
        yield '├──L "Hello I am the heading for \'L\'"\n'
        yield '└──Zd [document] "Hello I am the heading for \'Zd\'"\n'

    def given_collection(_):  # (started as copy-paste of the other)
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


class Case1620_dotfile_intro(CommonCase):

    def test_100_lines_are_okay_probably(self):
        lines, _, _ = self.custom_end_state
        self.assertEqual(lines[0].index('digraph g {'), 0)
        self.assertIn(len(lines), range(24, 36))

    def test_150_lines_are_YES_newline_terminated(self):
        # (this changed in #history-B.4 from *not* to yes)
        lines, _, _ = self.custom_end_state
        self.assertEqual(lines[0], 'digraph g {\n')
        self.assertEqual(lines[-1], '}\n')

    def test_200_emits_a_summary(self):
        _, payloader_BE_CAREFUL_HOT, chan = self.custom_end_state
        self.assertSequenceEqual(chan, ('info', 'structure', 'summary'))
        sct = payloader_BE_CAREFUL_HOT()
        import re
        rx = re.compile(r"""
            ^graph[ ]reflects[ ](?P<num_nodes>\d+)[ ]node\(s\)[ ]
            in[ ](?P<num_trees>\d+)[ ]tree\(s\)\.?
        """, re.VERBOSE)
        act = sct['message']
        self.assertRegex(act, rx)
        md = rx.match(act)
        nn, nt = (int(md[k]) for k in 'num_nodes num_trees'.split())

        exp = 7, 8  # expect this to change soon-ish
        self.assertSequenceEqual((nt, nn), exp)

    @shared_subject
    def custom_end_state(self):
        # Prepare listener
        from modality_agnostic.test_support.common import \
            listener_and_emissions_for as func
        listener, emissions = func(self, limit=1)

        # Resolve business collection then big index
        bcoll = self.given_collection
        big_index = bcoll.build_big_index_(listener)

        # Perform
        output_lines_via_big_index = subject_function_for_GraphViz()
        lines = output_lines_via_big_index(big_index, listener)
        lines = tuple(lines)  # You have to do it to produce the emissions
        emi, = emissions

        if self.do_debug:
            assert isinstance(lines, tuple)
            print('WOWZAA:')
            print('\n'.join(lines))

        return lines, emi.payloader, emi.channel

    @property
    def given_collection(self):
        from pho_test.common_initial_state import \
            read_only_business_collection_one as func
        return func()

    CAN_BE_USED_BY_VISUAL_TEST = True
    COLLECTION_FOR_VISUAL_TEST = given_collection

    do_debug = False


def subject_function_for_GraphViz():
    return subject_module().graphviz_dotfile_lines_via_


def subject_function_for_ASCII():
    return subject_module().tree_ASCII_art_lines_via


def subject_module():
    import pho.notecards_.graph_via_collection as module
    return module


if __name__ == '__main__':
    unittest.main()

# #history-B.4 change dotfile tests to cover big index new way
# #born.
