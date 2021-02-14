from modality_agnostic.test_support.common import listener_and_emissions_for
from unittest import TestCase as unittest_TestCase, main as unittest_main
from collections import namedtuple
from re import compile as re_compile


class CommonCase(unittest_TestCase):

    def do_the_hands_free_test(self):
        es = self.build_end_state()

        exp_fail = self.expected_error_messages()
        exp_succ = self.expected_idens()

        if exp_fail:
            if exp_succ:
                # You can expect both failure and success. do success first
                self.expect_success(es, exp_succ)
            self.expect_failure(es, exp_fail)
            return
        assert exp_succ
        assert 0 == len(es.emissions)
        self.expect_success(es, exp_succ)

    def expect_failure(self, es, exp_fail):
        emi, = es.emissions

        act = emi.channel
        exp = 'error', 'expression', 'parse_error'  # ..
        self.assertSequenceEqual(act, exp)

        act = tuple(emi.to_messages())
        exp = tuple(exp_fail)

        # For now, truncate the act to fit your exp (ignore other, extra lines)
        leng = len(exp)
        if leng < len(act):
            act = act[:leng]

        self.assertSequenceEqual(act, exp)

    def expect_success(self, es, exp_succ):
        act = integers_via_records(es.records)
        self.assertSequenceEqual(act, exp_succ)

    def build_end_state(self):

        # These
        uqt = self.given_user_query_tokens()
        sb = self.given_sort_by()

        # Prepare the readmes (just busy-work to accord with the batch feat.)
        def opn(path):
            assert 'pretend-readme.md' == path
            assert opn.called_zero_times
            opn.called_zero_times = False

            tail_lines = self.given_entity_lines()
            all_lines = self.given_all_lines()
            use_lines = lines_via(tail_lines, all_lines)

            return nullcontext(use_lines)
        opn.called_zero_times = True
        from contextlib import nullcontext
        readmes = nullcontext(('pretend-readme.md',))

        # Listener boilerplate
        listener, emissions = listener_and_emissions_for(self)

        # Execute
        from pho._issues import records_via_query_ as func
        itr = func(opened=readmes, user_query_tokens=uqt, sort_by=sb,
                   do_batch=None, opn=opn, listener=listener)

        future = next(itr)  # #provision [#883.E]
        if future is None:
            result_records_tuple = None
        else:
            result_records_tuple = tuple(itr)

        return EndState(tuple(emissions), result_records_tuple)

    def expected_error_messages(_):
        pass

    def expected_idens(_):
        pass

    def given_user_query_tokens(_):
        pass

    def given_sort_by(_):
        pass

    def given_entity_lines(_):
        pass

    def given_all_lines(_):
        pass

    do_debug = False


class HandsFreeMetaclass(type):  # #[#510.16] meta-class boilerplate

    def __new__(cls, class_name, bases=None, dct=None):
        res = type.__new__(cls, class_name, bases, dct)

        # We can't use the class that will employ this metaclass in this class
        only_ever_one, = bases
        if CommonCase == only_ever_one:
            return res

        setattr(res, 'test', res.do_the_hands_free_test)
        return res


class HandsFreeCase(CommonCase, metaclass=HandsFreeMetaclass):
    pass


class Case3864_50_select_all(HandsFreeCase):

    def expected_idens(_):
        return 6, 5, 4, 3, 2, 1


class Case3865_50_simple_user_query_only(HandsFreeCase):

    def given_user_query_tokens(_):
        return ('#open',)

    def expected_idens(_):
        return 6, 4, 3, 1


class Case3866_50_priority_only(HandsFreeCase):

    def given_sort_by(_):
        return 'by_priority', 'ASCENDING'

    def expected_idens(_):
        return 3, 2, 1, 6  # NOTE order


class Case3867_50_priority_and_user_query(HandsFreeCase):

    def given_sort_by(_):
        return 'by_priority', 'ASCENDING'

    def given_user_query_tokens(_):
        return ('#open',)

    def expected_idens(_):
        return 3, 1, 6


class Case3868_50_fail_to_parse_priority(HandsFreeCase):

    def expected_error_messages(_):
        yield "No support for string names yet, use numbers"

    def given_sort_by(_):
        return 'by_priority', 'ASCENDING'

    def given_entity_lines(_):
        yield "|[#6]|       | both #open and #priority:high ok?\n"


class Case3869_50_re_use_the_same_priority_value(HandsFreeCase):

    def expected_error_messages(_):
        yield "Can't re-use the same priority number. Already seen:"
        yield "    #priority:0.123 i'm 77"

    def expected_idens(_):
        return 88, 99, 66

    def given_sort_by(_):
        return 'by_priority', 'ASCENDING'

    def given_entity_lines(_):
        yield "|[#99]|       | #priority:0.124 i'm 99\n"
        yield "|[#88]|       | #priority:0.123 i'm 88\n"
        yield "|[#77]|       | #priority:0.123 i'm 77\n"
        yield "|[#66]|       | #priority:0.125 i'm 66\n"


def lines_via(tail_lines, all_lines):
    if tail_lines is None:
        if all_lines is None:
            return collection_one_lines()
        return all_lines

    assert all_lines is None
    return lines_via_tail_lines(tail_lines)


def collection_one_lines():
    yield "|sfaef| main_tag | fsaefeasf |\n"
    yield "|---|---|---|\n"
    yield "|[#eg]| no see | no see example row\n"
    yield "|[#6]|       | both #open and #priority:0.93 but lowest priority\n"
    yield "|[#5]|       | neither open nor priority\n"
    yield "|[#4]|       | #open but not a priority\n"
    yield "|[#3]|       | some higher #priority:0.87 thing, yes #open\n"
    yield "|[#2]|       | some higher #priority:0.88 thing, not open\n"
    yield "|[#1]| #open | some low priority (#priority:0.89) ting\n"


def lines_via_tail_lines(tail_lines):
    yield "|fizzy|main tag|fozzy|\n"
    yield "|---|---|---|\n"
    yield "|[#eggo]| nope | no see example\n"
    for line in tail_lines:
        yield line


def integers_via_records(records):
    return tuple(integer_via_record(record) for record in records)


def integer_via_record(record):
    cell_str = record.row_AST.cell_at_offset(0).value_string
    return int(rx.match(cell_str)['integer'])


rx = re_compile(r'\[#(?P<integer>\d+)\]\Z')


EndState = namedtuple('EndState', 'emissions records'.split())


if __name__ == '__main__':
    unittest_main()

# #born
