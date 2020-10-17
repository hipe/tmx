from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subj_in_children, \
        dangerous_memoize as shared_subject
import unittest


class CommonCase(unittest.TestCase):

    @property
    @shared_subj_in_children
    def end_state(self):
        def run(readme, opn, listener):
            return subject_function()(readme, eid, listener, opn)
        eid = self.given_needle()
        from pho_test.issues_support import build_end_state_for as func
        es = func(self, run)
        assert es.end_result is None
        return es

    do_debug = False


class Case3869PH_not_found(CommonCase):

    def test_050_emits(self):
        assert self.end_state

    def test_100_says_not_found(self):
        self.assertIn("'[#124]' not found", self.msg)

    def test_150_says_thing_about_order(self):
        self.assertIn("Or it's out of order. (stopped at '[#123]')", self.msg)

    @shared_subject
    def msg(self):
        return self.end_state.emissions['emi1'].payloader()['reason']

    def given_needle(_):
        return '124'

    def given_lines(_):
        return given_same_lines()

    def expected_emissions(_):
        yield 'error', 'structure', 'entity_not_found', 'as', 'emi1'


class Case3870_found(CommonCase):

    def test_025_emits_two(self):
        assert self.end_state

    def test_050_says_updated_attributes(self):
        dct = self.end_state.emissions['emi1'].payloader()
        self.assertIn('updated 2 attributes', dct['message'])

    def test_100_says_before(self):
        act = self.two_lines[0]
        self.assertEqual(act, 'BEFORE: |[#125]|#four| five s\n')

    def test_150_says_after(self):
        act = self.two_lines[1]
        self.assertEqual(act, 'AFTER:  |[#125]|#hole|\n')

    @shared_subject
    def two_lines(self):
        return tuple(self.end_state.emissions['emi2'].payloader())

    def given_needle(_):
        return '125'

    def given_lines(_):
        return given_same_lines()

    def expected_emissions(_):
        yield 'info', 'structure', 'updated_entity', 'as', 'emi1'
        yield 'info', 'expression', 'closed_issue', 'as', 'emi2'


def given_same_lines():
    yield '| iden |Main tag|Content|\n'
    yield '|------|-----|-------|\n'
    yield '|  eg  |aaaaa| eg\n'
    yield '|[#126]|#seve| eight\n'
    yield '|[#125]|#four| five s\n'
    yield '|[#123]|#one | two th\n'


def subject_function():
    from pho._issues.edit import close_issue as func
    return func


if __name__ == '__main__':
    unittest.main()

# #born
