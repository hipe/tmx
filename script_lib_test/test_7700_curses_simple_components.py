from script_lib_test.curses_yikes_support import input_controller_via_CCA
from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subject_in_children, \
        lazy
import unittest


class CommonCase(unittest.TestCase):

    # == DSL-like assertions

    def expect_does_not_have_focus(self, comp):
        assert 'initial' == state_name_of(comp)

    def expect_has_focus(self, comp):
        assert 'has_focus' == state_name_of(comp)  # might change to ! initial

    # ==

    @property
    @shared_subject_in_children
    def keypress_end_state_response(self):
        cont = self.given_controller()
        resp = cont.receive_keypress(self.given_keypress())
        if self.do_debug:
            from sys import stderr
            emis = emissions_via_response(resp)
            if emis is None:  # (remember this is a custom, pared down emi cl)
                stderr.write("\n(DBG: NO EMISSIONS)\n")
            else:
                for emi in emis:
                    for msg in emi.to_messages():
                        stderr.write(f"\n(EMI: {msg!r})\n")
        return resp

    def make_a_copy_of_the_component(self):
        ca = self.the_component()
        return ca.MAKE_A_COPY()

    def the_component(self):
        cca = self.given_CCA_be_careful()
        k = self.component_key
        return dereference_component(cca, k)

    def given_CCA_be_careful(_):
        return CCA_one_BE_CAREFUL()

    def concrete_expecting_success(self, h, w):
        listener, done = em_lib().listener_and_done_via((), self)
        aa = self.ACA
        res = concretize(h, w, aa, listener)
        done()
        return res

    @property
    @shared_subject_in_children
    def ACA(self):
        return ACA_via(self.given_ACA_def())

    do_debug = False


class Case7688_nav_area_states_and_render(CommonCase):
    # #provision [#608.M]: topmost fella starts out as focused (not the point)

    def test_020_my_first_transition_test(self):
        comp = self.make_a_copy_of_the_component()
        self.expect_has_focus(comp)
        move_to_state_via_transition_name(comp, 'cursor_exit')
        self.expect_does_not_have_focus(comp)
        move_to_state_via_transition_name(comp, 'cursor_enter')
        self.expect_has_focus(comp)

    def test_040_render_when_focused(self):
        comp = self.the_component()
        act = tuple(comp.to_rows())
        exp = (f'{focused}[…] > area 1 > fipp fapp ',)
        self.assertSequenceEqual(act, exp)

    def test_060_render_when_not_focused(self):
        comp = self.make_a_copy_of_the_component()
        move_to_state_via_transition_name(comp, 'cursor_exit')
        act = tuple(comp.to_rows())
        exp = (f'{nofocus}[…] > area 1 > fipp fapp ',)
        self.assertSequenceEqual(act, exp)

    component_key = 'nav_area'


class Case7692_checkbox_states_and_render(CommonCase):

    def test_020_hello_state(self):
        comp = self.the_component()
        self.expect_does_not_have_focus(comp)

    def test_040_hello_render(self):
        comp = self.the_component()
        rows = tuple(comp.to_rows())
        act, = rows
        exp = f'{nofocus}[ ] Whether to be verbose'
        self.assertEqual(act, exp)

    def test_060_check(self):
        comp = self.make_a_copy_of_the_component()
        move_to_state_via_transition_name(comp, 'cursor_enter')
        assert comp._is_checked is False
        state = state_of(comp)
        tr = state.transition_via_transition_name('[enter] to toggle')  # yuck
        fname = tr.action_function_name
        assert fname
        state.accept_transition(tr)
        resp = getattr(comp, fname)()
        k, = resp.changed_visually
        assert 'be_verbose' == k
        assert comp._is_checked is True

    component_key = 'be_verbose'


