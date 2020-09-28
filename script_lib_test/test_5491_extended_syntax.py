from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subj_in_children, lazy
import unittest
import re


# [Case5485 - Case5498)


class ExtendedSyntaxCase(unittest.TestCase):

    # -- assertions

    def expect_first_line_ignorecase(self, rxs):
        act_line = self.end_state.lines[0]
        self.assertRegex(act_line, re.compile(rxs, re.IGNORECASE))

    def expect_exitstatus(self, exp):
        act = self.end_state.exitstatus
        self.assertEqual(act, exp)

    def expect_invite(self):
        act_line = self.end_state.lines[-1]
        self.assertRegex(act_line, r'\bfor help\b')

    def expect_expected_values(self):
        act = self.end_state.values
        exp = self.expected_values()
        act_ks, exp_ks = tuple(tuple(d.keys()) for d in (act, exp))
        act_vs, exp_vs = tuple(tuple(d.values()) for d in (act, exp))
        self.assertSequenceEqual(act_ks, exp_ks)
        self.assertSequenceEqual(act_vs, exp_vs)

    def expect_the_formals_parse_OK(self):
        self.assertTrue(self.formals())

    # -- getters for assertions

    @property
    def the_last_arg(self):
        return self.formals().formal_positionals[-1]

    # -- build end state

    @property  # ..
    @shared_subj_in_children
    def end_state(self):
        argv = self.given_argv_tail()
        return self.build_end_state_via_argv_tail(argv)

    def build_end_state_via_argv_tail(self, argv_tail):

        # Prepare the stderr proxy (either for expecting nothing or something)
        exps = self.expected_lines()
        import script_lib.test_support.expect_STDs as lib
        _, serr, done = lib.stdout_and_stderr_and_done_via(exps or (), self)

        # Call our subject under test
        bash_argv = list(reversed(argv_tail))
        foz = self.formals()
        vals, es = foz.terminal_parse(serr, bash_argv)
        writes = done()

        # Simplify the recorded writes
        def my_assert(which):
            assert 'STDERR' == which
            return True
        lines = tuple(line for which, line in writes if my_assert(which))

        return _EndState(vals, lines, es, foz)

    @shared_subj_in_children
    def formals(self):
        return subject_function(self.given_formal_parameters())

    def expected_lines(_):
        pass

    do_debug = False


class Case5485_glob_cannot_be_at_not_the_end(ExtendedSyntaxCase):

    def test_010_raises(self):
        eclass = subject_exception_class()
        with self.assertRaises(eclass) as cm:
            self.formals()
        rxs = r"\bcan only occur at(?: the)? end: 'foo-bar\*'"
        self.assertRegex(str(cm.exception), re.compile(rxs, re.IGNORECASE))

    def given_formal_parameters(self):
        return (('foo-bar*', 'x'), ('biff-baz', 'x'))


class Case5486_1_glob_against_many(ExtendedSyntaxCase):

    def test_010_builds(self):
        self.expect_the_formals_parse_OK()

    def test_020_item_looks_right(self):
        arg = self.the_last_arg
        self.assertTrue(arg.is_plural)
        self.assertFalse(arg.is_required)

    def test_030_expect_expected(self):
        self.expect_expected_values()

    def given_argv_tail(_):
        return 'A', 'B', 'C'

    def formals(_):
        return case_5486_formals()

    def expected_values(_):
        return {'foo_bar': 'A', 'biff_baz': ('B', 'C')}


class Case5486_2_glob_against_none(ExtendedSyntaxCase):

    def test_030_note_it_is_NOT_auto_populated_with_an_empty_tuple(self):
        self.expect_expected_values()

    def given_argv_tail(_):
        return ('A',)

    def formals(_):
        return case_5486_formals()

    def expected_values(_):
        return {'foo_bar': 'A'}


@lazy
def case_5486_formals():
    return subject_function((('foo-bar', 'x'), ('biff-baz*', 'x')))


