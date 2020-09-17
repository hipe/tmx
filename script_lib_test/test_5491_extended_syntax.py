from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes
import unittest


class ExtendedSyntaxCase(unittest.TestCase):

    # -- assertions

    def expect_sequence_equals_recursive(self, ast, exp):
        from script_lib.test_support import assert_sequence_equals_recursive
        return assert_sequence_equals_recursive(ast, exp, self)

    # -- getters for assertions

    @property
    def the_last_opt(self):
        return self.the_CLI.opts[-1]

    @property
    def the_last_arg(self):
        return self.the_CLI.args[-1]

    # -- build end state

    def parse_against(self, *argv_tail):
        if self.do_debug:
            from sys import stderr
            serr = stderr
        else:
            serr = None
        opts_args, mon = self._my_run(serr, argv_tail)
        assert(mon.OK)
        assert(0 == mon.exitstatus)
        return opts_args

    def parse_expecting_failure(self, *argv_tail):
        from script_lib.test_support import lines_and_spy_io_for_test_context
        lines, spy_stderr = lines_and_spy_io_for_test_context(self, 'DBG: ')
        opts_args, mon = self._my_run(spy_stderr, argv_tail)

        assert(opts_args is None)
        assert(not mon.OK)
        assert(mon.exitstatus is not 0)

        return tuple(lines)

    def _my_run(self, serr, argv_tail):
        argv = ('/x/y/ya-eomma', *argv_tail)
        CLI = self.the_CLI
        from script_lib.cheap_arg_parse import _parse_CLI_args
        opts_args, mon = _parse_CLI_args(serr, argv, CLI)
        return opts_args, mon

    @dangerous_memoize_in_child_classes('_CLI', 'build_CLI')
    def the_CLI(self):
        pass

    def build_CLI(self):
        from script_lib.cheap_arg_parse import (
                CLI_via_syntax_AST_,
                syntax_AST_via_parameters_definition_)
        _pdef = self.given_formal_parameters()
        _syntax_AST = syntax_AST_via_parameters_definition_(_pdef)
        return CLI_via_syntax_AST_(_syntax_AST)

    do_debug = False


class Case5485_kleene_star_arg_cannot_be_at_not_the_end(ExtendedSyntaxCase):

    def test_010_raises(self):
        _exp = "plural positional args can only occur at the end: 'foo-bar*'"
        from script_lib.cheap_arg_parse import FormalParametersSyntaxError
        with self.assertRaises(FormalParametersSyntaxError) as cm:
            self.build_CLI()
        exe = cm.exception
        self.assertEqual(str(exe), _exp)

    def given_formal_parameters(self):
        return (('foo-bar*', 'x'), ('biff-bazz', 'x'))


class Case5486_kleene_star_at_end(ExtendedSyntaxCase):

    def test_010_builds(self):
        self.assertIsNotNone(self.the_CLI)

    def test_020_item_looks_right(self):
        arg = self.the_last_arg
        self.assertTrue(arg.is_plural)
        self.assertEqual(arg.arity_string, '*')

    def test_030_parse_multiple(self):
        opts, args = self.parse_against('A', 'B', 'C')
        assert(not len(opts))
        _exp = ('A', ('B', 'C'))
        self.expect_sequence_equals_recursive(args, _exp)

    def test_040_parse_one(self):
        opts, args = self.parse_against('A')
        assert(not len(opts))
        _exp = ('A', ())
        self.expect_sequence_equals_recursive(args, _exp)

    def given_formal_parameters(self):
        return (('foo-bar', 'x'), ('biff-bazz*', 'x'))


class Case5488_kleene_plus_at_end(ExtendedSyntaxCase):

    def test_010_builds(self):
        self.assertIsNotNone(self.the_CLI)

    def test_020_item_looks_right(self):
        arg = self.the_last_arg
        self.assertTrue(arg.is_plural)
        self.assertEqual(arg.arity_string, '+')

    def test_030_parse_multiple(self):
        opts, args = self.parse_against('A', 'B', 'C')
        assert(not len(opts))
        _exp = (('A', 'B', 'C'),)
        self.expect_sequence_equals_recursive(args, _exp)

    def test_040_parse_one(self):
        opts, args = self.parse_against('A')
        assert(not len(opts))
        _exp = (('A',),)
        self.expect_sequence_equals_recursive(args, _exp)

    def test_050_missing_required(self):
        lines = self.parse_expecting_failure()
        reason_line, invite_line = lines
        self.assertIn('expecting <foo-bar>', reason_line)

    def given_formal_parameters(self):
        return (('foo-bar+', 'x'),)  # #cp-2


