from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subj_in_children
import unittest


class CommonCase(unittest.TestCase):

    @property
    @shared_subj_in_children
    def end_state(self):
        from pho_test.issues_support import build_end_state_for as func
        return func(self, self.given_run)

    def expected_num_rewinds(_):
        return 0

    do_debug = False


class ProviCase(CommonCase):

    # == End state derivatives

    def end_identifier_string(self):
        return self.end_state.end_result[1].to_string()

    def end_provision_type(self):
        return self.end_state.end_result[0]

    # ==

    def given_run(self, readme, opn, listener):
        return provision_identifier()(readme, listener, opn)


class Case3878_range_of_allowed_ints_established_by_eg_and_last(ProviCase):

    def test_050_emits(self):
        assert self.end_state

    def test_100_explains(self):
        act, = self.end_state.emissions['the_emi'].payloader()
        exp = 'Out of space. No holes between [#123] and [#125]'
        self.assertEqual(act, exp)

    def given_lines(_):
        yield '| iden |Main tag|Content|\n'
        yield '|------|-----|-------|\n'
        yield '|[#125]| #example | eg\n'
        yield '|[#124]|       | qq\n'
        yield '|[#123]|       | qq\n'

    def expected_emissions(_):
        yield 'error', 'expression', 'out_of_space', 'as', 'the_emi'


class Case3880_if_given_a_major_and_a_minor_real_hole(ProviCase):

    def test_050_emits_nothing(self):
        assert self.end_state

    def test_100_uses_the_major_hole(self):
        self.assertEqual(self.end_provision_type(), 'major_hole')

    def test_150_correct_integer(self):
        self.assertEqual(self.end_identifier_string(), '[#123]')

    def given_lines(_):
        yield '| iden |Main tag|Content|\n'
        yield '|--------|----------|---|\n'
        yield '|[#125]  | #example | eg\n'
        yield '|[#124]  |        | qq\n'  # 👇 major hole below
        yield '|[#122]  |        | qq\n'  # ☝️ major hole above
        yield '|[#121.3]|        | x1\n'  # 👇 minor hole below
        yield '|[#121.A]|        | x2\n'  # ☝️ minor hole above
        yield '|[#121]  | #holeo | qq\n'

    def expected_emissions(_):
        return ()


class Case3882_if_no_major_holes_uses_lowest_minor_hole(ProviCase):

    def test_050_emits_nothing(self):
        assert self.end_state

    def test_100_uses_the_major_hole(self):
        self.assertEqual(self.end_provision_type(), 'minor_hole')

    def test_150_correct_integer(self):
        self.assertEqual(self.end_identifier_string(), '[#122.8]')

    def given_lines(_):
        yield '| iden |Main tag|Content|\n'
        yield '|--------|---|---|\n'
        yield '|[#125]  ||\n'
        yield '|[#124]  ||\n'
        yield '|[#123.4]||\n'  # 👇 one minor hole
        yield '|[#123.2]||\n'
        yield '|[#123]  ||\n'
        yield '|[#122.I]||\n'  # 👇 two minor holes
        yield '|[#122.7]||\n'
        yield '|[#122]  ||\n'
        yield '|[#121]  ||\n'

    def expected_emissions(_):
        return ()


class Case3884_the_lowest_item_tagged_as_hole_trumps_all_else(ProviCase):

    def test_050_emits_nothing(self):
        assert self.end_state

    def test_100_uses_the_major_hole(self):
        self.assertEqual(self.end_provision_type(), 'tagged_hole')

    def test_150_correct_integer(self):
        self.assertEqual(self.end_identifier_string(), '[#120.9]')

    def given_lines(_):
        yield '| iden |Main tag|Content|\n'
        yield '|--------|-----|---|\n'
        yield '|[#127]  |     ||\n'  # 👇 major hole below example row
        yield '|[#125]  |     ||\n'  # 👇 major hole below busiess item
        yield '|[#123]  |     ||\n'
        yield '|[#122]  |#hole||\n'  # 👈 this tagged hole loses b.c not lowest
        yield '|[#121]  |     ||\n'
        yield '|[#120.9]|#hole||\n'  # 👈 this tagged hole wins b.c losest
        yield '|[#120.7]|     ||\n'  # 👇 minor hole below
        yield '|[#120.5]|     ||\n'  # 👇 major hole below
        yield '|[#117]  |     ||\n'
        yield '|[#116]  |     ||\n'

    def expected_emissions(_):
        return ()


class MoneyCase(CommonCase):

    # == End state derivatives

    # ==

    def given_run(self, readme, opn, listener):
        dct = {'main_tag': '#opun'}
        return open_issue()(readme, dct, listener, opn)


class Case3886_money_insert(MoneyCase):

    def test_050_emits(self):
        assert self.end_state

    def test_100_expresses(self):
        act = self.end_state.emissions['the_emi'].payloader()['message']
        self.assertEqual(act, "created '[#125]' with 3 attributes")

    def test_150_diff(self):  # it feels too low-level to test this at all
        lines = self.end_state.diff_lines
        act = tuple(line[:2] for line in lines)
        exp = ('--', '++', '@@', ' |', ' |', ' |', '+|', ' |')
        self.assertSequenceEqual(act, exp)
        self.assertEqual(lines[6], '+|[#125]|#opun|\n')

    def given_lines(_):
        yield '| IDEn | MAIn TAg | CONTENt |\n'
        yield '|---|---|---|\n'
        yield '|[#126]|#eg| froo froo\n'
        yield '|[#124]||\n'

    def expected_emissions(_):
        yield 'info', 'structure', 'created_entity', 'as', 'the_emi'

    def expected_num_rewinds(_):
        return 2  # #soon


class Case3888_money_update(MoneyCase):

    def test_050_emits(self):
        assert self.end_state

    def test_100_expresses(self):
        act = self.end_state.emissions['the_emi'].payloader()['message']
        self.assertEqual(act, "updated '[#125]' (updated 2 attributes)")

    def test_150_diff(self):  # it feels too low-level to test this at all
        lines = self.end_state.diff_lines
        act = tuple(line[:2] for line in lines)
        exp = ('--', '++', '@@', ' |', ' |', ' |', '-|', '+|')
        self.assertSequenceEqual(act, exp)
        self.assertEqual(lines[6], '-|[#125]|#hole| Matey Patatey\n')
        self.assertEqual(lines[7], '+|[#125]|#opun|\n')

    def given_lines(_):
        yield '| IDEn | MAIn TAg | CONTENt |\n'
        yield '|---|---|---|\n'
        yield '|[#126]|#eg| froo froo\n'
        yield '|[#125]|#hole| Matey Patatey\n'

    def expected_emissions(_):
        yield 'info', 'structure', 'updated_entity', 'as', 'the_emi'

    def expected_num_rewinds(_):
        return 2  # #soon


def open_issue():
    return subject_module().open_issue


def provision_identifier():
    return subject_module()._provision_identifier


def subject_module():
    import pho._issues.edit as module
    return module


def xx(*_):
    raise RuntimeError('do me')


if __name__ == '__main__':
    unittest.main()

# #born
