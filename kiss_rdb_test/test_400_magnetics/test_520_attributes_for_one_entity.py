import _common_state  # noqa: F401
from kiss_rdb_test import structured_emission as selib
from modality_agnostic.memoization import dangerous_memoize as shared_subject
import unittest


class _CommonCase(unittest.TestCase):

    def partitions_via_identifier(self, id_s):

        listener = selib.debugging_listener() if False else None
        # set the above to true if it's failing and trying to emit, to debug

        _all_lines = self.given_lines()
        return _subject_module().in_file_attributes_via(
                id_s, _all_lines, listener)  # noqa: E501


class Case100_not_at_end_of_file(_CommonCase):

    def test_010_the_identifier_is_in_there(self):
        self.assertEqual(self.entity_partitions()['identifier_string'], 'B')

    def test_020_the_attributes_are_in_there(self):
        self.assertTrue(_in_file_attributes in self.entity_partitions())

    def test_030_the_first_one_is_the_one_that_was_resulted(self):
        o = self.entity_partitions()[_in_file_attributes]
        self.assertEqual(o['see-me'], 'do see me')

    @shared_subject
    def entity_partitions(self):
        return self.partitions_via_identifier('B')

    def given_lines(self):
        return selib.unindent("""
        # comment
        [item.A.attributes]
        [item.B.meta]
        [item.B.attributes]
        see-me = "do see me"

        [item.B.attributes]
        see-me = "don't see me"

        """)


# #todo: cover at end of file

# #todo: cover a vendor (toml spec) parse failure


def _subject_module():
    from kiss_rdb.magnetics_ import in_file_attributes_via_identifier_and_lines as _  # noqa: E501
    return _


def cover_me(msg):
    raise Exception(f'cover me: {msg}')


_in_file_attributes = 'in_file_attributes'


if __name__ == '__main__':
    unittest.main()

# #born.
