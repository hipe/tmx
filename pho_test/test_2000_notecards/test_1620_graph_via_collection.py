from pho_test.common_initial_state import big_index_one
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
        big_index = bcoll.build_big_index_NEW_(listener)
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


class Case1620_MONO_CASE(CommonCase):

    def test_100_lines_are_okay_probably(self):
        lines, _, _ = self.custom_end_state
        self.assertEqual(lines[0].index('digraph g {'), 0)
        self.assertIn(len(lines), range(16, 30))

    def test_150_lines_are_NOT_newline_terminated(self):
        lines, _, _ = self.custom_end_state
        self.assertEqual(lines[0], 'digraph g {')
        self.assertEqual(lines[-1], '}')

    def test_200_emits_a_summary(self):
        _, payloader_BE_CAREFUL_HOT, chan = self.custom_end_state
        self.assertSequenceEqual(chan, ('info', 'structure', 'summary'))
        sct = payloader_BE_CAREFUL_HOT()
        import re
        md = re.match(
                r'^graph reflects relationships among (\d+) notecards\.$',
                sct['message'])
        self.assertIn(int(md[1]), range(6, 10))

    @shared_subject
    def custom_end_state(self):
        output_lines_via_big_index = subject_function_for_GraphViz()

        def run(listener):
            bi = big_index_one()
            _itr = output_lines_via_big_index(bi, listener)
            return tuple(_itr)  # you have to do it in here to reach the emits

        import modality_agnostic.test_support.common as em
        listener, emissions = em.listener_and_emissions_for(self, limit=1)

        lines = run(listener)
        emi, = emissions

        if self.do_debug:
            assert isinstance(lines, tuple)
            print('WOWZAA:')
            print('\n'.join(lines))

        return lines, emi.payloader, emi.channel

    do_debug = False


def subject_function_for_GraphViz():
    return subject_module().output_lines_via_big_index_


def subject_function_for_ASCII():
    return subject_module().tree_ASCII_art_lines_via


def subject_module():
    import pho.notecards_.graph_via_collection as module
    return module


if __name__ == '__main__':
    unittest.main()

# #born.
