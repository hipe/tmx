import _common_state  # noqa: F401
from kiss_rdb_test import structured_emission as selib
import unittest

unindent = selib.unindent


"""NOTE tiny note about case numbers here:

they draw from the unified universal case numberpace,
however this test module can (and should) exist uncoupled from the next
so the practical order of tests run is not identical to the logical order.
"""


class _CommonCase(unittest.TestCase):

    def writes_file(self):

        depth, identifiers = self._depth_and_identifiers()

        _actual_itr = _subject_module().lines_of_index_via_identifiers(
                identifiers, depth)

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
        if '' == big_s:
            return iter(())
        itr = unindent(big_s)
        for line in itr:  # once
            assert('.\n' == line)
            break
        return itr

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

        from kiss_rdb.magnetics_ import collection_via_directory as this_lib

        def identifier_via_string(s):
            id_o = this_lib._identifier_via_string(s, None)
            assert(depth == len(id_o.native_digits))
            return id_o

        _identifiers = (identifier_via_string(s) for s in use_identifiers())

        return depth, _identifiers


class Case731_simplified_typical_NO_rerack_at_first(_CommonCase):

    def test_050_load_module(self):
        self.assertIsNotNone(_subject_module())

    def test_100_write_file(self):
        self.writes_file()

    def expect_file_lines(self):
        return """
        .
         A
        B (2   4)
        """

    def given_identifiers(self):
        return (
                'AB2',
                'AB4',
                )


class Case734_simplified_typical_YES_rerack_at_first(_CommonCase):

    def test_100_write_file(self):
        self.writes_file()

    def expect_file_lines(self):
        return """
        .
         A
        B (2)
         C
        D (    4)
        """

    def given_identifiers(self):
        return (
                'AB2',
                'CD4',
                )


class Case736_none(_CommonCase):

    def test_100_write_file(self):
        self.writes_file()

    def expect_file_lines(self):
        return ''

    def given_identifiers(self):
        return ()


class Case739_deeper(_CommonCase):

    def test_100_write_file(self):
        self.writes_file()

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
        return (
                'ABC2',
                'ABC3',
                'DEF4',
                'DGH5',
                )


def _subject_module():
    from kiss_rdb.magnetics_ import index_via_identifiers as _
    return _


if __name__ == '__main__':
    unittest.main()

# #born.
