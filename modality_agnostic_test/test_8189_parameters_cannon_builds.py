import unittest


class CommonCase(unittest.TestCase):

    def expect_foo_bar_and_biff_baz_both_required(self):
        (one_name, one_val), (two_name, two_val) = self.build_params()
        assert('foo_bar' == one_name)
        assert('biff_baz' == two_name)
        assert(one_val.is_required)
        assert(two_val.is_required)

    def build_params(self):
        command_module = self.given_command_module(command_modules())
        assert(command_module.PARAMETERS is None)
        from modality_agnostic.magnetics.formal_parameter_via_definition import (  # noqa: E501
                parameter_index_via_mixed)
        _param_index = parameter_index_via_mixed(command_module.Command)
        return _param_index.parameters_that_do_not_start_with_underscores


class Case8186_func_with_two_params(CommonCase):

    def test_010_function_index(self):
        self.expect_foo_bar_and_biff_baz_both_required()

    def given_command_module(self, o):
        return o.two_crude_function_parameters_by_function


class Case8189_class_with_two_params(CommonCase):

    def test_010_function_index(self):
        self.expect_foo_bar_and_biff_baz_both_required()

    def given_command_module(self, o):
        return o.two_crude_function_parameters_by_class


def command_modules():
    from modality_agnostic.test_support.parameters_canon import command_modules
    return command_modules


if __name__ == '__main__':
    unittest.main()

# #history-A.1: full rewrite
# #born.
