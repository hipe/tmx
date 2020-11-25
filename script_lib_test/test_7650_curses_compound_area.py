from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subject_in_children
import unittest


class CommonCommonCase(unittest.TestCase):

    @property
    def common_exception(_):
        return support_lib().common_exception_class()

    do_debug = False


class CaseForACA(CommonCommonCase):

    def perform_concretize(self, h, w):
        listener, emis = listener_and_emissions_for(self)
        aca = self.subject
        res = aca.concretize_via_available_height_and_width(h, w, listener)
        emi = None
        if len(emis):
            emi, = emis
        return res, emi

    @property
    @shared_subject_in_children
    def subject(self):
        return self.given_subject()

    @property
    def subject_function(self):
        return self.subject_module().abstract_compound_area_via_children_

    def subject_module(_):
        from script_lib.curses_yikes import compound_area_via_children as modul
        return modul


CommonCase = CaseForACA


class Case7645_ACA_introductory_errors(CommonCase):

    def test_050_you_must_have_at_least_one_child(self):
        with self.assertRaises(self.common_exception) as context:
            self.subject_function(())
        act = reason_via_exception(context.exception)
        self.assertEqual(act, "A compound area must have at least one child")

    def test_075_for_ordinary_children_you_cant_repeat_names(self):
        def children():
            yield 'ting_1', None
            yield 'ting_1', None
        with self.assertRaises(self.common_exception) as context:
            self.subject_function(children())
        act = reason_via_exception(context.exception)
        self.assertEqual(act, "Encountered duplicate child name: 'ting_1'")

    def test_100_for_now_you_need_one_veritcal_filler(self):
        def children():
            yield 'horizontal_rule'
        with self.assertRaises(self.common_exception) as context:
            self.subject_function(children())
        act = reason_via_exception(context.exception)
        exp = "Need at least one component that can fill vertically"
        self.assertEqual(act, exp)


class Case7650_ACA_attempt_to_party(CommonCase):

    def test_020_builds(self):
        assert self.subject.hello_I_am_ACA()

    def test_040_when_available_area_too_narrow(self):
        res, emi = self.perform_concretize(4, 0)
        assert res is None
        self.assertEqual(emi.channel[2], 'constraints_not_met')

        msg, = emi.to_messages()

        exp = 'available width is 0 but at least 1 is required'
        self.assertIn(exp, msg)

        exp = '(horizontal_rule_1, vertical_filler_1, horizontal_rule_2)'
        self.assertIn(exp, msg)

    def test_060_when_available_area_too_short(self):
        res, emi = self.perform_concretize(1, 1)
        assert res is None
        self.assertEqual(emi.channel[2], 'constraints_not_met')

        msg, = emi.to_messages()

        exp = 'available height is 1 but a height of at at least 2 is required'
        self.assertIn(exp, msg)

    def test_080_lets_party(self):
        res, emi = self.perform_concretize(4, 2)
        assert emi is None
        act = tuple(res.to_rows())
        exp = '--', '  ', '  ', '--'
        self.assertSequenceEqual(act, exp)

    def given_subject(self):
        def children():
            yield 'horizontal_rule'
            yield 'vertical_filler'
            yield 'horizontal_rule'
        return self.subject_function(children())


def listener_and_emissions_for(tc):
    from modality_agnostic.test_support.common import \
        listener_and_emissions_for as func
    return func(tc)


def reason_via_exception(exce):
    msg, = exce.args
    return msg


def support_lib():
    from script_lib_test import curses_yikes_support as module
    return module


if __name__ == '__main__':
    unittest.main()

# #born
