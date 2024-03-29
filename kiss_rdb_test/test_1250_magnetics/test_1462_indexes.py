from kiss_rdb_test.common_initial_state import \
        unindent_with_dot_hack, spy_on_write_and_lines_for
from modality_agnostic.test_support.common import \
    dangerous_memoize as shared_subject
import unittest


"""NOTE tiny note about case numbers here:

they draw from the unified universal case numberpace,
however this test module can (and should) exist uncoupled from the next
so the practical order of tests run is not identical to the logical order.
"""


class CommonCase(unittest.TestCase):

    def reads_file(self):

        file_lines_itr = self._build_expect_file_lines()

        _actual_ID_itr = _other_subject_mod().identifiers_via_lines_of_index(
                file_lines_itr)

        depth, expected_identifiers_itr = self._depth_and_identifiers()

        def f(o):
            return o.to_string()

        _use_actual_IDs = tuple(f(o) for o in _actual_ID_itr)

        _use_expected_IDs = tuple(f(o) for o in expected_identifiers_itr)

        self.assertSequenceEqual(_use_actual_IDs, _use_expected_IDs)

    def writes_file(self):

        depth, identifiers = self._depth_and_identifiers()

        _actual_itr = subject_module()._lines_of_index_via_identifiers(
                identifiers, depth, listener=None)

        if False:  # debugging
            from sys import stdout
            write = stdout.write

            write('\n\nWAHOO:\n')
            for line in _actual_itr:
                write(line)

            write('done. (SKIPPING TEST)\n')

            return  # BE CAREFUL

        _expected_itr = self._build_expect_file_lines()

        _actual = tuple(_actual_itr)

        _expected = tuple(_expected_itr)

        self.assertSequenceEqual(_actual, _expected)

    def _build_expect_file_lines(self):

        # our unindent trick won't work for file formats whose first
        # char is not in column 1. our format is this way.

        big_s = self.expect_file_lines()
        return unindent_with_dot_hack(big_s)

    def _depth_and_identifiers(self):

        itr = iter(self.given_identifiers())  # a tuple of strings (0 or more)

        is_empty_list = True
        depth = 79  # BE CAREFUL - avoid saniy check of too shallow a depth
        for first_s in itr:  # once
            is_empty_list = False
            depth = len(first_s)
            break

        def use_identifiers():  # dark hack to iterate after peek
            if is_empty_list:
                return
            yield first_s
            for s in itr:
                yield s

        from kiss_rdb.magnetics_.identifier_via_string import (
                identifier_via_string_ as id_via_s)

        def identifier_via_string(s):
            id_o = id_via_s(s, None)
            assert(depth == id_o.number_of_digits)
            return id_o

        _identifiers = (identifier_via_string(s) for s in use_identifiers())

        return depth, _identifiers

    do_debug = False


class Case1452_simplified_typical_NO_rerack_at_first(CommonCase):

    def test_050_load_module(self):
        self.assertIsNotNone(subject_module())

    def test_100_write_file(self):
        self.writes_file()

    def test_200_read_file(self):
        self.reads_file()

    def expect_file_lines(self):
        return """
        .
         A
        B (2   4)
        """

    def given_identifiers(self):
        return ('AB2',
                'AB4')


class Case1458_simplified_typical_YES_rerack_at_first(CommonCase):

    def test_100_write_file(self):
        self.writes_file()

    def test_200_read_file(self):
        self.reads_file()

    def expect_file_lines(self):
        return """
        .
         A
        B (2)
         C
        D (    4)
        """

    def given_identifiers(self):
        return ('AB2',
                'CD4')


class Case1462_simplified_multiple_rack_lines_in_a_row(CommonCase):

    def test_100_write_file(self):
        self.writes_file()

    def test_200_read_file(self):
        self.reads_file()

    def expect_file_lines(self):
        return """
        .
         Q
        Y (2 3)
        Z (    4)
         R
        S (      5)
        """

    def given_identifiers(self):
        return ('QY2',
                'QY3',
                'QZ4',
                'RS5')


class Case1466_none(CommonCase):

    def test_100_write_file(self):
        self.writes_file()

    def test_200_read_file(self):
        exe_cls = _other_subject_mod().EmptyFileException_
        try:
            self.reads_file()
        except exe_cls as e:
            exe = e
        self.assertEqual(str(exe), 'index file was empty')

    def expect_file_lines(self):
        return ''

    def given_identifiers(self):
        return ()


class Case1470_deeper(CommonCase):

    def test_100_write_file(self):
        self.writes_file()

    def test_200_read_file(self):
        self.reads_file()

    def expect_file_lines(self):
        return """
        .
          A
         B
        C (2 3)
          D
         E
        F (    4)
         G
        H (      5)
        """

    def given_identifiers(self):
        return ('ABC2',
                'ABC3',
                'DEF4',
                'DGH5')


class Case1474_shallowest(CommonCase):

    def test_100_write_file(self):
        self.writes_file()

    def test_200_read_file(self):
        self.reads_file()

    def expect_file_lines(self):
        return """
        .
        B (  3)
        D (2   4)
        """

    def given_identifiers(self):
        return ('B3',
                'D2',
                'D4')


class Case1476_CLI_tool(CommonCase):

    def test_050_exit_code_says_success(self):
        """(Note hard-coded relative path)"""

        act = self.end_state[2]
        self.assertEqual(act, 0)

    def test_100_lines_look_good(self):
        act = self.end_state[0]
        self.assertIn(len(act), range(3, 10))
        act = act[-1]
        exp = '9 (                            G H J)\n'
        self.assertEqual(act, exp)

    def test_120_info_lines(self):
        serr_lines = self.end_state[1]
        act, = serr_lines
        self.assertIn('wrote 152 bytes to «stdout»', act)

    @shared_subject
    def end_state(self):
        sout, sout_lines = spy_on_write_and_lines_for(
                self, 'SOUT DBG: ', isatty=True)
        serr, serr_lines = spy_on_write_and_lines_for(
                self, 'SERR DBG: ', isatty=True)

        yikes = 'kiss_rdb_test/fixture-directories/4844-eno/050-canon-main'
        argv = '[me]', 'generate', yikes, '--preview'

        cli = subject_module().CLI_

        from script_lib.test_support.expect_STDs import \
            pretend_STDIN_via_mixed as func
        sin = func('FAKE_STDIN_INTERACTIVE')

        rc = cli(sin, sout, serr, argv)
        return tuple(sout_lines), tuple(serr_lines), rc


def _other_subject_mod():
    from kiss_rdb.magnetics_ import identifiers_via_index as _
    return _


def subject_module():
    from kiss_rdb.magnetics_ import index_via_identifiers as module
    return module


if __name__ == '__main__':
    unittest.main()

# #born.
