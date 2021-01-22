"""this tests only the raw meta-parameters, no integration"""

from modality_agnostic.test_support.common import \
        dangerous_memoize as shared_subject, lazy
import unittest


class CommonCase(unittest.TestCase):

    @property
    def argument_arity_range_(self):
        return self.parameter_.argument_arity_range


class Case7755_default_argument_arity(CommonCase):

    def test_010_magnetic_loads(self):
        self.assertIsNotNone(subject_module())

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


class Case7765_flag_argument_arity_intro(CommonCase):

    def test_020_parameter_builds(self):
        self.assertIsNotNone(self.parameter_)

    def test_040_argument_arity_looks_as_expected(self):
        r = self.argument_arity_range_
        self.assertEqual(0, r.start)
        self.assertEqual(0, r.stop)

    @shared_subject
    def parameter_(self):
        return _build_parameter_via_argument_arity_string('FLAG')


class Case7775_list_argument_arity(CommonCase):

    def test_020_parameter_builds(self):
        self.assertIsNotNone(self.parameter_)

    def test_040_argument_arity_looks_as_expected(self):
        r = self.argument_arity_range_
        self.assertEqual(0, r.start)
        self.assertEqual(None, r.stop)

    @shared_subject
    def parameter_(self):
        return _build_parameter_via_argument_arity_string('OPTIONAL_LIST')


class Case7785_default_value_everything(CommonCase):

    def test_010_by_default_the_default_value_is_none(self):
        _x = _default_value_of_this(_the_totally_empty_parameter())
        self.assertIsNone(_x)

    def test_020_you_can_pass_default_value(self):
        self.assertIsNotNone(self.parameter_)

    def test_030_yuup(self):
        _x = _default_value_of_this(self.parameter_)
        self.assertEqual(123, _x)

    @shared_subject
    def parameter_(self):
        return define(default_value=123)


def _default_value_of_this(para):
    return para.default_value


class Case7795_desc_no_style(CommonCase):

    def test_020_parameter_builds(self):
        self.assertIsNotNone(self.parameter_)

    def test_030_read_back(self):
        _act = _lines_of_description(self.parameter_)
        _exp = ['line 1', 'line 2']
        self.assertEqual(_exp, _act)

    @shared_subject
    def parameter_(self):
        def f(o):
            o('line 1')
            o('line 2')
        return _build_parameter_with_this_description(f)


class Case7805_desc_yes_style(CommonCase):

    def test_020_parameter_builds(self):
        self.assertIsNotNone(self.parameter_)

    def test_030_read_back(self):
        _act = _lines_of_description(self.parameter_)
        _exp = ['line one', 'line *2*']
        self.assertEqual(_exp, _act)

    @shared_subject
    def parameter_(self):
        def f(o, style):
            o('line one')
            o('line '+style.em('2'))
        return _build_parameter_with_this_description(f)


class Case78015_crazy_hack(CommonCase):  # move it to elsewhere if you want to

    def test_010_lines_look_good(self):
        act = self.end_state[0]
        exp = tuple(self.expected_desc_lines())
        self.assertSequenceEqual(act, exp)

    def test_020_param_descs_look_good(self):
        act = self.end_state[1]
        exp_ks = ('notecard_ID', 'verbose')
        self.assertSequenceEqual(tuple(act.keys()), exp_ks)
        import re
        this_rx = re.compile(r'^[^ ].*\n\Z')
        for lines in act.values():
            assert 0 < len(lines)
            assert all(this_rx.match(s) for s in lines)  # ..

    def expected_desc_lines(_):
        yield "Hello I am a command with parameters specific to..\n"
        yield "\n"
        yield "This generates hugo-flavored markdown files from notecards.\n"
        yield "\n"

    @shared_subject
    def end_state(self):
        func = subject_module()._crazy_hack
        lines, pool = func(frobulate_fiz_buzz.__doc__)
        return lines, pool


def frobulate_fiz_buzz(  # a fixture fuction
        collection_path, listener,
        notecard_ID=None,
        verbose: bool = False):

    """Hello I am a command with parameters specific to..

    This generates hugo-flavored markdown files from notecards.

    Args:
        notecard_ID: yy
                     xx
        verbose: The second parameter Verbose output go away as option.
    """

    raise RuntimeError('no run')


def _lines_of_description(param):
    """NOTE - this is a proof of concept for how you should implement this"""

    f = param.description

    def o(line):
        arr.append(line)
    arr = []
    import inspect
    if 2 == len(inspect.signature(f).parameters):
        f(o, _STYLER)
    else:
        f(o)
    return arr


class _STYLER:  # #class-as-namespace
    if True:
        def em(s):
            return '*%s*' % s


# -- some memoized parameters

@lazy
def _the_totally_empty_parameter():
    return define()


# -- build parameter given one meta-parameter

def _build_parameter_with_this_description(f):
    return define(description=f)


def _build_parameter_via_argument_arity_string(s):
    mod = subject_module()
    arity = getattr(mod.arities, s)
    return mod.define(argument_arity=arity)


# --

def define(**kwargs):
    return subject_module().define(**kwargs)


def subject_module():
    from modality_agnostic.magnetics import formal_parameter_via_definition
    return formal_parameter_via_definition


if __name__ == '__main__':
    unittest.main()

# #born.
