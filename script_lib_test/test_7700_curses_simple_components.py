from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subject_in_children, \
        dangerous_memoize as shared_subject
import unittest


class CommonCase(unittest.TestCase):

    def concrete_expecting_success(self, h, w):
        listener, done = em_lib().listener_and_done_via((), self)
        aa = self.ACA
        res = aa.concretize_via_available_height_and_width(h, w, listener)
        done()
        return res

    @property
    @shared_subject_in_children
    def ACA(self):
        return ACA_via(self.given_ACA_def())

    do_debug = True


class CaseNNNN_xxx(CommonCase):

    def test_040_omg(self):
        assert self.ACA.hello_I_am_ACA()

    def test_060_ohai(self):
        assert self.this_thing.hello_I_am_CCA()

    def test_080_crazizzle(self):
        act = tuple(self.this_thing.to_rows())
        row1, row2, row3, row4, row5, row6 = act

        def assert_row(row, letter):
            assert 27 == len(row)
            assert all(letter == s for s in row)

        assert_row(row1, '~')
        assert_row(row2, 'F')
        assert_row(row3, 'C')
        assert_row(row4, 'F')
        assert_row(row5, ' ')
        assert_row(row6, ' ')

    @shared_subject
    def this_thing(self):
        return self.concrete_expecting_success(6, 27)

    def given_ACA_def(self):
        yield 'nav_area', ('fipple_fapple',)
        yield 'text_field', 'foo_fah'
        yield 'checkbox', 'be_verbose', 'label', 'Whether to be verbose'
        yield 'text_field', 'fiz_nizzle'
        yield 'vertical_filler'


def em_lib():
    import modality_agnostic.test_support.common as module
    return module


def ACA_via(x):
    func = support_lib().function_for_building_abstract_compound_areas()
    return func(x)


def support_lib():
    from script_lib_test import curses_yikes_support as module
    return module


if __name__ == '__main__':
    unittest.main()

# #born
