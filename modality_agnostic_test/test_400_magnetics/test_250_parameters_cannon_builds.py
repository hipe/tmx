"""modality agnostic. reconcile parameter detail with function parameters.


(NOTE about placement:
  - this test placement doesn't isomorph with a magnetic.
  - this test is placed for regression friendliness
  - in fact it should be under the test_support counterpart node, but etc
"""

import unittest


class _CommonCase(unittest.TestCase):

    # -- assertions (all)

    def _these_two(self, cmd):
        self._expect_these(['foo_bar', 'biff_baz'], cmd)

    def _expect_these(self, names, cmd):
        # flatten view:
        _exp = [x for x in cmd.formal_parameter_dictionary.keys()]
        self.assertEqual(names, _exp)

    def _this_builds(self, x):
        self.assertIsNotNone(x)

    def _raises(self, msg, f):
        # #todo - idiomize this for the test platform
        import modality_agnostic
        exe = None
        try:
            f()
        except modality_agnostic.Exception as e:
            exe = e
        _act = str(exe)
        self.assertEqual(msg, _act)


class Case8189_build_and_see_component_names(_CommonCase):

    def test_010_class_only_builds(self):
        _ = _command_modules().two_crude_function_parameters_by_class()
        self._this_builds(_)

    def test_020_function_only_builds(self):
        _ = _command_modules().two_crude_function_parameters_by_function()
        self._this_builds(_)

    def test_030_first_has_those_two(self):
        _ = _command_modules().two_crude_function_parameters_by_class()
        self._these_two(_)

    def test_040_first_has_those_two(self):
        _ = _command_modules().two_crude_function_parameters_by_function()
        self._these_two(_)

    def test_050_one_detailed_inside_one_outside_ERRORS(self):
        _exp = ('this/these parameter detail(s) must have ' +
                'corresponding function parameters: (boozo_bozzo, biffo)')
        _act = _command_modules().one_inside_one_outside_NOT_MEMOIZED
        self._raises(_exp, _act)

    def test_060_dont_do_defaults(self):
        _exp = "for 'fez_boz' use details to express a default"
        self._raises(_exp, _command_modules().dont_do_defaults_NOT_MEMOIZED)

    def test_070_dont_do_strange_shaped_params(self):
        _exp = "'kw_arggos' must be of kind POSITIONAL_OR_KEYWORD (had VAR_KEYWORD)"  # noqa E501
        _act = _command_modules().weird_parameter_shape_NOT_MEMOIZED
        self._raises(_exp, _act)


def _command_modules():
    from modality_agnostic.test_support.parameters_canon import (
            command_modules as x)
    return x


if __name__ == '__main__':
    unittest.main()

# #born.
