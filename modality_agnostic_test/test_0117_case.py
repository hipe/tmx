import modality_agnostic.test_support.common as em
import unittest
from collections import namedtuple as _nt


shared_subject = em.dangerous_memoize


class CommonCase(unittest.TestCase):
    do_debug = False


class Case0107_works(CommonCase):

    def test_050_works(self):
        es = self.build_end_state()
        act, = es
        assert 'bb' == act

    def build_end_state(self):
        def when_two_letters_is():
            yield 'AA', lambda: rec.append('aa')
            yield 'BB', lambda: rec.append('bb')
        case = subject_fellow()()
        rec = []
        case('BB', when_two_letters_is)
        return tuple(rec)


class Case0108_when_not_found_with_string_values(CommonCase):

    def test_050_result_was_nothing(self):
        act = self.end_state.result_value
        assert act is None

    def test_060_obvi_didnt_call_any_of_the_consequences(self):
        assert 0 == len(self.end_state.recordings)

    def test_080_emission_channel_is_this(self):
        emi, = self.end_state.emissions
        act = emi.channel
        exp = 'error', 'expression', 'no_case_matched'
        self.assertSequenceEqual(act, exp)

    def test_100_the_message_is_the_moneyshot(self):
        emi, = self.end_state.emissions
        act, = emi.to_messages()
        msgs = act.split('. ')
        act1, act2 = msgs
        exp = "Expecting two letters to be 'AA' or 'BB'"
        self.assertEqual(act1, exp)
        self.assertEqual(act2, "Had: 'CC'")

    @shared_subject
    def end_state(self):
        def when_two_letters_is():
            yield 'AA', lambda: rec.append('aa')
            yield 'BB', lambda: rec.append('bb')
        listener, emis = em.listener_and_emissions_for(self)
        case = subject_fellow()(listener)
        rec = []
        x = case('CC', when_two_letters_is)
        return EndState(tuple(emis), tuple(rec), x)


class Case0109_one_arg_form(CommonCase):

    def test_050_like_this(self):

        def when_chim_churry_is():
            yield condition_one, consequence_one
            yield condition_two, consequence_two
            yield condition_three, consequence_three

        def condition_one():
            pass

        def condition_two():
            return True

        def condition_three():
            self.fail("should never reach here")

        def consequence_one():
            self.fail("no see")

        def consequence_two():
            return 'value for two'

        def consequence_three():
            self.fail('no see')

        case = subject_fellow()()
        val = case(when_chim_churry_is)
        assert val == 'value for two'


class Case0110_one_arg_form_error_message(CommonCase):

    def test_100_the_message_is_the_moneyshot(self):
        msgs = self.build_end_state()
        act, = msgs
        exp = ("Expecting chim churry to be 'condition_one', "
               "'condition_two' or 'condition_three'")
        self.assertEqual(act, exp)

    def build_end_state(self):

        def when_chim_churry_is():
            yield condition_one, no_see
            yield condition_two, no_see
            yield condition_three, no_see

        def condition_one():
            pass

        def condition_two():
            pass

        def condition_three():
            pass

        def no_see():
            self.fail("no see")

        listener, emis = em.listener_and_emissions_for(self)
        case = subject_fellow()(listener)
        val = case(when_chim_churry_is)
        assert val is None
        emi, = emis
        return emi.to_messages()


EndState = _nt('EndState', ('emissions', 'recordings', 'result_value'))


def subject_fellow():
    from kiss_rdb.magnetics_.collection_via_path import _build_case_function
    return _build_case_function


if __name__ == '__main__':
    unittest.main()

# #born
