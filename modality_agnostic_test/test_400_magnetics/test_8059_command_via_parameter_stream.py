from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes
import unittest


class CommonCase(unittest.TestCase):

    def function_index_builds(self):
        self.assertIsNotNone(self.function_index)

    @dangerous_memoize_in_child_classes('_OP', 'build_only_parameter')
    def only_parameter(self):
        pass

    def build_only_parameter(self):
        only, = self.function_index.parameters_that_do_not_start_with_underscores  # noqa: E501
        name, param = only
        assert(isinstance(name, str))
        return param

    @dangerous_memoize_in_child_classes('_FI', 'build_function_index')
    def function_index(self):
        pass

    def build_function_index(self):
        _ = self.given_function()
        return subject_module().parameter_index_via_mixed(_)


# head boundary: Case7805


class Case8060_function_with_no_args(CommonCase):

    def test_010_function_index_builds(self):
        self.function_index_builds()

    def test_020_knows_it_has_no_parameters(self):
        self.assertIs(len(self.function_index.parameters_that_do_not_start_with_underscores), 0)  # noqa: E501

    def given_function(self):
        def function():
            pass
        return function


class Case8063_function_with_one_ordinary_arg(CommonCase):

    def test_010_function_index_builds(self):
        self.function_index_builds()

    def test_020_param_knows_it_is_required(self):
        self.assertTrue(self.only_parameter.is_required)

    def given_function(self):
        def function(ohai_hey):
            pass
        return function


class Case8066_function_with_param_made_to_look_optional(CommonCase):

    def test_010_function_index_builds(self):
        self.function_index_builds()

    def test_020_param_knows_it_is_optional(self):
        self.assertFalse(self.only_parameter.is_required)

    def given_function(self):
        def function(not_required=None):
            pass
        return function


# tail boundary: Case8313


def subject_module():
    import modality_agnostic.magnetics.formal_parameter_via_definition as mod
    return mod


if __name__ == '__main__':
    unittest.main()

# #history-A.1: full rewrite
# #born.
