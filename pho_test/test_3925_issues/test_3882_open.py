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
        with opn(readme, 'r+') as fh:
            return provision_identifier()(opn, fh, listener)


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
        self.assertEqual(self.end_identifier_string(), '[#122.H]')

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
        return open_issue()(readme, dct, listener, opn=opn)


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
        yield 'verbose', 'expression'  # 😕
        yield 'info', 'structure', 'created_entity', 'as', 'the_emi'

    def expected_num_rewinds(_):
        return 1


class Case3887_directives(MoneyCase):

    def test_010_go(self):
        act = self.end_state.end_result.created_entity.identifier.to_string()
        assert '[#124.C]' == act

    def given_lines(_):
        yield "## (hello i'm table title)\n"
        yield "\n"
        yield "(Our range: [#000-#999])\n"
        yield "([#123-122) is yadda yadda this isn't a thing)\n"
        yield "(Put new issues in this range: [#124.A-#125))\n"
        yield "\n"
        yield '| col 1 | main tag | col 3|\n'
        yield '|---|---|---|\n'
        yield '|[#999] | see one ? | see two? |\n'
        yield '|[#128]  | see one ? | see two? |\n'
        yield '|[#124.B]| #obun | fix the thing\n'
        yield '|[#124.A]| #obun | fix the thing\n'
        yield '|[#122]  | #obun | fix the thing\n'

    def expected_emissions(_):
        yield 'verbose', 'expression'
        yield 'info', 'structure', 'created_entity'

    def expected_num_rewinds(_):
        return 1


class Case3888_money_update(MoneyCase):

    def test_050_emits(self):
        assert self.end_state

    def test_100_expresses(self):
        act = self.end_state.emissions['the_emi'].payloader()['message']
        exp = "updated '[#125]' (created 1 and updated 1 attribute)"
        self.assertEqual(act, exp)

    def test_150_diff(self):  # it feels too low-level to test this at all
        lines = self.end_state.diff_lines
        act = tuple(line[:2] for line in lines)
        exp = ('--', '++', '@@', ' |', ' |', ' |', '-|', '+|')
        self.assertSequenceEqual(act, exp)
        self.assertEqual(lines[6], '-|[#125]|#hole|\n')
        self.assertEqual(lines[7], '+|[#125]|#opun|\n')

    def given_lines(_):
        yield '| IDEn | MAIn TAg | CONTENt |\n'
        yield '|---|---|---|\n'
        yield '|[#126]|#eg| froo froo\n'
        yield '|[#125]|#hole|\n'

    def expected_emissions(_):
        yield 'verbose', 'expression'  # 😕
        yield 'info', 'structure', 'updated_entity', 'as', 'the_emi'

    def expected_num_rewinds(_):
        return 1


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
