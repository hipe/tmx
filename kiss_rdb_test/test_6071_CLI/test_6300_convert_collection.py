from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes, \
        dangerous_memoize as shared_subject, lazy
import unittest


class CommonCase(unittest.TestCase):  # #[#459.F]

    # -- assertions & assistance

    def _same_business_lines(self):  # NOTE not alphabetized (unlike before)
        act = self.outputted_file_lines.table_lines
        self.assertIn('choo chah', act[-2])
        self.assertIn('boo bah', act[-1])
        self.assertEqual(len(act), 4)

    def fails(self):
        self.assertNotEqual(self._validated_exitstatus(), 0)

    def succeeds(self):
        self.assertEqual(self._validated_exitstatus(), 0)

    def _validated_exitstatus(self):
        _es = self.end_state
        es = _es.exitstatus
        self.assertIsInstance(es, int)
        return es

    def invites(self):
        # _exp = "see 'ohai-mami --help'\n"
        _exp = "Try 'ohai-mami convert-collection --help' for help.\n"
        _act = self.stderr_lines[1]
        self.assertEqual(_act, _exp)

    @property
    def reason_stderr_line(self):
        return self.last_stderr_line()  # click ick/meh

    def first_stderr_line(self):
        return self.stderr_lines[0]

    def last_stderr_line(self):
        return self.stderr_lines[-1]

    @property
    def stderr_lines(self):
        return self._lines('stderr')

    def _lines(self, stdout_or_stderr):
        return self.end_state.first_line_run(stdout_or_stderr).lines

    @dangerous_memoize_in_child_classes('_OFL', 'build_outputted_file_lines')
    def outputted_file_lines():
        pass

    def build_outputted_file_lines(self):

        itr = iter(self.end_state.first_line_run('stdout').lines)
        line = next(itr)
        head_lines = []
        if '---' == line[0:3]:
            while True:
                head_lines.append(line)
                line = next(itr)
                if '---' == line[0:3]:
                    head_lines.append(line)
                    break

        table_title_line = None

        for line in itr:
            if '\n' == line:
                continue
            if '#' != line[0]:
                break
            table_title_line = line
            for line in itr:
                if '\n' == line:
                    continue
                break
            break

        assert '|' == line[0]
        table_lines = []
        while True:
            table_lines.append(line)
            line = next(itr)
            if '|' != line[0]:
                break

        while '\n' == line:
            line = next(itr)

        _1, _2, _3 = head_lines, table_title_line, table_lines

        class OutputtedFileLines:  # #class-as-namespace
            head_lines = tuple(_1)
            table_title_line = _2
            table_lines = tuple(_3)
            tail_lines = (line, *itr)

        return OutputtedFileLines

    def build_end_state(self, case_category):
        # NOTE the biggest challenge is abstracting click's particularies

        get_lines_normally, get_exitstatus_normally = True, True
        yes_sout, yes_serr = False, False
        exception_category, do_debug = None, False

        if 'stdout' == case_category:
            yes_sout = True
            expect_which = 'stdout'
        elif 'stderr' == case_category:
            yes_serr = True
            expect_which = 'stderr'
        elif 'click_exception' == case_category:
            exception_category = 'click_exception'
            get_lines_normally = False
            yes_serr = True
            get_exitstatus_normally = False
            expect_which = 'stderr'
        elif 'debug' == case_category:
            yes_sout, yes_serr = True, True
            do_debug = True
        else:
            assert(False)

        use_stdin = self.given_stdin()
        use_argv_tail = ('convert-collection', *self.argv_tail())  # :#here1

        def stderrer():
            import sys
            return sys.stderr

        def yes_do_debug():
            return do_debug or self.do_debug

        from kiss_rdb_test.CLI import BIG_FLEX
        big_flex_end_state = BIG_FLEX(
                given_stdin=use_stdin,
                given_args=use_argv_tail,
                allow_stdout_lines=yes_sout,
                allow_stderr_lines=yes_serr,
                exception_category=exception_category,
                injections_dictionary=None,  # no rng, no filesystem
                might_debug=yes_do_debug(),
                do_debug_f=yes_do_debug)

        if get_exitstatus_normally:
            use_exitstatus = big_flex_end_state.exit_code
        else:
            use_exitstatus = 9876  # so bad

        if get_lines_normally:
            lines = big_flex_end_state.lines
        else:
            # 😭
            import script_lib.test_support.expect_STDs as lib
            writes = []  # writes not lines
            r1 = lib.build_write_receiver_for_debugging('DBG: ', yes_do_debug)
            io_for_write = lib.spy_on_write_via_receivers((r1, writes.append))
            big_flex_end_state.exception.show(io_for_write)
            big_string = ''.join(writes)
            import re
            lines = re.compile('(?<=\n)(?=.)', re.DOTALL).split(big_string)

        # click likes filling the memory with big strings so meh
        return _EndState(expect_which, tuple(lines), use_exitstatus)

    def stdin_that_is_NOT_interactive(self):
        return _this_one_lib().FAKE_STDIN_NON_INTERACTIVE

    def stdin_that_IS_interactive(self):
        return _this_one_lib().FAKE_STDIN_INTERACTIVE

    do_debug = False