class Case5487_required_glob_missing(ExtendedSyntaxCase):

    def test_030_says_this_thing(self):
        rxs = 'expecting <foo-bar>'
        self.expect_first_line_ignorecase(rxs)

    def test_040_emits_this_exitsatus(self):
        self.expect_exitstatus(6)

    def test_050_expect_invite(self):
        self.expect_invite()

    def given_argv_tail(_):
        return ()

    def formals(_):
        return case_5488_formals()

    def expected_lines(_):
        yield 'STDERR'
        yield 'zero_or_one', 'STDERR'


class Case5488_1_required_glob_against_many(ExtendedSyntaxCase):

    def test_010_builds(self):
        self.expect_the_formals_parse_OK()

    def test_020_item_looks_right(self):
        arg = self.the_last_arg
        self.assertTrue(arg.is_plural)
        self.assertTrue(arg.is_required)

    def test_030_expect_expected(self):
        self.expect_expected_values()

    def given_argv_tail(_):
        return 'A', 'B', 'C'

    def formals(_):
        return case_5488_formals()

    def expected_values(_):
        return {'foo_bar': ('A', 'B', 'C')}


class Case5488_2_required_glob_against_one(ExtendedSyntaxCase):

    def test_030_expect_expected(self):
        self.expect_expected_values()

    def given_argv_tail(_):
        return ('A',)

    def formals(_):
        return case_5488_formals()

    def expected_values(_):
        return {'foo_bar': ('A',)}


@lazy
def case_5488_formals():
    return subject_function((('<foo-bar>+', 'x'),))


class Case5489_1_kleene_star_flag_against_one_long(ExtendedSyntaxCase):

    def test_010_builds(self):
        self.expect_the_formals_parse_OK()

    def test_020_item_looks_right(self):
        opt = self.formals().formal_options[0]
        self.assertFalse(opt.takes_argument)
        self.assertTrue(opt.is_plural)
        self.assertFalse(opt.is_required)

    def test_010_expect_expected(self):
        self.expect_expected_values()

    def given_argv_tail(_):
        return ('--foo-bar',)

    def formals(_):
        return case_5489_formals()

    def expected_values(_):
        return {'foo_bar': 1}


class Case5489_2_kleene_star_flag_against_flagball(ExtendedSyntaxCase):

    def test_010_expect_expected(self):
        self.expect_expected_values()

    def given_argv_tail(_):
        return '-ff',

    def formals(_):
        return case_5489_formals()

    def expected_values(_):
        return {'foo_bar': 2}


class Case5489_3_kleene_star_flag_against_none(ExtendedSyntaxCase):

    def test_010_expect_expected(self):
        self.expect_expected_values()

    def given_argv_tail(_):
        return ()

    def formals(_):
        return case_5489_formals()

    def expected_values(_):
        return {}


@lazy
def case_5489_formals():
    return subject_function((('-f', '--foo-bar*', 'x'),))


# Case5490 available


class Case5491_1_kleene_star_argumented_option_against_one(ExtendedSyntaxCase):

    def test_010_builds(self):
        self.expect_the_formals_parse_OK()

    def test_020_item_looks_right(self):
        opt = self.formals().formal_options[0]
        self.assertTrue(opt.takes_argument)
        self.assertTrue(opt.is_plural)
        self.assertFalse(opt.is_required)

    def given_argv_tail(_):
        return '--foo-bar', 'A'

    def formals(_):
        return case_5491_formals()

    def expected_values(_):
        return {'foo_bar': ['A']}


class Case5491_2_kleene_star_argumented_option_against_two(ExtendedSyntaxCase):

    def test_010_expect_expected(self):
        self.expect_expected_values()

    def given_argv_tail(_):
        return '--foo-bar=B', '--foo-bar', 'C'

    def formals(_):
        return case_5491_formals()

    def expected_values(_):
        return {'foo_bar': ['B', 'C']}


class Case5491_3_kleene_star_argumented_option_against_nil(ExtendedSyntaxCase):

    def test_010_expect_expected(self):
        self.expect_expected_values()

    def given_argv_tail(_):
        return ()

    def formals(_):
        return case_5491_formals()

    def expected_values(_):
        return {}


