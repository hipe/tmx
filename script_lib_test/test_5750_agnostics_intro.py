import unittest


class CommonCase(unittest.TestCase):

    def expect_expected(self):
        actual_CLI_formals = tuple(self.build_CLI_formal_parameters())
        expect_CLI_formals = tuple(self.expect_these())

        _leng = max(len(actual_CLI_formals), len(expect_CLI_formals))

        for i in range(0, _leng):
            _actual_formal = actual_CLI_formals[i]
            _expect_formal = expect_CLI_formals[i]
            self.assertSequenceEqual(_actual_formal, _expect_formal)

    def build_stdout_lines_when_expecting_success(self):

        _argv = ('/fake-fs/annyong-amma', *self.given_argv_tail())

        from script_lib.test_support import lines_and_spy_io_for_test_context
        lines, sout = lines_and_spy_io_for_test_context(self, 'DEBUG SOUT: ')

        if self.do_debug:
            _, serr = lines_and_spy_io_for_test_context(self, 'DEBUG SERR: ')
        else:
            serr = None

        es = CLI(None, sout, serr, _argv)
        assert(0 == es)
        return tuple(lines)

    def build_CLI_formal_parameters(self):

        def these():
            for param in self.given_formal_parameters():
                cat_which = _cat_which_via_desc(param.description)
                use_normal_name = f"{cat_which.replace(' ', '_')}_param"
                yield (use_normal_name, param)

        from script_lib.magnetics.CLI_formal_parameters_via_formal_parameters import (  # noqa: E501
                CLI_formal_parameters_via_formal_parameters)

        return CLI_formal_parameters_via_formal_parameters(these())

    def given_formal_parameters(self):
        return (self.given_formal_parameter(),)

    do_debug = False


class Case5740_category_4_required_field(CommonCase):

    def test_010_expect_the_expected(self):
        self.expect_expected()

    def expect_these(self):
        return (('cat-4-param', 'desc for cat 4'),)

    def given_formal_parameter(self):
        return formal_parameter_for('REQUIRED_FIELD', 'cat 4')


class Case5743_category_2_optional_field(CommonCase):

    def test_010_expect_the_expected(self):
        self.expect_expected()

    def expect_these(self):
        return (('--cat-2-param=PARAM', 'desc for cat 2'),)

    def given_formal_parameter(self):
        return formal_parameter_for('OPTIONAL_FIELD', 'cat 2')


class Case5747_category_1_flag(CommonCase):

    def test_010_expect_the_expected(self):
        self.expect_expected()

    def expect_these(self):
        return (('--cat-1-param', 'desc for cat 1'),)

    def given_formal_parameter(self):
        return formal_parameter_for('FLAG', 'cat 1')


class Case5750_category_5_required_list(CommonCase):  # #midpoint

    def test_010_expect_the_expected(self):
        self.expect_expected()

    def expect_these(self):
        return (('cat-5-param+', 'desc for cat 5'),)

    def given_formal_parameter(self):
        return formal_parameter_for('REQUIRED_LIST', 'cat 5')


class Case5753_category_3_optional_list(CommonCase):

    def test_010_expect_the_expected(self):
        self.expect_expected()

    def expect_these(self):
        return (('cat-3-param*', 'desc for cat 3'),)

    def given_formal_parameter(self):
        return formal_parameter_for('OPTIONAL_LIST', 'cat 3')


class Case5756_N_number_is_too_many_positionals(CommonCase):

    def test_010_expect_the_expected(self):
        self.expect_expected()

    def expect_these(self):
        yield ('--arg-1-param=PARAM!', 'desc for arg 1')  # NOTE exclamation
        yield ('arg-2-param', 'desc for arg 2')
        yield ('arg-3-param', 'desc for arg 3')
        yield ('arg-4-param', 'desc for arg 4')

    def given_formal_parameters(self):
        yield formal_parameter_for('REQUIRED_FIELD', 'arg 1')
        yield formal_parameter_for('REQUIRED_FIELD', 'arg 2')
        yield formal_parameter_for('REQUIRED_FIELD', 'arg 3')
        yield formal_parameter_for('REQUIRED_FIELD', 'arg 4')


class Case5759_there_can_only_be_one_glob(CommonCase):

    def test_010_expect_the_expected(self):
        self.expect_expected()

    def expect_these(self):
        yield ('--arg-1-param', 'desc for arg 1')
        yield ('--arg-2-param=PARAM*', 'desc for arg 2')
        yield ('--arg-3-param=PARAM+', 'desc for arg 3')
        yield ('arg-4-param*', 'desc for arg 4')

    def given_formal_parameters(self):
        yield formal_parameter_for('FLAG', 'arg 1')
        yield formal_parameter_for('OPTIONAL_LIST', 'arg 2')
        yield formal_parameter_for('REQUIRED_LIST', 'arg 3')
        yield formal_parameter_for('OPTIONAL_LIST', 'arg 4')


def formal_parameter_for(type_s, cat_which):  # #todo move me
    import modality_agnostic.magnetics.formal_parameter_via_definition as param
    return param.define(
            description=f'desc for {cat_which}',
            argument_arity=type_s)


def _cat_which_via_desc(description):
    import re
    md = re.match(r'desc for (.+)$', description)
    return md[1]


class Case5762_big_run(CommonCase):

    def test_010_big_run(self):
        _exp = ('here is foo bar: "aa"\n',
                'here is biff baz: "bb"\n')
        _act = self.build_stdout_lines_when_expecting_success()
        self.assertSequenceEqual(_act, _exp)

    def given_argv_tail(self):
        return ('thing-one', 'aa', 'bb')


# == BEGIN

def CLI(sin, sout, serr, argv):
    from script_lib.cheap_arg_parse_branch import cheap_arg_parse_branch

    def children():
        yield 'thing-one', load_thing_one
        yield 'thing-two', load_thing_two

    return cheap_arg_parse_branch(sin, sout, serr, argv, children())


def load_thing_one():
    def name(o):
        return o.two_crude_function_parameters_by_function
    return CLI_function_via(name)


def load_thing_two():
    def name(o):
        return o.two_crude_function_parameters_by_class
    return CLI_function_via(name)


def CLI_function_via(command_moduler):
    from modality_agnostic.test_support.parameters_canon import command_modules
    _command_module = command_moduler(command_modules)
    from script_lib.magnetics.CLI_formal_parameters_via_formal_parameters import (  # noqa: E501
            CLI_function_via_command_module)
    return CLI_function_via_command_module(_command_module)

# == END


# tail boundary: (Case5844)


if __name__ == '__main__':
    # import sys as o
    # exit(CLI(o.stdin, o.stdout, o.stderr, o.argv))
    unittest.main()

# #born
