"""Disucssion:
This test file is to cover the help subsystem (module) related to the
"engine" CLI system.

Strictly speaking, the "help" subsystem should not have to rely on one
or another particular engine *frontend*, but XX
"""

from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subject_in_children
import unittest


class DocstringCase(unittest.TestCase):

    def go(self):
        itr = subject_module()._one_or_more_lines_via_docstring(
                self.given_doctstring)
        act = tuple(itr)
        exp = tuple(self.expected_lines())
        self.assertSequenceEqual(act, exp)


class Case6012_empty_string(DocstringCase):

    def test_010_is_NO_lines(self):
        self.go()

    def expected_lines(_):
        return ()

    given_doctstring = ""


class Case6016_one_line_no_EOL(DocstringCase):

    def test_010_NORMALIZES_by_adding_EOL(self):
        self.go()

    def expected_lines(_):
        return ("Only one line, no eol\n",)

    given_doctstring = "Only one line, no eol"


class Case6020_line1_line2(DocstringCase):

    def test_010_gets_rid_of_trailing_margin_on_final_semiline(self):
        self.go()

    def expected_lines(_):
        return "Line 1\n", "Line 2\n"

    given_doctstring = """Line 1
    Line 2
    """


class Case6024_cover_this_annoying_case(DocstringCase):
    given_doctstring = """
    Line 2

    Line 4
    """

    def test_010_work(self):
        self.go()

    def expected_lines(_):
        return "Line 2\n", "Line 4\n"


class Case6028_PEP_0257_blank_line(DocstringCase):

    def test_010_normalizes_out_blank_line(self):
        self.go()

    def expected_lines(_):
        return "Line 1\n", "Line 3\n"

    given_doctstring = """Line 1

    Line 3
    """


class IntegrationCase(unittest.TestCase):

    # Things to test

    @property
    @shared_subject_in_children
    def parsed_help_screen(self):
        lines = self.output_lines
        from script_lib.test_support.expect_help_screen import \
                parse_help_screen as func
        return func(lines, do_it_the_new_way=True)

    @property
    def output_lines(self):
        return self.end_state['stderr_lines']

    @property
    def returncode(self):
        return self.end_state['returncode']

    @property
    @shared_subject_in_children
    def end_state(self):
        return {k:v for k, v in self.build_end_state()}

    def build_end_state(self):
        argv = '/foo/bar/some-prog-name.py', 'value_1', self.given_help_token
        usage_lines=("usage: {{prog_name}} [-n] [--force] ARG1 [ARG2]\n",)
        big_s = I_am_a_pretend_business_function_command.__doc__

        from script_lib.test_support.expect_STDs import \
                pretend_STDIN_via_mixed as func, \
                spy_on_write_and_lines_for as spy

        sin = func('FAKE_STDIN_INTERACTIVE')
        sout, sout_lines = spy(self, 'SOUT: ')
        serr, serr_lines = spy(self, 'SERR: ')

        invo = higher_level_module().build_invocation(
                sin, sout, serr, argv, usage_lines=usage_lines,
                docstring_for_help_description=big_s)
        rc, pt = invo.returncode_or_parse_tree()
        yield 'returncode', rc
        # yield 'stdout_lines', tuple(sout_lines)
        assert 0 == len(sout_lines)
        yield 'stderr_lines', tuple(serr_lines)

    given_help_token = '--help'
    do_debug = False


class Case6032_integration_ONE(IntegrationCase):

    def test_010_returncode_of_HELP_is_zero(self):
        self.assertEqual(0, self.returncode)

    def test_010_has_usage_line(self):
        assert self.parsed_help_screen['usage']

    def test_020_has_description_section_of_two_lines(self):
        sect = self.parsed_help_screen['description']
        assert 1 == len(tuple(sect.to_body_lines()))

    given_help_token = '-h'


def I_am_a_pretend_business_function_command():
    """Foo La La line one.

    This thing is really great. It does stuff that's fanstastic.
    """
    pass


def higher_level_module():
    import script_lib.via_usage_line as mod
    return mod


def subject_module():
    import script_lib.magnetics.help_lines_via_invocation as mod
    return mod


if '__main__' ==  __name__:
    unittest.main()

# #born