@lazy
def case_5491_formals():
    return subject_function((('--foo-bar=X*', 'x'),))


# Case5493 available - maybe for kleene plus argumented option


class Case5493_integrate_plural_optional_field_with_glob(ExtendedSyntaxCase):

    def test_010_builds(self):
        self.expect_the_formals_parse_OK()

    def test_020_parses_options_interspersed_with_glob(self):
        self.expect_expected_values()

    def given_argv_tail(_):
        return '-oA', 'B', '--opt-ario', 'C', 'D', '-o', 'E'

    def given_formal_parameters(_):
        yield '-o', '--opt-ario=V*', 'x'
        yield 'biff-baz*', 'x'

    def expected_values(_):
        return {'opt_ario': ['A', 'C', 'E'], 'biff_baz': ('B', 'D')}


class Case5494_exclamation_point_cannot_be_used_on_flags(ExtendedSyntaxCase):

    def test_010_raises(self):
        eclass = subject_exception_class()
        with self.assertRaises(eclass) as cm:
            self.formals()
        rxs = r"'!' cannot be used on flags\b.+Had:? '--foo-bar!'"
        self.assertRegex(str(cm.exception), re.compile(rxs, re.IGNORECASE))

    def given_formal_parameters(self):
        return (('--foo-bar!', 'x'),)


class Case5495_missing_required_optionals(ExtendedSyntaxCase):
    # This weird form allows you to model a field that looks like an option
    # but has the imperity of a regular positional argument. This facility
    # exists to make input buffers more readable (albeit longer) and less
    # error-prone, if you have many required parameters (imagine entities).
    # ("three" feels like the max of regular positional formals you want.)

    def test_010_formals_build(self):
        self.expect_the_formals_parse_OK()

    def test_020_item_looks_right(self):
        opt = self.formals().formal_options[1]  # or 0. #here1
        self.assertTrue(opt.takes_argument)
        self.assertFalse(opt.is_plural)
        self.assertTrue(opt.is_required)

    def test_030_says_this_thing(self):
        rxs = "'--foo-bar' and '--biff-baz' are required"
        self.expect_first_line_ignorecase(rxs)

    def test_040_emits_this_exitsatus(self):
        self.expect_exitstatus(7)

    def test_050_expect_invite(self):
        self.expect_invite()

    def given_argv_tail(_):
        return '--wee', 'no see'

    def given_formal_parameters(_):
        yield '--foo-bar=X!', 'ns'
        yield '--biff-baz=X!', 'ns'  # #here1
        yield '--wee=X', 'ns'

    def expected_lines(_):
        yield 'STDERR'
        yield 'zero_or_one', 'STDERR'


class Case5496_1_required_optional_parses(ExtendedSyntaxCase):

    def test_010_builds(self):
        self.expect_the_formals_parse_OK()

    def given_argv_tail(_):
        return '--foo-bar', 'A'

    def formals(_):
        return case_5496_formals()

    def expected_values(_):
        return {'foo_bar': 'A'}


class Case5496_2_required_optional_clobbers(ExtendedSyntaxCase):

    def test_010_expect_expected(self):
        self.expect_expected_values()

    def given_argv_tail(_):
        return '--foo-bar=B', '--foo-bar', 'C'

    def formals(_):
        return case_5496_formals()

    def expected_values(_):
        return {'foo_bar': 'C'}


# does not show up in help screen


@lazy
def case_5496_formals():
    return subject_function((('--foo-bar=X!', 'x'),))


# stop: Case5498


class _EndState:
    def __init__(o, vals, lines, es, foz):
        o.values, o.lines, o.exitstatus, o.formals = vals, lines, es, foz


def subject_function(defs):
    func = subject_module().formals_via_definitions
    return func(defs, lambda: '/x/y/ya-eomma')  # no idea what "ya-eomma" is


def subject_exception_class():
    return subject_module().DefinitionError_


def subject_module():
    import script_lib.cheap_arg_parse as module
    return module


if __name__ == '__main__':
    unittest.main()

# #history-B.1 during blind rewrite. exemplary cleanup
# #born.
