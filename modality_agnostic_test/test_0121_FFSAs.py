from modality_agnostic.test_support.common import lazy
import unittest


class CommonCase(unittest.TestCase):
    pass


class test_7685_intro(CommonCase):

    def test_010_loads(self):
        self.assertTrue(subject_module())

    def test_020_builds(self):
        ffsa = ffsa_one()
        assert ffsa.FFSA_key  # touch any arbitrary exposure of it


class test_7695_holy_smokes_merge(CommonCase):

    def test_010_FFSA_two_builds(self):
        assert ffsa_two()

    def test_020_holy_smokes(self):
        def gviz(ffsa):
            return tuple(ffsa.to_graph_viz_inner_lines_simplified())

        ffsa_left = ffsa_one()
        ffsa_right = ffsa_two()
        ffsa_merged = ffsa_left.HOLY_SMOKES_MERGE_FFSAs(ffsa_right)

        # Make sure FFSA One looks as we expect before
        act = gviz(ffsa_left)
        exp = tuple(self.expected_lines_before_one())
        self.assertSequenceEqual(act, exp)

        # Make sure FFSA Two looks as we expect before
        act = gviz(ffsa_right)
        exp = tuple(self.expected_lines_before_two())
        self.assertSequenceEqual(act, exp)

        # Money Money Money
        act = gviz(ffsa_merged)
        exp = tuple(self.expected_lines_after_merge())
        self.assertSequenceEqual(act, exp)

    def expected_lines_after_merge(_):
        yield 'state_one->state_four[label="transition zero"]\n'
        yield 'state_one->state_two[label="transition one"]\n'
        yield 'state_one->state_three[label="transition [t]wo"]\n'
        yield 'state_zero->state_one[label="transo whatever"]\n'

    def expected_lines_before_two(_):
        yield 'state_zero->state_one[label="transo whatever"]\n'
        yield 'state_one->state_four[label="transition zero"]\n'

    def expected_lines_before_one(_):
        yield 'state_one->state_two[label="transition one"]\n'
        yield 'state_one->state_three[label="transition [t]wo"]\n'


def ffsa_via_def(orig_f):  # #decorator
    def use_f():
        return build_FFSA(orig_f)
    return use_f


@lazy
def ffsa_two():
    return build_FFSA(ffsa_two_def, where_to_insert=ffsa_two_WTI())


def ffsa_two_def():
    yield 'state_zero', 'transo whatever', 'state_one'
    yield 'state_one', 'transition zero', 'state_four'


def ffsa_two_WTI():
    yield 'state_one', 'transition zero', 'at_beginning'


@lazy
@ffsa_via_def
def ffsa_one():
    yield 'state_one', 'transition one', 'state_two'
    yield 'state_one', 'transition [t]wo', 'state_three'


def build_FFSA(defnf, **kw):
    return build_FFSA_via('pretendo.moduolo', defnf, **kw)


def build_FFSA_via(house_module_string, defnf, **kw):
    return subject_module().build_formal_FSA_via_definition_function_(
        house_module_string, defnf, **kw)


def subject_module():
    from script_lib.curses_yikes import _formal_state_machine_collection as mod
    return mod


if __name__ == '__main__':
    unittest.main()

# #born 2 weeks later
