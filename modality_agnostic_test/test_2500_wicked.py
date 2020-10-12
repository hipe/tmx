from modality_agnostic.test_support.common import \
        listener_and_emissions_for, \
        dangerous_memoize_in_child_classes as shared_subj_in_child_classes, \
        lazy
import unittest


class CommonCase(unittest.TestCase):

    # == Case Merge

    def case_merge_fails_with_message_that_includes(self, needle):
        listener, emis = listener_and_emissions_for(self)
        rv = self.run_merge_the_two_cases(listener)
        emi, = emis
        lines = tuple(emi.payloader())  # multiple lines ok
        self.assertIn(needle, lines[0])
        self.assertIsNone(rv)

    def expect_expected_output_lines(self):
        result_case = self.run_merge_the_two_cases()
        actual = result_case.lines
        expected = tuple(self.expected_output_lines())
        self.assertSequenceEqual(actual, expected)

    def run_merge_the_two_cases(self, listener=None):
        ccase = case_via_lines(self.given_client_case())
        tcase = case_via_lines(self.given_template_case())
        return updated_block(ccase, tcase, listener)

    # == Plans (assert, build)

    def expect_expected_plan_signature(self):
        exp = tuple(self.expected_plan_signature())
        plan = self.build_plan()
        act = tuple(step_sx[0] for step_sx in plan.steps)
        self.assertSequenceEqual(act, exp)

    def build_plan(self, listener=None):
        def blocks_via_sig(sig):
            return tuple(dct[sx[0]](sx) for sx in sig)
        dct = these()
        csig = self.given_client_signature()
        tsig = self.given_template_signature()
        cblx, tblx = (blocks_via_sig(sig) for sig in (csig, tsig))
        return plan_via_three(cblx, tblx, listener)

    # == Blocks (assert, build)

    def expect_signature(self, * P_or_Cs):
        def which(typ):
            if 'test_case' == typ:
                return 'C'
            if 'plain' == typ:
                return 'P'
            raise RuntimeError(f"oops: '{typ}'")
        act = tuple(which(ch.type) for ch in self.blocks)
        self.assertSequenceEqual(act, P_or_Cs)

    def expect_num_lines(self, *ints):
        acts = tuple(len(ch.lines) for ch in self.blocks)
        self.assertSequenceEqual(acts, ints)

    @property
    @shared_subj_in_child_classes
    def blocks(self):
        return tuple(blocks_via_lines(self.given_lines()))

    do_debug = False


class Case2491_coarse_parse(CommonCase):

    def test_100_parses(self):
        assert self.blocks

    def test_100_signature(self):
        self.expect_signature('P', 'C', 'P')

    def test_200_line_numbers(self):
        self.expect_num_lines(3, 3, 1)

    def given_lines(_):
        yield 'anything you want\n'
        yield '  f fsfisl eijlag fjsn\n'
        yield '\n'
        yield 'class CaseNNNN_foo_bar(CommonCase):\n'
        yield ' \n'
        yield '       xx\n'
        yield 'ohai\n'


class Case2494_pop_new_guy_into_the_middle(CommonCase):

    def test_100_ok(self):
        self.expect_expected_plan_signature()

    def expected_plan_signature(_):
        yield 'update_client_case_with_template_case'
        yield 'insert_case'
        yield 'update_client_case_with_template_case'

    def given_client_signature(_):
        yield 'case', '1234', 'chip_chewey'
        yield 'case', '4567', 'mip_mewey'

    def given_template_signature(_):
        yield 'case', 'NNNN', 'chip_chewey'
        yield 'case', 'NNNN', 'fip_fewey'
        yield 'case', 'NNNN', 'mip_mewey'


class Case2497_strange_new_function(CommonCase):

    def test_050_ok(self):
        needle = "can't add arbitrary new functions"
        self.case_merge_fails_with_message_that_includes(needle)

    def given_client_case(_):
        yield 'class Case1234_wingo_wango(CommonCase):\n'
        yield '\n'
        yield '    def test_075_temecula_tennesee(self):\n'
        yield '        self.ohai()\n'
        yield '\n'

    def given_template_case(_):
        yield 'class CaseNNNN_wingo_wango(CommonCase):\n'
        yield '\n'
        yield '    def test_050_alfa_falfa(self):\n'
        yield '        self.foo_nani()\n'
        yield '\n'
        yield '    def test_100_beta_orbiter(self):\n'
        yield '        self.choo_chani()\n'
        yield '\n'


class Case2500_functions_out_of_order(CommonCase):  # #midpoint

    def test_050_ok(self):
        needle = "must be in the same order"
        self.case_merge_fails_with_message_that_includes(needle)

    def given_client_case(_):
        yield 'class Case1234_wingo_wango(CommonCase):\n'
        yield '\n'
        yield '    def test_456_beta_orbiter(self):\n'
        yield '        self.zibby()\n'
        yield '\n'
        yield '    def test_567_alfa_falfa(self):\n'
        yield '        self.dibby()\n'
        yield '\n'

    def given_template_case(_):
        yield 'class CaseNNNN_wingo_wango(CommonCase):\n'
        yield '\n'
        yield '    def test_050_alfa_falfa(self):\n'
        yield '        self.foo_nani()\n'
        yield '\n'
        yield '    def test_100_beta_orbiter(self):\n'
        yield '        self.choo_chani()\n'
        yield '\n'