class Case010_help(CommonCase):

    def test_100_succeeds(self):
        self.succeeds()

    def test_200_content(self):
        lines = self.end_state.first_line_run('stdout').lines  # click
        self.assertIn('Usage: ', lines[0])
        self.assertAlmostEqual(len(lines), 18, delta=2)

    @shared_subject
    def end_state(self):
        return self.build_end_state('stdout')  # because click

    def given_stdin(self):
        return self.stdin_that_IS_interactive()  # be jerks

    def argv_tail(self):
        return ('--help',)


class Case020_no_args(CommonCase):

    def test_100_fails(self):
        self.fails()

    def test_200_whines(self):
        _exp = "Error: Missing argument 'FROM_COLLECTION'.\n"
        # _exp = 'parameter error: expecting <script>\n'
        self.assertEqual(self.reason_stderr_line, _exp)

    def test_300_DOES_NOT_INVITE(self):
        self.invites()

    @shared_subject
    def end_state(self):
        return self.build_end_state('click_exception')

    def given_stdin(self):
        return self.stdin_that_IS_interactive()  # be jerks

    def argv_tail(self):
        return ()


class Case030_args_and_stdin(CommonCase):

    def test_100_fails(self):
        self.fails()

    def test_200_content(self):
        _exp = "STDIN cannot be a pipe unless FROM_COLLECTION is '-'\n"
        # _exp = 'parameter error: when piping from STDIN, <script> must be "-"
        _act = self.first_stderr_line()
        self.assertEqual(_act, _exp)

    def test_300_invites(self):
        # broke at #history-A.2
        self.assertEqual(len(self.stderr_lines), 1)
        # self.invites()

    @shared_subject
    def end_state(self):
        return self.build_end_state('stderr')

    def given_stdin(self):
        return self.stdin_that_is_NOT_interactive()

    def argv_tail(self):
        return ('no-see-1', 'no-see-2')


class Case040_too_many_args(CommonCase):

    def test_100_fails(self):
        self.fails()

    def test_200_content(self):
        _act = self.reason_stderr_line
        _exp = "Error: no such option: --fing-foo\n"
        # _exp = "parameter error: unrecognized option: '--fing-foo'\n"
        self.assertEqual(_act, _exp)

    def test_300_invites(self):
        self.invites()

    @shared_subject
    def end_state(self):
        return self.build_end_state('click_exception')

    def given_stdin(self):
        return self.stdin_that_IS_interactive()

    def argv_tail(self):
        return ('no-see', '--fing-foo', 'da-da')


class Case050SA_one_arg_which_is_stdin(CommonCase):  # #midpoint

    def test_100_succeeds(self):
        self.succeeds()

    def test_200_header_row_and_second_one(self):
        act = self.outputted_file_lines.table_lines
        self.assertRegex(act[0], r'^\| [A-Z][a-z]+ \|$')
        self.assertRegex(act[1], r'^(?:\|[-:]-+:?)+\|$')

    def test_220_business_object_rows_are_NOT_alpahbetized(self):
        self._same_business_lines()

    def test_300_head_lines(self):
        _act = self.outputted_file_lines.head_lines
        self.assertIn('i am your collection', _act[1])

    def test_400_tail_lines(self):
        _act = self.outputted_file_lines.tail_lines
        self.assertIn('#born', _act[-1])

    @shared_subject
    def end_state(self):
        return self.build_end_state('stdout')

    def given_stdin(self):
        return STUB_STDIN(
                # '{ "header_level": 1 }\n',  # #history-A.2
                '{ "lesson": "[choo chah](foo fa)" }\n',
                '{ "lesson": "[boo bah](loo la)" }\n')

    def argv_tail(self):
        return ('-', '--from-format', 'producer-script',
                '-', '--to-format', 'markdown-table')


class Case060_one_arg_which_is_token(CommonCase):

    # (at #history-A.2 (the big upgrade when we put this under kiss instead
    # of a standalone script) it would have been nice to exercise the option
    # (almost certainly broken right now) of outputting to a file instead of
    # to STDOUT; BUT A) easy workaround and B) it would be best to wait until
    # after/during [#873.P] when we try to unify the markdown adapter as
    # streaming

    def test_100_succeeds(self):
        self.succeeds()

    def test_200_same_business_lines(self):
        self._same_business_lines()

    @shared_subject
    def end_state(self):
        return self.build_end_state('stdout')

    def given_stdin(self):
        return self.stdin_that_IS_interactive()

    def argv_tail(self):
        from os.path import dirname, join
        test_dir = dirname(dirname(__file__))
        tail = 'exe_140_khong_micro.py'
        data_provider = join(test_dir, 'fixture_executables', tail)

        return (data_provider,
                '-', '--to-format', 'markdown-table')


class _EndState:
    def __init__(self, which, lines, es):
        self._the_only_run = _LineRun(lines)
        self.exitstatus = es
        self._which = which

    def first_line_run(self, which):
        assert self._which == which
        return self._the_only_run


class _LineRun:
    def __init__(self, lines):
        self.lines = lines


class STUB_STDIN:  # :[#605.4]

    def __init__(self, *lines):
        self._lines = lines

    def isatty(self):
        return False

    def __iter__(self):
        return iter(self._lines)

    def fileno(_):  # #provision [#608.15]: implement this correctly
        return 0

    mode = 'r'


def _this_one_lib():
    import script_lib.test_support.expect_STDs as module
    return module


if __name__ == '__main__':
    unittest.main()

# #history-B.2
# #history-A.3: moved here from another subproject
# #history-A.2 implementation moved to kiss (convert collection)
# #history-A.1: when interfolding became the main algorithm, order changed
# #born.
