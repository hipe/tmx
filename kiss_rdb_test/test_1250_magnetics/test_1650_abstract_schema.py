from modality_agnostic.test_support.common import \
        dangerous_memoize as shared_subject
from unittest import TestCase as unittest_TestCase, main as unittest_main


class CommonCase(unittest_TestCase):

    @shared_subject
    def abstract_schema_one(self):
        lines = self.expected_sexp_lines_one
        return subject_module().abstract_schema_via_sexp_lines(lines)

    @shared_subject
    def expected_sexp_lines_one(self):
        return lines_via_big_string("""
            ("abstract_schema" ("properties")
              ("abstract_entity" "AA"
                ("abstract_attribute" "BB" "text" "key")
                ("abstract_attribute" "CC" "text" "optional")
              )
            )
        """)

    def build_end_state_for_CLI(self):
        from script_lib.test_support.expect_STDs import \
            pretend_STDIN_via_mixed as stdin_via, \
            spy_on_write_and_lines_for as soutserr

        sin = stdin_via(self.given_stdin())
        sout, sout_lines = soutserr(self, 'DBG SOUT: ')
        serr, serr_lines = soutserr(self, 'DBG SERR: ')
        cli = subject_module()._CLI
        argv = ('/fake-fs/no-see/me-script', * self.given_argv())
        es = cli(sin, sout, serr, argv)
        return es, tuple(sout_lines), tuple(serr_lines)

    do_debug = False


class Case1640_abstract_schema_via_sexp_lines(CommonCase):

    def test_010_abstract_schema_looks_right(self):
        abs_sch = self.abstract_schema_one
        abs_ents = tuple(abs_sch.to_tables())
        ent_names = tuple(t.table_name for t in abs_ents)
        assert ('AA',) == ent_names
        abs_attrs = tuple(abs_ents[0].to_columns())
        attr_names = tuple(attr.column_name for attr in abs_attrs)
        self.assertSequenceEqual(('BB', 'CC'), attr_names)


class Case1644_sexp_lines_via_abstract_schema__round_trip__(CommonCase):

    def test_010_sexp_lines_look_right(self):
        abs_sch = self.abstract_schema_one
        act_lines = tuple(abs_sch.to_sexp_lines())
        exp_lines = self.expected_sexp_lines_one
        self.assertSequenceEqual(act_lines, exp_lines)


class Case1648_CLI_model_abstract_schema_from_command_line(CommonCase):
    # (actually this is for testing reading from STDIN)

    def test_010_succeeds(self):
        returncode, _, _ = self.end_state_for_CLI
        assert 0 == returncode

    def test_020_wrote_thing(self):
        _, out_lines, err_lines = self.end_state_for_CLI
        self.assertSequenceEqual(out_lines, self.expected_sexp_lines_one)
        assert not err_lines

    @shared_subject
    def end_state_for_CLI(self):
        return self.build_end_state_for_CLI()

    def given_argv(self):
        return '-formal-entity AA -attr BB -key -attr CC -optional'.split()

    def given_stdin(self):
        return 'FAKE_STDIN_INTERACTIVE'


class Case1652_CLI_read_sexp_lines_from_file_works(CommonCase):
    # (actually this is for testing reading from STDIN)

    def test_010_has_exitstatus_of_zero(self):
        returncode, _, _ = self.end_state_for_CLI
        assert 0 == returncode

    def test_020_wrote_thing(self):
        _, out_lines, err_lines = self.end_state_for_CLI
        assert 0 == len(err_lines)
        self.assertSequenceEqual(out_lines, self.expected_sexp_lines_one)

    @shared_subject
    def end_state_for_CLI(self):
        return self.build_end_state_for_CLI()

    def given_argv(self):
        return '-file', '-'

    def given_stdin(self):
        return self.expected_sexp_lines_one


class Case1656_help_screen(CommonCase):

    def test_010_ohai(self):
        returncode, sout_lines, serr_lines = self.end_state_for_CLI
        assert 0 == returncode
        assert 0 == len(sout_lines)
        assert 'usage: me-script' in serr_lines[0]
        assert 45 < len(serr_lines)  # ..

    @shared_subject
    def end_state_for_CLI(self):
        return self.build_end_state_for_CLI()

    def given_argv(self):
        return ('--help',)

    def given_stdin(self):
        return 'FAKE_STDIN_INTERACTIVE'


def lines_via_big_string(big_s):
    big_s = big_s.replace('\n            ', '\n')
    import re
    lines = re.compile('(?<=\n)(?=.)', re.MULTILINE).split(big_s)
    assert '\n' == lines[0]
    assert '        ' == lines[-1]
    return tuple(lines[1:-1])


def subject_module():
    import kiss_rdb.magnetics.abstract_schema_via_sexp as mod
    return mod


if __name__ == '__main__':
    unittest_main()

# #born
