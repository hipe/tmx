"""this tests only the raw meta-parameters, no integration"""

import unittest

from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        lazy)


class _CommonCase(unittest.TestCase):

    @property
    def argument_arity_range_(self):
        return self.parameter_.argument_arity_range


class Case7755_default_argument_arity(_CommonCase):

    def test_010_magnetic_loads(self):
        self.assertIsNotNone(_subject_magnetic())

    def test_020_parameter_builds(self):
        self.assertIsNotNone(self.parameter_)

    def test_030_see_the_argument_arity_range(self):
        self.assertIsNotNone(self.argument_arity_range_)

    def test_040_this_argument_arity_range_is_exactly_one(self):
        r = self.argument_arity_range_
        self.assertEqual(1, r.start)
        self.assertEqual(1, r.stop)

    @property
    def parameter_(self):
        return _the_totally_empty_parameter()


class Case7765_flag_argument_arity_intro(_CommonCase):

    def test_020_parameter_builds(self):
        self.assertIsNotNone(self.parameter_)

    def test_040_argument_arity_looks_as_expected(self):
        r = self.argument_arity_range_
        self.assertEqual(0, r.start)
        self.assertEqual(0, r.stop)

    @property
    def parameter_(self):
        return _parameter_with_flag_argument_arity()


class Case7775_list_argument_arity(_CommonCase):

    def test_020_parameter_builds(self):
        self.assertIsNotNone(self.parameter_)

    def test_040_argument_arity_looks_as_expected(self):
        r = self.argument_arity_range_
        self.assertEqual(0, r.start)
        self.assertEqual(None, r.stop)

    @property
    def parameter_(self):
        return _parameter_with_list_argument_arity()


class Case7785_default_value_everything(_CommonCase):

    def test_010_by_default_the_default_value_is_none(self):
        _x = _default_value_of_this(_the_totally_empty_parameter())
        self.assertIsNone(_x)

    def test_020_you_can_pass_default_value(self):
        self.assertIsNotNone(self.parameter_)

    def test_030_yuup(self):
        _x = _default_value_of_this(self.parameter_)
        self.assertEqual(123, _x)

    @property
    @shared_subject
    def parameter_(self):
        return _subject_magnetic()(
                default_value=123,
        )


def _default_value_of_this(para):
    return para.default_value


class Case7795_desc_no_style(_CommonCase):

    def test_020_parameter_builds(self):
        self.assertIsNotNone(self.parameter_)

    def test_030_read_back(self):
        _act = _lines_of_description(self.parameter_)
        _exp = ['line 1', 'line 2']
        self.assertEqual(_exp, _act)

    @property
    @shared_subject
    def parameter_(self):
        def f(o):
            o('line 1')
            o('line 2')
        return _build_parameter_with_this_description(f)


class Case7805_desc_yes_style(_CommonCase):

    def test_020_parameter_builds(self):
        self.assertIsNotNone(self.parameter_)

    def test_030_read_back(self):
        _act = _lines_of_description(self.parameter_)
        _exp = ['line one', 'line *2*']
        self.assertEqual(_exp, _act)

    @property
    @shared_subject
    def parameter_(self):
        def f(o, style):
            o('line one')
            o('line '+style.em('2'))
        return _build_parameter_with_this_description(f)


def _lines_of_description(param):
    """NOTE - this is a proof of concept for how you should implement this"""

    f = param.description

    def o(line):
        arr.append(line)
    arr = []
    import inspect
    if 2 == len(inspect.signature(f).parameters):
        f(o, _styler())
    else:
        f(o)
    return arr


@lazy
def _styler():
    class _STYLER:
        def em(s):
            return '*%s*' % s
    return _STYLER


# -- some memoized parameters

@lazy
def _parameter_with_list_argument_arity():
    return _build_parameter_via_argument_arity_string('OPTIONAL_LIST')


@lazy
def _parameter_with_flag_argument_arity():
    return _build_parameter_via_argument_arity_string('FLAG')


@lazy
def _the_totally_empty_parameter():
    return _subject_magnetic()()


# -- build parameter given one meta-parameter

def _build_parameter_with_this_description(f):
    return _subject_magnetic()(
            description=f,
    )


def _build_parameter_via_argument_arity_string(s):
    _r = getattr(_subject_magnetic_file().arities, s)
    return _subject_magnetic()(
            argument_arity=_r,
    )


# --

def _subject_magnetic():
    return _subject_magnetic_file()


@lazy
def _subject_magnetic_file():
    import modality_agnostic.magnetics.formal_parameter_via_definition as x
    return x


if __name__ == '__main__':
    unittest.main()

# #born.
