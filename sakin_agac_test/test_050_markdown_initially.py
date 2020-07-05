from sakin_agac_test.common_initial_state import (
        executable_fixture)
from modality_agnostic.memoization import (
        dangerous_memoize_in_child_classes,
        dangerous_memoize as shared_subject, lazy)
import unittest


class _CommonCase(unittest.TestCase):  # #[#459.F]

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
        _es = self.end_state()
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
        return self.end_state().first_line_run(stdout_or_stderr).lines

    @property
    @dangerous_memoize_in_child_classes('_OFL', 'build_outputted_file_lines')
    def outputted_file_lines():
        pass

    def build_outputted_file_lines(self):

        itr = iter(self.end_state().first_line_run('stdout').lines)
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

        recv_sout, recv_serr, fin = _this_one_lib().stdout_stderr_partitioner()

        do_debug = False
        yes_sout = True
        yes_serr = True
        exception_category = None
        get_lines_normally = True
        get_exitstatus_normally = True

        if 'stdout' == case_category:
            yes_serr = False
            recv_line = recv_sout
        elif 'stderr' == case_category:
            yes_sout = False
            recv_line = recv_serr
        elif 'click_exception' == case_category:
            exception_category = 'click_exception'
            get_lines_normally = False
            yes_sout = False
            get_exitstatus_normally = False
            recv_line = recv_serr
        elif 'debug' == case_category:
            do_debug = True
        else:
            assert(False)

        _use_stdin = self.stdin()

        _use_argv_tail = ('convert-collection', *self.argv_tail())  # :#here1

        def stderrer():
            import sys
            return sys.stderr

        from kiss_rdb_test.CLI import BIG_FLEX
        big_flex_end_state = BIG_FLEX(
                given_stdin=_use_stdin,
                given_args=_use_argv_tail,
                allow_stdout_lines=yes_sout,
                allow_stderr_lines=yes_serr,
                exception_category=exception_category,
                injections_dictionary=None,  # no rng, no filesystem
                might_debug=(do_debug or self.do_debug),
                do_debug_f=lambda: do_debug or self.do_debug,
                debug_IO_f=stderrer)

        if get_exitstatus_normally:
            use_exitstatus = big_flex_end_state.exit_code
        else:
            use_exitstatus = 9876  # so bad

        if get_lines_normally:
            lines = big_flex_end_state.lines
        else:
            # 😭
            writes = []
            from modality_agnostic import write_only_IO_proxy
            _IO_for_write = write_only_IO_proxy(
                    write=writes.append, flush=lambda: None)
            big_flex_end_state.exception.show(_IO_for_write)
            _big_string = ''.join(writes)
            import re
            _rx = re.compile('(?<=\n)(?=.)', re.DOTALL)  # _eol
            lines = _rx.split(_big_string)
            if do_debug or self.do_debug:
                io = stderrer()
                io.write('\n')  # _eol
                for line in lines:
                    io.write(f"dbg stderr: {line}")

        for line in lines:
            recv_line(line)

        return fin(use_exitstatus)

    def stdin_that_is_NOT_interactive(self):
        return _this_one_lib().MINIMAL_NON_INTERACTIVE_IO

    def stdin_that_IS_interactive(self):
        return _this_one_lib().MINIMAL_INTERACTIVE_IO

    do_debug = False


class Case010_help(_CommonCase):

    def test_100_succeeds(self):
        self.succeeds()

    def test_200_content(self):
        lines = self.end_state().first_line_run('stdout').lines  # click
        self.assertIn('Usage: ', lines[0])
        self.assertAlmostEqual(len(lines), 18, delta=2)

    @shared_subject
    def end_state(self):
        return self.build_end_state('stdout')  # because click

    def stdin(self):
        return self.stdin_that_IS_interactive()  # be jerks

    def argv_tail(self):
        return ('--help',)


class Case020_no_args(_CommonCase):

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

    def stdin(self):
        return self.stdin_that_IS_interactive()  # be jerks

    def argv_tail(self):
        return ()


class Case030_args_and_stdin(_CommonCase):

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

    def stdin(self):
        return self.stdin_that_is_NOT_interactive()

    def argv_tail(self):
        return ('no-see-1', 'no-see-2')


class Case040_too_many_args(_CommonCase):

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

    def stdin(self):
        return self.stdin_that_IS_interactive()

    def argv_tail(self):
        return ('no-see', '--fing-foo', 'da-da')


class Case050SA_one_arg_which_is_stdin(_CommonCase):  # #midpoint

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

    def stdin(self):
        return _this_one_lib().FAKE_STDIN(
                # '{ "header_level": 1 }\n',  # #history-A.2
                '{ "lesson": "[choo chah](foo fa)" }\n',
                '{ "lesson": "[boo bah](loo la)" }\n',
                )

    def argv_tail(self):
        return ('-', '--from-format', 'producer-script',
                '-', '--to-format', 'markdown-table')


class Case060_one_arg_which_is_token(_CommonCase):

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

    def stdin(self):
        return self.stdin_that_IS_interactive()

    def argv_tail(self):
        return (executable_fixture('exe_140_khong_micro.py'),
                '-', '--to-format', 'markdown-table')


@lazy
def _this_one_lib():
    # awful, but we want xx
    from script_lib.test_support.stdout_and_stderr_and_end_stater import (
            stdout_stderr_partitioner as _1,
            FAKE_STDIN as _2,
            MINIMAL_INTERACTIVE_IO as _3,
            MINIMAL_NON_INTERACTIVE_IO as _4)

    class These:  # class-as-namespace
        stdout_stderr_partitioner = _1
        FAKE_STDIN = _2
        MINIMAL_INTERACTIVE_IO = _3
        MINIMAL_NON_INTERACTIVE_IO = _4

    return These


if __name__ == '__main__':
    unittest.main()

# #history-A.2 implementation moved to kiss (convert collection)
# #pending-rename: to somewhere in kiss, for testing the command named #here1
# #history-A.1: when interfolding became the main algorithm, order changed
# #born.
