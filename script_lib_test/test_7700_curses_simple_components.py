from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subject_in_children, \
        lazy
import unittest


class CommonCase(unittest.TestCase):

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
        harness = cca._children[k]
        return harness.concrete_area

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


class Case7688_nav_area_states(CommonCase):
    # #provision [#608.M]: topmost fella starts out as selected (not the point)

    def test_020_my_first_transition_test(self):
        comp = self.make_a_copy_of_the_component()
        assert 'has_focus' == state_name_of(comp)
        move_to_state_via_transition_name(comp, 'cursor_exit')
        assert 'initial' == state_name_of(comp)
        move_to_state_via_transition_name(comp, 'cursor_enter')
        assert 'has_focus' == state_name_of(comp)

    def test_040_render_when_not_selected(self):
        comp = self.the_component()
        act = tuple(comp.to_rows())
        exp = ('👉 fipple fapple            ',)
        self.assertSequenceEqual(act, exp)

    def test_060_render_when_selected(self):
        comp = self.make_a_copy_of_the_component()
        move_to_state_via_transition_name(comp, 'cursor_exit')
        act = tuple(comp.to_rows())
        exp = ('  fipple fapple            ',)
        self.assertSequenceEqual(act, exp)

    component_key = 'nav_area'


class Case7692_checkbox_states(CommonCase):

    def test_100_hello_state(self):
        assert 'initial' == state_name_of(self.the_component())

    component_key = 'be_verbose'


class Case7696_textfield_states(CommonCase):

    def test_100_hello_state(self):
        assert 'initial' == state_name_of(self.the_component())

    component_key = 'foo_fah'


class Case7700_press_a_strange_key(CommonCase):

    def test_033_response_is_OK(self):
        response_is_OK(self.keypress_end_state_response)

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

    def test_033_response_is_OK(self):
        response_is_OK(self.keypress_end_state_response)

    def test_066_does_nothing(self):
        assert self.keypress_end_state_response.do_nothing

    def given_keypress(_):
        return 'KEY_UP'

    def given_controller(_):
        return controller_one_DO_NOT_MUTATE()


class Case7704_move_down_oh_boy(CommonCase):

    def test_033_LETS_GO(self):
        resp = self.keypress_end_state_response
        assert resp.OK
        change1, change2 = resp.changes
        exp = 'nav_area transition_over cursor_exit'.split()
        self.assertSequenceEqual(change1, exp)
        exp = 'foo_fah transition_over cursor_enter'.split()
        self.assertSequenceEqual(change2, exp)

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


def response_is_OK(resp):
    assert resp.OK is True


@lazy
def controller_one_DO_NOT_MUTATE():
    cca = CCA_one_BE_CAREFUL()
    # cca = cca.MAKE_A_COPY()
    return cca.to_EXPERIMENTAL_input_controller()


@lazy
def CCA_one_BE_CAREFUL():
    aa = ACA_one()
    return concretize(6, 27, aa)


@lazy
def ACA_one():
    return ACA_via(ACA_def_one())


def ACA_def_one():
    if True:
        yield 'nav_area', ('fipple_fapple',)
        yield 'text_field', 'foo_fah'
        yield 'horizontal_rule'
        yield 'checkbox', 'be_verbose', 'label', 'Whether to be verbose'
        yield 'text_field', 'fiz_nizzle'
        yield 'vertical_filler'


def move_to_state_via_transition_name(comp, sn):
    comp.state.move_to_state_via_transition_name(sn)


def state_name_of(comp):
    return comp.state.state_name


def concretize(h, w, aa, listener=None):
    return aa.concretize_via_available_height_and_width(h, w, listener)


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
