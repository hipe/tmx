from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subj_in_children, lazy
import unittest


class CommonCase(unittest.TestCase):

    # == Assertion Support

    def expect_none_result(self):
        self.assertIsNone(self.end_result)

    @property
    def end_result(self):
        return self.end_state.end_result

    @property
    def end_emission(self):
        return self.end_state.emission

    # == Build End State

    @property
    @shared_subj_in_children
    def end_state(self):
        return self.build_end_state()

    def build_end_state(self):  # maybe children want to override this
        return self.build_end_state_commonly()

    def build_end_state_commonly(self):
        exps = self.expected_emissions()
        listener, done = em().listener_and_done_via(exps, self)
        performance_result = self.given_performance(listener)
        ems, this_emission = done(), None
        if len(ems):
            this_emission = ems.pop('the_emi')  # ..
            assert not ems  # ..
        return end_state()(performance_result, this_emission)

    def build_collection_plus(self):
        from kiss_rdb_test.common_initial_state import \
            pretend_file_via_path_and_lines as func
        fname = 'fake/file'  # must be relative not abs for path relativizer
        pfile = func(fname, self.given_table())

        def opn(path):
            assert fname == path
            return pfile

        def recv_diff_lines(diff_lines):
            assert recv_diff_lines.value is None
            recv_diff_lines.value = tuple(diff_lines)
            return True  # important! tell it you succeeded

        opn.RECEIVE_DIFF_LINES = recv_diff_lines
        recv_diff_lines.value = None

        func = subject_module()._I_am_a_legacy_of_the_past_who_will_go_away
        ci = func(fname, opn=opn, iden_clser=self.given_identity_class)
        from kiss_rdb.magnetics_.collection_via_path import \
            NEW_COLLECTION_VIA_OLD_COLLECTION_IMPLEMENTATION_ as func
        coll = func(ci)
        return coll, recv_diff_lines.value

    do_debug = False


class Case2744_fail_to_parse_one_identifier(CommonCase):

    def test_010_emits_on_the_expected_channel(self):
        assert self.end_state.emission

    def test_020_the_good_identifiers_got_thru_and_used_the_custom_class(self):
        idens = self.end_result
        assert 1 < len(idens)
        assert all((idens[0], idens[-1]))
        assert 'ohai I am custom iden' == idens[0][0]

    def test_030_the_bad_identifer_is_none__did_not_get_filtered_out(self):
        assert self.end_result[1] is None

    def test_040_a_reason_was_emitted(self):
        act = self.end_emission.payloader()['reason']
        self.assertRegex(act, r"\bwhoopsie.+\bhad:? 'D'")

    def test_050_you_have_the_path_and_line_and_line_number_but_not_col(self):
        sct = self.end_emission.payloader()
        self.assertEqual(sct['lineno'], 5)
        self.assertEqual(sct['line'], "|  D|  e|  f|\n")
        self.assertNotIn('col', sct)

    def given_table(_):
        return ("|foo|bar|baz|\n",
                "|---|---|---|\n",
                "| eg|   |   |\n",
                "|  a|  b|  c|\n",
                "|  D|  e|  f|\n",
                "|  g|  h|  i|\n")

    def given_identity_class(self, listener, cstacker):
        def build_iden(primi):
            if re.match('^[a-z]$', primi):
                return ('ohai I am custom iden', primi)
            assert re.match('^[A-Z]$', primi)
            sct = {k: v for row in cstacker() for k, v in row.items()}
            sct['reason'] = f"whoopsie, idens must be lc. had: {repr(primi)}"
            listener('info', 'structure', 'ohai', lambda: sct)
            pass
        import re
        return build_iden

    def given_performance(self, listener):
        coll, _ = self.build_collection_plus()
        itr = coll.TO_IDENTIFIER_STREAM(listener)
        return tuple(itr)

    def expected_emissions(_):
        yield 'info', 'structure', 'ohai', 'as', 'the_emi'


