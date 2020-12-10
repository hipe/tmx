from script_lib_test.curses_yikes_support import \
        expect_only_changed_visually, expect_only_changes, \
        buttons_top_row, input_controller_via_CCA
# from modality_agnostic.test_support.common import lazy
# dangerous_memoize_in_child_classes as shared_subject_in_children, \
import unittest


class CommonCase(unittest.TestCase):
    pass


class Case7706_move_down_and_toggle_checkbox(CommonCase):

    def test_020_long_story(self):
        aca = ACA_via(ACA_def_one())
        cca = concretize(11, 28, aca)
        ic = input_controller_via_CCA(cca)

        # In initial state
        row = buttons_top_row(cca)

        # The buttons should look like this now (blank)
        self.assertEqual(row, f'{not_sel}                         ')

        # Press this button
        resp = ic.receive_keypress('KEY_DOWN')
        changes = expect_only_changes(resp)
        resp = ic.apply_changes(changes)
        act = expect_only_changed_visually(resp)

        # Three components should have changed
        self.assertSequenceEqual(act, ('buttons', 'nav_area', 'be_verbose'))
        act = buttons_top_row(cca)

        # The buttons should look like this now
        self.assertEqual(act, f'{not_sel}  [enter] to toggle      ')

        # Press this button (to toggle the checkbox)
        resp = ic.receive_keypress('\n')

        # Process the arbitrary component state change
        changes = expect_only_changes(resp)
        resp = ic.apply_changes(changes)
        act = expect_only_changed_visually(resp)

        # One component should have changed
        self.assertSequenceEqual(act, ('be_verbose',))


def ACA_def_one():
    yield 'nav_area', ('fipple_fapple',)
    yield 'vertical_filler'
    yield 'checkbox', 'be_verbose', 'label', 'Whether to be verbose'
    yield 'buttons'


def concretize(h, w, aa, listener=None):
    return support_lib().concretize(h, w, aa, listener)


def ACA_via(x):
    func = support_lib().function_for_building_abstract_compound_areas()
    return func(x)


def support_lib():
    from script_lib_test import curses_yikes_support as module
    return module


def xx(msg=None):
    raise RuntimeError(''.join(('cover me', *((': ', msg) if msg else ()))))


not_sel = ' ' * 3  # ..


if __name__ == '__main__':
    unittest.main()

# #born