class Case7696_text_field_states_and_render(CommonCase):

    def test_020_hello_state(self):
        assert 'initial' == state_name_of(self.the_component())

    def test_040_hello_render(self):
        comp = self.the_component()
        rows = tuple(comp.to_rows())
        act, = rows
        exp = f'{nofocus}Foo fah: [              ]'
        self.assertEqual(act, exp)

    def test_060_big_interaction_for_enter_emacs_mode(self):

        # Navigate down to the text field component
        comp = self.make_a_copy_of_the_component()
        comp.become_focused()

        # Hit enter on the component to enter edit mode (assert host direc.)
        state = state_of(comp)
        tr = state.transition_via_transition_name('[enter] for edit')  # yuck
        fname = tr.action_function_name
        assert fname
        state.accept_transition(tr)
        resp = getattr(comp, fname)()
        ch, = resp.changes
        assert 'host_directive' == ch[0]
        assert 'enter_text_field_modal' == ch[1]

        # Pretend we enter some text and hit enter
        resp = comp.receive_new_value_from_modal_('zing')

        # Assert: this results in a response (could write to flash)
        assert ('foo_fah',) == resp.changed_visually

        # Assert: the new value is displayed by the component now
        act = tuple(comp.to_rows())
        exp = (f'{focused}Foo fah: [zing          ]',)
        self.assertSequenceEqual(act, exp)

    component_key = 'foo_fah'


class Case7700_press_a_strange_key(CommonCase):

    def test_066_response_has_semantic_category(self):
        act = response_category(self.keypress_end_state_response)
        assert 'key_does_nothing' == act

    def test_100_response_has_string_message(self):
        act = response_string_message(self.keypress_end_state_response)
        self.assertEqual(act, "Does nothing: '8'")

    def given_keypress(_):
        return '8'

    def given_controller(_):
        return controller_one_DO_NOT_MUTATE()


class Case7702_move_up_but_you_cant_go_up(CommonCase):

    def test_066_does_nothing(self):
        assert self.keypress_end_state_response.do_nothing

    def given_keypress(_):
        return 'KEY_UP'

    def given_controller(_):
        return controller_one_DO_NOT_MUTATE()


class Case7704_move_down_oh_boy(CommonCase):

    def test_033_this_is_what_the_patch_looks_like_for_change_focus(self):
        resp = self.keypress_end_state_response
        change1, = resp.changes

        from script_lib.curses_yikes import \
            MutableChangeFocusDirective_ as func

        o = func(*change1)  # creating this validates the first 2 components

        # The previously focused is this
        assert 'nav_area' == o['goodbye_component_key']

        # The newly focused is this
        assert 'foo_fah' == o['hello_component_key']
        assert 'foo_fah' == o['component_key_in_the_context_of_buttons']

        # Its "component button page key" (state name) is this
        assert 'has_focus' == o['component_buttons_page_key']

    def given_keypress(_):
        return 'KEY_DOWN'

    def given_controller(_):
        return controller_one_DO_NOT_MUTATE()


def response_string_message(resp):
    emi, = emissions_via_response(resp)
    msg, = emi.to_messages()
    return msg


def response_category(resp):
    emi, = emissions_via_response(resp)
    return emi.category


def emissions_via_response(resp):
    return resp.emissions


def controller_one_DO_NOT_MUTATE():
    return controller_and_CCA_one_DO_NOT_MUTATE()[0]


def CCA_one_BE_CAREFUL():
    return controller_and_CCA_one_DO_NOT_MUTATE()[1]


@lazy
def controller_and_CCA_one_DO_NOT_MUTATE():
    aca = ACA_one()
    cca = concretize(6, 28, aca)
    ic = input_controller_via_CCA(cca)
    return ic, cca


@lazy
def ACA_one():
    return ACA_via(ACA_def_one())


def ACA_def_one():
    if True:
        yield 'nav_area', ('my_app_long_name', 'area_1', 'fipp_fapp')
        yield 'text_field', 'foo_fah'
        yield 'horizontal_rule'
        yield 'checkbox', 'be_verbose', 'label', 'Whether to be verbose'
        yield 'text_field', 'fiz_nizzle'
        yield 'vertical_filler'


def move_to_state_via_transition_name(comp, sn):
    return state_of(comp).move_to_state_via_transition_name(sn)


def state_name_of(comp):
    return state_of(comp).state_name


def state_of(comp):
    return comp._state


def dereference_component(cca, k):
    return cca[k]


def em_lib():
    import modality_agnostic.test_support.common as module
    return module


def concretize(h, w, aa, listener=None):
    return support_lib().concretize(h, w, aa, listener)


def ACA_via(x):
    func = support_lib().function_for_building_abstract_compound_areas()
    return func(x)


def support_lib():
    from script_lib_test import curses_yikes_support as module
    return module


focused = ' 👉 '  # currently 3 spaces wide because of a visual bug
nofocus = '   '  # will change to be wider space


if __name__ == '__main__':
    unittest.main()

# #born
