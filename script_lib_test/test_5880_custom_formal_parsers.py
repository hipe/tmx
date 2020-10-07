from modality_agnostic.test_support.common import \
        dangerous_memoize as shared_subject
import unittest


class CommonCase(unittest.TestCase):

    def build_end_state_expecting_success(self):
        foz = self.build_formals()
        argv = self.given_argv()
        from script_lib.test_support.expect_STDs import \
            spy_on_write_and_lines_for as func
        serr, lines = func(self, 'DBG: ')
        vals, es = foz.terminal_parse(serr, list(reversed(argv)))
        assert es is None
        assert 0 == len(lines)
        return vals

    def build_formals(self):
        foz_defs = self.given_formals()
        return subject_module().formals_via_definitions(foz_defs, lambda: 'lets-dance')  # noqa: E501

    do_debug = False


class Case5472_help_screen(CommonCase):

    def test_050_does_not_dereference_your_custom_parser(self):
        assert self.end_state_lines

    def test_100_in_usage_section(self):
        act, = self.help_screen.section_via_key('usage').lines
        self.assertEqual(act, 'usage: lets-dance [-<digit>] [-h]\n')

    def test_150_in_options_section(self):
        act = next(self.help_screen.section_via_key('options').to_body_lines())
        self.assertRegex(act, '^[ ]{2,}-<digit>[ ]{2,}ziff zaff$')

    @shared_subject
    def help_screen(self):
        return EHS().parse_help_screen(self.end_state_lines)

    @shared_subject
    def end_state_lines(self):
        foz = self.build_formals()
        lines = foz.help_lines("desco\n  desco line 2\n  ")
        return tuple(lines)

    def given_formals(self):
        yield '-<digit>', lambda: self.fail('nope'), 'ziff zaff'
        yield '-h', '--help', 'thizzo scrizzo'


class Case5474_money(CommonCase):

    def test_050_yes_parse(self):
        vals = self.build_end_state_expecting_success()
        assert 123 == vals['digit']

    def given_argv(_):
        return '-123',

    def given_formals(self):
        yield '-<digit>', build_this_custy, 'desco'
        yield '-h', '--help', 'thizzo scrizzo'


def build_this_custy():
    def match(tok):
        if (md := re.match('^-([0-9]+)$', tok)) is None:
            return
        return int(md[1])
    import re
    return match


def subject_module():
    import script_lib.cheap_arg_parse as module
    return module


def EHS():
    from script_lib.test_support import expect_help_screen
    return expect_help_screen


if __name__ == '__main__':
    unittest.main()

# #born
