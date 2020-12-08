from script_lib_test.curses_yikes_support import \
        start_long_story, \
        concretize, \
        function_for_building_abstract_compound_areas as ACA_via_via
from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subject_in_children
import unittest


class LowLevelCase(unittest.TestCase):

    def given_insert(self, item_offset, item_value):
        cx = {k: v for k, v in self._cx_via_given()}
        func = self.subject_function()
        func(cx, item_offset, item_value)
        self.result_children = cx

    def given_delete(self, item_value):
        cx = {k: v for k, v in self._cx_via_given()}
        _, * value_keys = cx.keys()  # #here1
        arg_key = next(k for k in value_keys if item_value == cx[k])
        func = self.subject_function()
        func(cx, arg_key)
        self.result_children = cx

    def expect(self, *exp_values):
        cx = self.result_children
        del self.result_children

        # Assert that the result keys have contiguous names in the right order
        these_keys = tuple(f"item_{i}" for i in range(1, len(cx)))
        exp_keys = 'qq_row', * these_keys
        act_keys = tuple(cx.keys())
        self.assertSequenceEqual(act_keys, exp_keys)

        # Assert the item values
        act_values = tuple(cx[k] for k in these_keys)
        self.assertSequenceEqual(act_values, exp_values)

    def _cx_via_given(self):
        tup = self.given
        yield 'qq_row', None
        count = 0
        for item_value in tup:
            count += 1
            yield f"item_{count}", item_value


class Case7728_low_level_delete(LowLevelCase):

    def test_010_delete_from_end(self):
        self.given = 'A', 'B', 'C'
        self.given_delete('C')
        self.expect('A', 'B')

    def test_020_delete_from_middle(self):
        self.given = 'A', 'B', 'C'
        self.given_delete('B')
        self.expect('A', 'C')

    def test_030_delete_from_beginning(self):
        self.given = 'A', 'B', 'C'
        self.given_delete('A')
        self.expect('B', 'C')

    def test_060_delete_resulting_in_empty_list(self):
        self.given = ('A',)
        self.given_delete('A')
        self.expect()

    def subject_function(_):
        from script_lib.curses_yikes._orderable_list import \
            _delete_from_dictionary_shifting_keys as func
        return func


class Case7730_low_level_insert(LowLevelCase):

    def test_010_insert_into_empty(self):
        self.given = ()
        self.given_insert(0, 'A')
        self.expect('A')

    def test_020_insert_after_one(self):
        self.given = ('A',)
        self.given_insert(1, 'B')
        self.expect('A', 'B')

    def test_030_insert_before_one(self):
        self.given = ('B',)
        self.given_insert(0, 'A')
        self.expect('A', 'B')

    def test_060_insert_in_between(self):
        self.given = 'A', 'C'
        self.given_insert(1, 'B')
        self.expect('A', 'B', 'C')

    def subject_function(_):
        from script_lib.curses_yikes._orderable_list import \
            _insert_into_dictionary_shifting_keys as func
        return func


class CommonCase(unittest.TestCase):

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

    do_debug = False


class Case7732_gain_and_lose_focus_no_entry(CommonCase):

    def test_010_ACA_builds(self):
        assert ACA_two()

    def test_020_CA_builds(self):
        assert concretize(h, w, ACA_two())

    def test_030_from_start_SAC_is_selected_becaues_it_top(self):
        s = self.screenshot_at('at_start')
        o = s.classified_row_with_focus
        assert o.looks_like_nav_area

    def test_040_focus_looks_right_after_key_down(self):
        s = self.screenshot_at('focus_looks_right')
        o = s.classified_row_at(1)
        assert o.looks_like_label_row
        assert o.has_focus

    def test_050_focus_goes_back_up_to_orig(self):
        s = self.screenshot_at('focus_goes_back_to_orig')
        o = s.classified_row_at(0)
        assert o.looks_like_nav_area
        assert o.has_focus

    def given_performance(self):
        o = start_long_story(self, h, w, ACA_two(), controller_key='chummo')
        yield 'at_start', o.screenshot()
        o.press_key('KEY_DOWN')
        yield 'focus_looks_right', o.screenshot()
        o.press_key('KEY_UP')
        yield 'focus_goes_back_to_orig', o.screenshot()


class Case7734_add_two(CommonCase):

    def test_010_ACA_builds(self):
        assert ACA_one()

    def test_020_CA_builds(self):
        assert concretize(h, w, ACA_one())

    def test_030_entered_screen(self):
        s = self.screenshot_at('the_entered_screen')
        o = s.classified_row_with_focus
        assert o.looks_like_label_row
        assert 'chimmo' in s.changed_visually
        assert '[a]dd' in s.button_labels

    def test_040_after_first_add(self):
        s = self.screenshot_at('after_first_add')
        o = s.classified_row_with_focus
        assert 'fazoozle' == o.content
        assert '[x]delete' in s.button_labels

    def test_050_after_second_add(self):
        s = self.screenshot_at('after_second_add')
        o = s.classified_row_with_focus
        assert 'foozie 2' == o.content
        assert 3 == o.lineno

    def given_performance(self):
        o = start_long_story(self, h, w, ACA_one(), controller_key='chimmo')

        # Press enter to enter the SAC-editing frame
        o.press_key('\n')
        o.expect_this_button_was_pressed('[enter] to edit')

        # Response is a patch to PUSH A NEW CONTROLLER FRAME
        o.expect_only_change_with_head('input_controller', 'push_receiver')
        yield 'the_entered_screen', o.screenshot()

        # Press 'a' to add a new item
        o.press_key('a')
        o.enter_text('fazoozle ')
        yield 'after_first_add', o.screenshot()

        # Press 'a' to add another item after the last items
        o.press_key('a')
        o.enter_text('  foozie 2')
        yield 'after_second_add', o.screenshot()