class Case2746_INSERT_when_out_of_order(CommonCase):

    def test_020_emits(self):
        assert self.end_emission

    def test_010_expect_none_result_because_you_failed(self):
        self.expect_none_result()

    def test_020_the_string_method_of_custom_iden_is_used_in_errror_msg(self):
        msgs = self.end_emission.payloader()
        msg, = msgs
        self.assertRegex(msg, r' not in order\b.+Secrets.+ then .+Stone___👈')

    def given_table(_):
        return ("|      t i t l e     |anno|\n",
                "|:-------------------|----|\n",
                "|                    |    |\n",
                "|Chamber of Secrets  |1998|\n",
                "|Philosopher's Stone |1997|\n",
                "|Goblet of Fire      |2000|\n",
                "|Order of the Phoenix|2003|\n")
        #       "|Prisoner of Azkaban |1999|\n",

    def given_identity_class(self, *args):
        return build_this_other_identifier_class(*args)

    def given_performance(self, listener):
        coll, _ = self.build_collection_plus()
        dct = {'t_i_t_l_e': 'Prisoner of Azkaban', 'year': '1999'}
        return create_entity(coll, dct, listener)

    def expected_emissions(_):
        yield 'error', 'expression', 'disorder', 'as', 'the_emi'


class Case2748_INSERT_okay(CommonCase):

    def test_010_emits_idk(self):
        assert self.end_emission

    def test_020_the_created_entity_uses_the_injected_identifier_class(self):
        ent = self.end_state.end_result
        act = str(ent.identifier)
        self.assertEqual(act, '👉___Prisoner of Azkaban___👈')

    def given_table(_):
        return ("|                 title|anno|\n",
                "|:---------------------|----|\n",
                "|                      |    |\n",
                "|   Philosopher's Stone|1997|\n",
                "|  Chamber of Secrets  |1998|\n",
                #   Prisoner of Azkaban |1999|\n",
                "|  Goblet of Fire      |2000|\n")

    def given_identity_class(self, *args):
        return build_this_other_identifier_class(*args)

    def given_performance(self, listener):
        coll, NEATO = self.build_collection_plus()
        dct = {'title': 'Prisoner of Azkaban', 'anno': '1999'}
        return create_entity(coll, dct, listener)

    def expected_emissions(_):
        yield 'info', 'structure', 'created_entity', 'as', 'the_emi'


# ==

def build_this_other_identifier_class(listener, cstacker):
    def build_iden(primi):
        if primi is None:
            return
        assert primi in _correct_order  # this case isn't under test else emit
        return MyCustomClass(primi)
    return build_iden


class MyCustomClass:
    def __init__(self, title):
        self._my_ordinality = _correct_order.index(title)
        self._title = title

    def __str__(self):  # (Case2748)
        return self.to_string()

    def to_string(self):  # (Case2746)
        return f"👉___{self._title}___👈"

    def __lt__(self, otr):
        return -1 == self._cmp(otr)

    def __eq__(self, otr):
        return 0 == self._cmp(otr)

    def _cmp(self, otr):
        assert isinstance(otr, self.__class__)
        my_ord, otr_ord = self._my_ordinality, otr._my_ordinality
        if my_ord < otr_ord:
            return -1
        if my_ord == otr_ord:
            return 0
        assert otr_ord < my_ord
        return 1


_correct_order = (
    "Philosopher's Stone", 'Chamber of Secrets', 'Prisoner of Azkaban',
    'Goblet of Fire', 'Order of the Phoenix')


def create_entity(coll, dct, listener):
    return coll.create_entity(dct, listener)


@lazy
def end_state():
    from collections import namedtuple as nt
    return nt('EndState', ('end_result', 'emission'))


def em():
    import modality_agnostic.test_support.common as em
    return em


def subject_module():
    import kiss_rdb.storage_adapters_.markdown_table as module
    return module


if __name__ == '__main__':
    unittest.main()

# #born