class Case2503_insert_before_insert_after_and_clobber(CommonCase):

    def test_050_ok(self):
        self.expect_expected_output_lines()

    def expected_output_lines(_):
        yield 'class Case1234_wingo_wango(CommonCase):\n'
        yield '\n'
        yield '    def test_025_alpha(self):\n'
        yield '        self.template_thing_one()\n'
        yield '\n'
        yield '    def test_222_beta(self):\n'
        yield '        self.template_thing_two()\n'
        yield '\n'
        yield '    def test_076_gamma(self):\n'
        yield '        self.template_thing_thing()\n'

    def given_client_case(_):
        yield 'class Case1234_wingo_wango(CommonCase):\n'
        yield '\n'
        yield '    def test_222_beta(self):\n'
        yield '        self.i_will_get_overwritten_two()\n'

    def given_template_case(_):
        yield 'class CaseNNNN_wingo_wango(CommonCase):\n'
        yield '\n'
        yield '    def test_025_alpha(self):\n'
        yield '        self.template_thing_one()\n'
        yield '\n'
        yield '    def test_050_beta(self):\n'
        yield '        self.template_thing_two()\n'
        yield '\n'
        yield '    def test_076_gamma(self):\n'
        yield '        self.template_thing_thing()\n'


class Case2506_the_default_directive(CommonCase):  # minimal pair w/ above

    def test_050_ok(self):
        self.expect_expected_output_lines()

    def expected_output_lines(_):
        yield 'class Case1234_wingo_wango(CommonCase):\n'
        yield '\n'
        yield '    def test_025_alpha(self):\n'
        yield '        self.template_thing_one()\n'
        yield '\n'
        yield '    def test_222_beta(self):\n'
        yield '        self.I_AM_SOME_CUSTOM_CLIENT_CODE()\n'
        yield '\n'
        yield '    def test_076_gamma(self):\n'
        yield '        self.template_thing_thing()\n'

    def given_client_case(_):
        yield 'class Case1234_wingo_wango(CommonCase):\n'
        yield '\n'
        yield '    def test_222_beta(self):\n'
        yield '        self.I_AM_SOME_CUSTOM_CLIENT_CODE()\n'
        yield '\n'

    def given_template_case(_):
        yield 'class CaseNNNN_wingo_wango(CommonCase):\n'
        yield '\n'
        yield '    def test_025_alpha(self):\n'
        yield '        self.template_thing_one()\n'
        yield '\n'
        yield '    def test_050_beta(self):\n'
        yield '        # wicked: default\n'
        yield '        self.template_thing_two()\n'
        yield '\n'
        yield '    def test_076_gamma(self):\n'
        yield '        self.template_thing_thing()\n'


class Case2509_the_default_directive_doesnt_come_thru(CommonCase):

    def test_050_ok(self):
        self.expect_expected_output_lines()

    def expected_output_lines(_):
        yield 'class Case1234_wingo_wango(CommonCase):\n'
        yield '\n'
        yield '    def test_050_beta(self):\n'
        yield '        self.template_thing_two()\n'

    def given_client_case(_):
        yield 'class Case1234_wingo_wango(CommonCase):\n'
        yield '    pass\n'

    def given_template_case(_):
        yield 'class CaseNNNN_wingo_wango(CommonCase):\n'
        yield '\n'
        yield '    def test_050_beta(self):\n'
        yield '        # wicked: default\n'
        yield '        self.template_thing_two()\n'


@lazy
def these():
    def case_via_sx(sx):
        return fake_case(*sx[1:])
    dct = {}
    dct['case'] = case_via_sx
    from collections import namedtuple as nt
    fake_case = nt('FakeCase', ('case_num', 'case_key'))
    fake_case.type = 'test_case'
    fake_case.is_plain = False
    return dct


def case_via_lines(lines):
    case, = blocks_via_lines(lines)
    assert 'test_case' == case.type
    return case


# ==

def updated_block(cblock, tblock, listener):
    from modality_agnostic.wicked._updated_case_via_two_cases import \
        updated_case_via_ as func
    return func(cblock, tblock, listener)


def plan_via_three(cblx, tblx, listener):
    func = blocks_module().plan_via_client_and_template_blocks_
    return func(cblx, tblx, listener)


def blocks_via_lines(lines):
    func = blocks_module()._blocks_via_lines
    return func(lines)


def blocks_module():
    import modality_agnostic.wicked._file_DOM_via_lines as module
    return module


if '__main__' == __name__:
    unittest.main()

# #born