"""NOTE the next run of several cases is the result of having started with
a very long story that was in one long test (!) and then breaking it up in to
smaller cases by modeling these "waypoints" (and in the process creating a
bunch of facilities to allow this).

This is significant because the individual performances below might make more
sense if you know how they fit into the context of the original long narrative,
which covers most/all of the core functionality of our orderable list and
SAC inventions:

- Add an item
- Add another item after it
- Navigate up to the first item
- Add an item after the first item. Assert insert between first & second item
- Navigate up to the first item (also the 1st you ever created)
- Delete it. Assert list is now: ("third item added", "second item added")
  Assert focus stayed on the screen row, so "third item added" has focus
- Move the item down. Assert list is now: ("second item added", "third ite ..")
- Pop out of the SAC with "do[n]e". Assert it popped somehow
.
"""


class Case7736_add_actually_inserts(CommonCase):

    def test_010_new_item_is_in_between_and_has_focus(self):
        s1 = self.screenshot_at('before_added_third')
        act = s1.content_strings
        exp = 'added first', 'added second'
        self.assertSequenceEqual(act, exp)

        assert s1.content_with_focus == 'added first'

        s2 = self.screenshot_at('after_added_third')
        act = s2.content_strings
        exp = 'added first', 'added third', 'added second'
        self.assertSequenceEqual(act, exp)

        assert s2.content_with_focus == 'added third'

    def given_performance(self, o):

        # Move up to focus item 1
        o.press_key('KEY_UP')
        yield 'before_added_third', o.screenshot()

        # Add a third item
        o.press_key('a')
        # o.expect_this_button_was_pressed('add-[a]fter')
        o.enter_text('added third')
        yield 'after_added_third', o.screenshot()

    def given_startingpoint_focus(_):
        return 'chimmo', 'item_2'

    def given_startingpoint(self):
        return ACA_one_with_vals(self, chimmo=('added first', 'added second'))


class Case7738_delete(CommonCase):

    def test_010_deletes_the_thing(self):
        s1 = self.screenshot_at('before_deleted')
        act = s1.content_strings
        exp = 'added first', 'added third', 'added second'
        self.assertSequenceEqual(act, exp)

        s2 = self.screenshot_at('after_deleted')
        act = s2.content_strings
        exp = 'added third', 'added second'
        self.assertSequenceEqual(act, exp)

    def test_020_focus_after(self):
        s2 = self.screenshot_at('after_deleted')
        o = s2.classified_row_with_focus
        assert 'added third' == o.content

    def given_performance(self, o):
        yield 'before_deleted', o.screenshot()
        o.press_key('x')
        o.expect_this_button_was_pressed('[x]delete')
        yield 'after_deleted', o.screenshot()

    def given_startingpoint_focus(_):
        return 'chimmo', 'item_1'

    def given_startingpoint(self):
        list_values = 'added first', 'added third', 'added second'
        return ACA_one_with_vals(self, chimmo=list_values)


class Case7740_move_down_and_pop_out(CommonCase):

    def test_010_(self):
        s2 = self.screenshot_at('after_moved_down')
        act = s2.content_strings
        exp = 'added second', 'added third'
        self.assertSequenceEqual(act, exp)

    def given_performance(self, o):

        yield 'before_moved_down', o.screenshot()

        o.press_key('d')
        o.expect_this_button_was_pressed('move-[d]own')
        yield 'after_moved_down', o.screenshot()

        o.press_key('n')
        o.expect_this_button_was_pressed('do[n]e-editing-list')
        yield 'after_pop_out', o.screenshot()

    def given_startingpoint_focus(_):
        return 'chimmo', 'item_1'

    def given_startingpoint(self):
        list_values = 'added third', 'added second'
        return ACA_one_with_vals(self, chimmo=list_values)


def ACA_two():  # MEMOIZE ME
    return ACA_via_via()(ACA_def_two())


def ACA_def_two():
    yield 'nav_area', ('enjoy_your', 'orderable_list')
    yield 'orderable_list', 'chummo',
    yield 'flash_area'
    yield 'buttons'


def ACA_one_with_vals(tc, ** vals):
    return start_long_story(
        tc, h, w, ACA_one(vals), controller_key='chimmo')


def ACA_one(vals=None):
    return ACA_via_via()(ACA_def_one(), vals=vals)


def ACA_def_one():
    yield 'orderable_list', 'chimmo'
    yield 'buttons'


h, w = 9, 38


def xx(*_):
    raise RuntimeError('xx')


if __name__ == '__main__':
    unittest.main()

# #born
