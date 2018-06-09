# #covers: [isomorphic asset file]

import _init  # noqa: F401
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        )
import unittest


class _CommonCase(unittest.TestCase):  # #[#410.K]

    # -- assertions & assistance

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
        _exp = 'usage: ohai-mami\n'
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


class Case110_help(_CommonCase):

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


class Case120_no_args_allowed(_CommonCase):

    def test_100_fails(self):
        self.fails()

    def test_200_whines(self):
        _exp = 'had 1 needed 0 arguments\n'
        self.assertEqual(self.first_stderr_line(), _exp)

    def test_300_invites(self):
        self.invites()

    @shared_subject
    def end_state(self):
        return self.build_end_state()

    def stdin(self):
        return self.stdin_that_IS_interactive()  # be jerks

    def argv_tail(self):
        return ('jerp',)


class Case130_must_be_stdin(_CommonCase):

    def test_100_fails(self):
        self.fails()

    def test_200_content(self):
        self.end_state().first_section('stderr')

        _exp = 'currently, non-interactive from STDIN only\n'
        self.assertEqual(self.first_stderr_line(), _exp)

    def test_300_example(self):
        _exp = 'e.g: blab_blah | ohai-mami\n'
        self.assertEqual(self.last_stderr_line(), _exp)

    @shared_subject
    def end_state(self):
        return self.build_end_state()

    def stdin(self):
        return self.stdin_that_IS_interactive()

    def argv_tail(self):
        return ()


class Case200_wee(_CommonCase):

    def test_100_succeeds(self):
        self.succeeds()

    def test_200_header_row_and_second_one(self):
        act = self.table_lines()[0:2]
        self.assertRegex(act[0], r'^\| [A-Z][a-z]+ .+ \|$')
        self.assertRegex(act[1], r'^(?:\|[-:]-+:?)+\|$')

    def test_220_business_object_rows(self):
        act = self.table_lines()[2:]
        self.assertIn('choo chah', act[0])
        self.assertIn('boo bah', act[1])
        self.assertEqual(len(act), 2)

    def test_300_info(self):
        act = self.end_state().first_section('stderr').lines
        self.assertRegex(act[0], r'^emitted \d+ row-items, \d+ bytes$')
        self.assertEqual(len(act), 1)

    @shared_subject
    def table_lines(self):
        return self.end_state().first_section('stdout').lines

    @shared_subject
    def end_state(self):
        return self.build_end_state()

    def stdin(self):
        return _this_one_lib().STDERR_CRAZYTOWN(
                '{ "_is_sync_meta_data": true }\n',
                '{ "header_level": 1 }\n',
                '{ "lesson": "[choo chah](foo fa)" }\n',
                '{ "lesson": "[boo bah](loo la)" }\n',
                )

    def argv_tail(self):
        return ()


def _this_one_lib():
    import script_lib.test_support.stdout_and_stderr_and_end_stater as lib
    return lib


if __name__ == '__main__':
    unittest.main()

# #born.
