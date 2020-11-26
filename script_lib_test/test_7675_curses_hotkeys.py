from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subject_in_children
import unittest


class CommonCase(unittest.TestCase):

    def do_this_crazy_wordwrap_test(self):
        aha = self.abstract_area
        w = aha.minimum_width
        h = aha.minimum_height_via_width(w)
        return h

    @property
    @shared_subject_in_children
    def concrete_area(self):
        h, w = self.given_concrete_area_dimensions()
        aa = self.abstract_area

        act_h = aa.minimum_height_via_width(w)  # write to the cache ugh
        assert h == act_h

        return aa.concretize_via_available_height_and_width(h, w)

    @property
    @shared_subject_in_children
    def abstract_area(self):
        x = self.given_hotkeys_definition()
        return build_abstract_hotkeys_area(x)


class Case7667_simple_intro(CommonCase):

    def test_025_loads(self):
        assert subject_module()

    def test_050_builds(self):
        assert self.abstract_area.hello_I_am_AHA()

    def test_100_does_crazy_wordwrap_thing(self):
        min_h = self.do_this_crazy_wordwrap_test()
        self.assertEqual(min_h, 2)

    def given_hotkeys_definition(_):
        def buttons():
            yield 'foo [b]ar', 'b[i]ff'

        yield 'page_of_buttons', 'x1', buttons


class Case7671_lets_try_changing_pages(CommonCase):

    def test_050_builds(self):
        assert self.abstract_area.hello_I_am_AHA()

    def test_100_does_crazy_wordwrap_thing(self):
        min_h = self.do_this_crazy_wordwrap_test()
        self.assertEqual(min_h, 3)

    def test_125_concrete_area_builds(self):
        assert self.concrete_area.hello_I_am_CHA()

    def test_150_blank_dynamic_area_is_blank(self):
        ca = self.concrete_area
        ca.set_active_page_to_none()
        act = tuple(ca.to_rows())
        exp = (
            '                    ',
            '                    ',
            '                    ')
        self.assertSequenceEqual(act, exp)

    def test_175_LETS_GO(self):
        ca = self.concrete_area
        ca.set_active_page('page_for_strength_training_mode')
        act = tuple(ca.to_rows())
        exp = (
            '  [c]hin/pull-ups   ',
            '[h]andstand push-ups',
            '  [d]ips [t]oggle   ',
        )
        self.assertSequenceEqual(act, exp)

    def test_200_gravity_pulls_downward(self):
        ca = self.concrete_area
        ca.set_active_page('page_for_endurance_training_mode')
        act = tuple(ca.to_rows())
        exp = (
            '                    ',
            '                    ',
            '      [t]oggle      ',
        )
        self.assertSequenceEqual(act, exp)

    def given_concrete_area_dimensions(_):
        w = len('[h]andstand push-ups')
        h = 3
        return h, w

    def given_hotkeys_definition(_):

        def buttons():
            yield '[c]hin/pull-ups', '[h]andstand push-ups'
            yield '[d]ips', '[t]oggle'

        yield 'page_of_buttons', 'page_for_strength_training_mode', buttons

        def buttons():
            # meh, when you're in running mode you're just running
            yield ('[t]oggle',)

        yield 'page_of_buttons', 'page_for_endurance_training_mode', buttons


class Case7675_introduce_static_area(CommonCase):

    def test_050_builds(self):
        assert self.abstract_area.hello_I_am_AHA()

    def test_100_does_crazy_wordwrap_thing(self):
        min_h = self.do_this_crazy_wordwrap_test()
        self.assertEqual(min_h, 4)

    def test_125_concrete_area_builds(self):
        assert self.concrete_area.hello_I_am_CHA()

    def test_250_lets_go(self):
        ca = self.concrete_area
        ca.set_active_page('page_one')
        act = tuple(ca.to_rows())
        exp = (
            'button [o]ne',
            'button [t]wo',
            '   [s]end   ',
            '   [d]one   ',
        )
        self.assertSequenceEqual(act, exp)

    def given_concrete_area_dimensions(self):
        return 4, len('button [o]ne')

    def given_hotkeys_definition(_):

        def buttons():
            yield 'button [o]ne', 'button [t]wo'

        yield 'page_of_buttons', 'page_one', buttons

        def buttons():
            yield '[s]end', '[d]one'

        yield 'static_buttons_area', buttons


def build_ACA(x):
    return support_lib().function_for_building_abstract_compound_areas()(x)


def support_lib():
    from script_lib_test import curses_yikes_support as module
    return module


def build_abstract_hotkeys_area(x):
    return subject_module().abstract_hotkeys_area_via(x)


def subject_module():
    from script_lib.curses_yikes import hotkey_via_character_and_label as mod
    return mod


if __name__ == '__main__':
    unittest.main()

# #born
