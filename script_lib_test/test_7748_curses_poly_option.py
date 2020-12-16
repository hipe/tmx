from script_lib_test.curses_yikes_support import \
        expect_only_changed_visually, \
        expect_only_changes, \
        start_long_story, \
        function_for_building_abstract_compound_areas as ACA_via_via
from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subject_in_children
import unittest


class CommonCase(unittest.TestCase):

    # == FROM #copy-pasted

    def screenshot_at(self, k):
        return self.screens[k]

    @property
    @shared_subject_in_children
    def screens(self):
        sp = self.given_startingpoint()
        spf = self.given_startingpoint_focus()
        if sp:
            if spf:
                sp.FOCUS_HACK(spf)
            args = (sp,)
        else:
            assert not spf
            args = ()
        return {k: v for k, v in self._each_screen(args)}

    def _each_screen(self, args):
        for k, v in self.given_performance(*args):
            if self.do_debug:
                v.DUMP(k.replace('_', ' '))
            yield k, v

    def given_startingpoint(_):
        pass

    def given_startingpoint_focus(_):
        pass

    # == TO

    do_debug = False


class Case7748_(CommonCase):

    def test_010_(self):
        self.screens

    def given_performance(self):
        o = start_long_story(self, h, w, ACA_one(), controller_key='zizzo')
        yield 'at_start', o.screenshot()

        # Key down once to focus the SAC label
        o.press_key('KEY_DOWN')
        yield 'focus_should_be_on_SAC', o.screenshot()

        # Enter to enter editing the SAC
        o.press_key('\n')
        o.expect_this_button_was_pressed('[enter] to edit')
        yield 'after_entered', o.screenshot()

        # Press key to add
        o.press_key('a')
        o.expect_this_button_was_pressed('[a]dd')

        # Yuck break up the compound patch
        changes = expect_only_changes(o.release_response())
        change1, change2 = changes

        # Expect first change is to add WIP row
        exp = 'child_component', 'zizzo', '_insert_WIP_row'
        self.assertSequenceEqual(change1[:3], exp)
        resp = o.apply_change(change1)

        # Applying this (does a lot and) leads to a focus change
        change, = expect_only_changes(resp)
        self.assertSequenceEqual(change[:2], ('input_controller', 'change_focus'))  # noqa: E501
        resp = o.apply_change(change)

        # Applying the patch to change focus changed these:
        cv = expect_only_changed_visually(resp)
        self.assertSequenceEqual(cv, ('buttons', 'zizzo'))  # bad

        # Expect the directive to draw the emacs field (we don't actually proc)
        direc, rest = o.expect_this_is_directive_to_draw_emacs_field(change2)
        exp = ('zizzo', 'item_1'), 1, 8, 2, 4
        self.assertSequenceEqual(direc, exp)
        self.assertSequenceEqual(rest, ('nn', 'item_1'))
        yield 'AFTER_PRESSED_ADD', o.screenshot()

        # Then enter text for NAME
        o.then_enter_text('wazoo')
        resp = o.apply_changes()
        yield 'AFTER_ENTERED_ONLY_NAME', o.screenshot()

        # Expect the directive to draw the emacs field THIS time for VALUE
        change, = expect_only_changes(resp)
        direc, rest = o.expect_this_is_directive_to_draw_emacs_field(change)
        exp = ('zizzo', 'item_1'), 1, 22, 2, 15
        self.assertSequenceEqual(direc, exp)
        self.assertSequenceEqual(rest, ('vv', 'item_1'))

        # Then enter text for VALUE, expect only changed visually
        o.then_enter_text('fazoo')
        act = expect_only_changed_visually(o.apply_changes())
        self.assertSequenceEqual(act, ('zizzo',))
        yield 'AFTER_ADD_ONE', o.screenshot()


def ACA_one(vals=None):
    return ACA_via_via()(ACA_def_one(), vals=vals)


def ACA_def_one():
    yield 'nav_area', ('enjoy_your', 'orderable_list')
    yield 'orderable_list', 'zizzo', 'item_class', 'poly_option'
    yield 'flash_area'
    yield 'buttons'


h, w = 9, 38


def xx(*_):
    raise RuntimeError('xx')


if __name__ == '__main__':
    unittest.main()

# #born