class Case5489_flag_with_kleene_star(ExtendedSyntaxCase):

    def test_010_builds(self):
        self.assertIsNotNone(self.the_CLI)

    def test_020_item_looks_right(self):
        opt = self.the_last_opt
        self.assertFalse(opt.takes_argument)
        self.assertTrue(opt.is_plural)
        self.assertEqual(opt.arity_string, '*')

    def test_030_parse_one_long(self):
        opts, args = self.parse_against('--foo-bar')
        assert(not len(args))
        self.assertSequenceEqual(opts, (1,))

    def test_050_parse_several_short_in_flagball(self):
        opts, args = self.parse_against('-ff')
        assert(not len(args))
        self.assertSequenceEqual(opts, (2,))

    def test_060_parse_none(self):
        # NOTE if no opts it's None not empty tuple
        opts, args = self.parse_against()
        assert(not len(args))
        self.assertSequenceEqual(opts, (None,))

    def given_formal_parameters(self):
        return (('-f', '--foo-bar*', 'x'),)


class Case5491_optional_field_with_kleene_star(ExtendedSyntaxCase):

    def test_010_builds(self):
        self.assertIsNotNone(self.the_CLI)

    def test_020_item_looks_right(self):
        opt = self.the_last_opt
        self.assertTrue(opt.takes_argument)
        self.assertTrue(opt.is_plural)
        self.assertEqual(opt.arity_string, '*')

    def test_030_parse_one(self):
        opts, args = self.parse_against('--foo-bar', 'A')
        assert(not len(args))
        _exp = (('A',),)
        self.expect_sequence_equals_recursive(opts, _exp)

    def test_040_parse_several(self):
        opts, args = self.parse_against('--foo-bar=B', '--foo-bar', 'C')
        assert(not len(args))
        _exp = (('B', 'C'),)
        self.expect_sequence_equals_recursive(opts, _exp)

    def test_050_parse_nothing(self):
        # NOTE if no opts it's None not empty tuple
        opts, args = self.parse_against()
        assert(not len(args))
        self.assertSequenceEqual(opts, (None,))

    def given_formal_parameters(self):
        return (('--foo-bar=X*', 'x'),)


class Case5492_integrate_plural_optional_field_with_glob(ExtendedSyntaxCase):

    def test_010_builds(self):
        self.assertIsNotNone(self.the_CLI)

    def test_030_parse_options_within_glob(self):
        opts, args = self.parse_against(
                '-oA', 'B', '--opt-ario', 'C', 'D', '-o', 'E')
        self.expect_sequence_equals_recursive(args, (('B', 'D'),))
        self.expect_sequence_equals_recursive(opts, (('A', 'C', 'E'),))

    def given_formal_parameters(self):
        return (('-o', '--opt-ario=V*', 'x'), ('biff-bazz*', 'x'))


class Case5494_exclamation_point_cannot_be_used_on_flags(ExtendedSyntaxCase):

    def test_010_raises(self):
        _ = "'!' cannot be used on flags, only optional fields ('--foo-bar')"
        from script_lib.cheap_arg_parse import FormalParametersSyntaxError
        with self.assertRaises(FormalParametersSyntaxError) as cm:
            self.build_CLI()
        exe = cm.exception
        self.assertEqual(str(exe), _)

    def given_formal_parameters(self):
        return (('--foo-bar!', 'x'),)


class Case5495_optional_field_can_have_exclamation_point(ExtendedSyntaxCase):

    def test_010_builds(self):
        self.assertIsNotNone(self.the_CLI)

    def test_020_item_looks_right(self):
        opt = self.the_last_opt
        self.assertTrue(opt.takes_argument)
        self.assertFalse(opt.is_plural)
        self.assertEqual(opt.arity_string, '!')

    def test_030_regular(self):
        opts, args = self.parse_against('--foo-bar', 'A')
        assert(not len(args))
        _exp = ('A',)
        self.expect_sequence_equals_recursive(opts, _exp)

    def test_040_clobber(self):
        opts, args = self.parse_against('--foo-bar=B', '--foo-bar', 'C')
        assert(not len(args))
        _exp = ('C',)
        self.expect_sequence_equals_recursive(opts, _exp)

    def test_050_missing_required(self):
        lines = self.parse_expecting_failure()
        reason_line, invite_line = lines
        self.assertIn("'--foo-bar' is required", reason_line)

    # does not show up in help screen

    def given_formal_parameters(self):
        return (('--foo-bar=X!', 'x'),)


# stop: Case5498


if __name__ == '__main__':
    unittest.main()

# #born.
