"""modality agnostic. reconcile parameter detail with function parameters.
"""
import os, sys, unittest

# boilerplate
_ = os.path
path = _.dirname(_.dirname(_.dirname(_.abspath(__file__))))
a = sys.path
if a[0] != path:
    a.insert(0, path)
# end boilerplate


import game_server
memoize = game_server.memoize


class _CommonCase(unittest.TestCase):

    # -- assertions (all)

    def _these_two(self, cmd):
        self._expect_these(['foo_bar', 'biff_baz'], cmd)

    def _expect_these(self, names, cmd):
        _exp = [ x for x in cmd.formal_parameter_dictionary.keys() ]  # flatten view
        self.assertEqual(names, _exp)

    def _this_builds(self, x):
        self.assertIsNotNone(x)

    def _raises(self, msg, f):
        # #todo - idiomize this for the test platform
        exe = None
        try:
            f()
        except game_server.Exception as e:
            exe = e
        _act = str(exe)
        self.assertEqual(msg, _act)


class Case010_build_and_see_component_names(_CommonCase):

    def test_010_class_only_builds(self):
        self._this_builds(_command_modules().two_crude_function_parameters_by_class())

    def test_020_function_only_builds(self):
        self._this_builds(_command_modules().two_crude_function_parameters_by_function())

    def test_030_first_has_those_two(self):
        self._these_two(_command_modules().two_crude_function_parameters_by_class())

    def test_040_first_has_those_two(self):
        self._these_two(_command_modules().two_crude_function_parameters_by_function())

    def test_050_one_detailed_inside_one_outside_ERRORS(self):
        _exp = ('this/these parameter detail(s) must have ' +
            'corresponding function parameters: (boozo_bozzo, biffo)')
        self._raises(_exp, _command_modules().one_inside_one_outside_NOT_MEMOIZED)

    def test_060_dont_do_defaults(self):
        _exp = "for 'fez_boz' use details to express a default"
        self._raises(_exp, _command_modules().dont_do_defaults_NOT_MEMOIZED)

    def test_070_dont_do_strange_shaped_params(self):
        _exp = "'kw_arggos' must be of kind POSITIONAL_OR_KEYWORD (had VAR_KEYWORD)"
        self._raises(_exp, _command_modules().weird_parameter_shape_NOT_MEMOIZED)


@memoize
def _command_modules():
    from game_server_test.parameters_canon import command_modules as x
    return x


if __name__ == '__main__':
    unittest.main()

# #born.
