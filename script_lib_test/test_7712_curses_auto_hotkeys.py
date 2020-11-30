# from modality_agnostic.test_support.common import lazy
# dangerous_memoize_in_child_classes as shared_subject_in_children, \
import unittest


class CommonCase(unittest.TestCase):
    pass


class Case7706_move_down_and_toggle_checkbox(CommonCase):

    def test_020_long_story(self):
        aca = ACA_via(ACA_def_one())
        cca = concretize(11, 27, aca)
        ic = cca.to_EXPERIMENTAL_input_controller()

        # In intial state
        row = buttons_top_row(cca)

        # The buttons should look like this now (blank)
        self.assertEqual(row, '                           ')

        # Press this button
        resp = ic.receive_keypress('KEY_DOWN')
        resp = ic.apply_changes(resp.changes)
        act = tuple(resp.changed_visually)

        # Three components should have changed
        self.assertSequenceEqual(act, ('nav_area', 'be_verbose', 'buttons'))
        act = buttons_top_row(cca)

        # The buttons should look like this now
        self.assertEqual(act, '     [enter] to toggle     ')

        # Press this button (to toggle the checkbox)
        resp = ic.receive_keypress('\n')

        # Process the arbitrary component state change
        resp = ic.apply_changes(resp.changes)
        act = tuple(resp.changed_visually)

        # One component should have changed
        self.assertSequenceEqual(act, ('be_verbose',))


def buttons_top_row(cca):
    r1, _, = tuple(cca.HARNESS_AT('buttons').to_rows())  # ..
    return r1


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


if __name__ == '__main__':
    unittest.main()

# #born
