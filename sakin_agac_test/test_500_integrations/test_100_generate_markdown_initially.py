"""
#covers: script/khong/markdown_via_json_stream
(also provides coverage for [#608.2] :[#414.2])
"""


from _init import (
        fixture_executable_path,
        )
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        )
import unittest


class _CommonCase(unittest.TestCase):  # #[#410.K]

    # -- assertions & assistance

    def _same_business_lines(self):
        act = self.table_lines()
        self.assertIn('boo bah', act[-2])
        self.assertIn('choo chah', act[-1])
        self.assertEqual(len(act), 5)

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
        _exp = "'ohai-mami -h' for help\n"
        self.assertEqual(self.last_stderr_line(), _exp)

    def first_stderr_line(self):
        return self._stderr_line(0)

    def last_stderr_line(self):
        return self._stderr_line(-1)

    def _stderr_line(self, offset):
        return self.end_state().first_section('stderr').lines[offset]

    def build_end_state(self):
        # sout, serr, end_stater = _this_one_lib().for_DEBUGGING()
        sout, serr, end_stater = _this_one_lib().for_flip_flopping_sectioner()

        _stdin = self.stdin()

        _tail = self.argv_tail()
        _use_argv = ('ohai-mami', *_tail)

        import script.khong.markdown_via_json_stream as subject_script

        _es = subject_script._CLI(_stdin, sout, serr, _use_argv)

        _state = end_stater(_es)
        return _state

    def stdin_that_is_NOT_interactive(self):
        return _this_one_lib().MINIMAL_NON_INTERACTIVE_IO

    def stdin_that_IS_interactive(self):
        return _this_one_lib().MINIMAL_INTERACTIVE_IO


class Case110_help(_CommonCase):  # #coverpoint9.1.4 - one arg, help

    def test_100_succeeds(self):
        self.succeeds()

    def test_200_content(self):
        lines = self.end_state().first_section('stderr').lines

        self.assertIn('usage: ', lines[0])

        self.assertAlmostEqual(len(lines), 6, delta=3)

    @shared_subject
    def end_state(self):
        return self.build_end_state()

    def stdin(self):
        return self.stdin_that_IS_interactive()  # be jerks

    def argv_tail(self):
        return ('--hel',)


class Case120_no_args(_CommonCase):  # #coverpoint9.0  - no args

    def test_100_fails(self):
        self.fails()

    def test_200_whines(self):
        _exp = 'provide STDIN or <script>\n'
        self.assertEqual(self.first_stderr_line(), _exp)

    def test_300_invites(self):
        self.invites()

    @shared_subject
    def end_state(self):
        return self.build_end_state()

    def stdin(self):
        return self.stdin_that_IS_interactive()  # be jerks

    def argv_tail(self):
        return ()


class Case130_both(_CommonCase):  # #coverpoint9.2 - two args

    def test_100_fails(self):
        self.fails()

    def test_200_content(self):
        _exp = "can't have both STDIN and argument(s)\n"
        self.assertEqual(self.first_stderr_line(), _exp)

    def test_300_invites(self):
        self.invites()

    @shared_subject
    def end_state(self):
        return self.build_end_state()

    def stdin(self):
        return self.stdin_that_is_NOT_interactive()

    def argv_tail(self):
        return ('no-see',)


class Case170_too_many_args(_CommonCase):  # #coverpoint9.3 - two args

    def test_100_fails(self):
        self.fails()

    def test_200_content(self):
        _exp = 'too many args (had 3 need 1)\n'
        self.assertEqual(self.first_stderr_line(), _exp)

    def test_300_invites(self):
        self.invites()

    @shared_subject
    def end_state(self):
        return self.build_end_state()

    def stdin(self):
        return self.stdin_that_IS_interactive()

    def argv_tail(self):
        return ('no-see', '--fing-foo', 'da-da')


class Case200_stdin(_CommonCase):  # #coverpoint9.1.1  - one arg: stdin

    def test_100_succeeds(self):
        self.succeeds()

    def test_200_header_row_and_second_one(self):
        act = self.table_lines()
        self.assertRegex(act[0], r'^\| [A-Z][a-z]+ .+ \|$')
        self.assertRegex(act[1], r'^(?:\|[-:]-+:?)+\|$')

    def test_220_business_object_rows_got_alphabetized(self):
        self._same_business_lines()

    @shared_subject
    def table_lines(self):
        return self.end_state().first_section('stdout').lines

    @shared_subject
    def end_state(self):
        return self.build_end_state()

    def stdin(self):
        return _this_one_lib().STDERR_CRAZYTOWN(
                '{ "_is_sync_meta_data": true, "natural_key_field_name": "lesson" }\n',  # noqa: E501
                '{ "header_level": 1 }\n',
                '{ "lesson": "[choo chah](foo fa)" }\n',
                '{ "lesson": "[boo bah](loo la)" }\n',
                )

    def argv_tail(self):
        return ()


class Case220_arg(_CommonCase):  # #coverpoint9.1.2  - one arg: arg

    def test_100_succeeds(self):
        self.succeeds()

    def test_200_same_business_lines(self):
        self._same_business_lines()

    @shared_subject
    def table_lines(self):
        return self.end_state().first_section('stdout').lines

    @shared_subject
    def end_state(self):
        return self.build_end_state()

    def stdin(self):
        return self.stdin_that_IS_interactive()

    def argv_tail(self):
        return (fixture_executable_path('exe_140_khong_micro.py'),)


def _this_one_lib():
    import script_lib.test_support.stdout_and_stderr_and_end_stater as lib
    return lib


if __name__ == '__main__':
    unittest.main()

# #history-A.1: when interfolding became the main algorithm, order changed
# #born.
