from kiss_rdb_test.common_initial_state import (
        debugging_listener,
        functions_for,
        unindent,
        )
from kiss_rdb_test.CUD import (
        wrap_collection,
        filesystem_recordings_of,
        build_filesystem_expecting_num_file_rewrites,
        )
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        memoize,
        )
import unittest


_CommonCase = unittest.TestCase


# Case4358 traverse when fail


class Case4359_traversal_OK(_CommonCase):

    def test_100_EVERYTHING(self):  # NOTE subject not memoized

        def f(id_obj):
            return id_obj.to_string()  # ..

        these = self.subject_collection().to_identifier_stream(_no_listener)
        assert(these)
        _actual = (f(o) for o in these)

        _expected = (
                '24',
                '68',
                )

        _actual = tuple(_actual)

        self.assertSequenceEqual(_actual, _expected)

    # NOTE not memoized
    def subject_collection(self):
        return _build_collection(
                dir_path=_dir_path_most_common(),
                filesystem=None)


# Case4360 retrieve fail


class Case4361_retrieve_OK(_CommonCase):

    def test_100_EVERYTHING(self):  # NOTE subject not memoized
        dct = self._result_value()

        self.assertEqual(dct['identifier_string'], '68')
        dct = dct['core_attributes']
        self.assertEqual(dct, {'xx': 'xx of 68'})

    # NOTE not memoized
    def _result_value(self):
        _col = _build_collection(
                dir_path=_dir_path_most_common(),
                filesystem=None)

        _col = wrap_collection(_col)

        # _listener = _no_listener
        _listener = debugging_listener
        return _col.retrieve_entity('68', _listener)


# Case4362 delete fail


class Case4364_delete_OK_CAPTURE_GREEDY_COMMENTS_ISSUE(_CommonCase):

    def test_100_EVERYTHING(self):  # NOTE subject not memoized

        rec, = self.recorded_file_rewrites()

        """.#open [#867.H] here (also) is doing the bad thing where it
        greedily consumes all comments and whitespace after an entity and
        thinks of that is part of the entity. the desired behavior would be
        to walk-back the cut-off point to just before the first blank line
        after the entity, but this will take busy work..
        """

        _expect = tuple(unindent("""
        [item.24.attributes]
        xx = "xx of 24"
        """))

        self.assertSequenceEqual(rec.lines, _expect)

    # NOTE not memoized
    def recorded_file_rewrites(self):
        return filesystem_recordings_of(self, 'delete', '68')

    def subject_collection(self):  # (same as #here1)
        return wrap_collection(_build_collection(
                dir_path=_dir_path_most_common(),
                filesystem=build_filesystem_expecting_num_file_rewrites(1)))


# Case4365 update fail


class Case4366_update_OK(_CommonCase):
    # remarkably, update for single file works with no modifcation to code
    # (beyond what we did to modify code for delete).

    def test_100_EVERYTHING(self):  # NOTE subject not memoized
        rec, = self.recorded_file_rewrites()

        _expected = tuple(unindent("""
        [item.24.attributes]
        xw = "nü"
        xx = "xx of 24 updated"
        [item.68.attributes]
        """))

        _actual = rec.lines[0:4]

        self.assertSequenceEqual(_actual, _expected)

    # NOTE not memoized
    def recorded_file_rewrites(self):  # NOTE not memoized
        return filesystem_recordings_of(self, 'update', '24', (
            ('update_attribute', 'xx', 'xx of 24 updated'),
            ('create_attribute', 'xw', 'nü'),
            ))

    def subject_collection(self):  # (same as #here1)
        return wrap_collection(_build_collection(
                dir_path=_dir_path_most_common(),
                filesystem=build_filesystem_expecting_num_file_rewrites(1)))


# Case4367 create fail


class Case4368_create_into_existing_file(_CommonCase):
    """note that we only expect one file rewrite here as opposed to the usual 2
    """

    def test_100_succeeds(self):
        self.recorded_file_rewrites()

    def test_200_entities_file_rewritten_OK(self):
        rec, = self.recorded_file_rewrites()
        _actual = _last_1_of_path(rec.path)

        self.assertEqual(_actual, 'entities.toml')

        _hi = rec.lines[2:6]

        _expect = tuple(unindent("""
        [item.43.attributes]
        abc = "123"
        de-fg = "true"
        [item.68.attributes]
        """))

        self.assertSequenceEqual(_hi, _expect)

    @shared_subject
    def recorded_file_rewrites(self):
        cuds = {
                'abc': '123',
                'de-fg': 'true',
                }
        return filesystem_recordings_of(self, 'create', cuds)

    def subject_collection(self):

        def random_number_generator(pool_size):
            assert(pool_size == 1022)  # 1024 - 2
            return 64  # (as iid) 42 per [#867.S] CLI

        return wrap_collection(_build_collection(
                dir_path=_dir_path_most_common(),
                random_number_generator=random_number_generator,
                filesystem=build_filesystem_expecting_num_file_rewrites(1)))


# == assertion support

def _last_1_of_path(path):
    import re
    return re.search(r'/([^/]+)$', path)[1]


# == setup support

def _build_collection(dir_path, **injections):
    return _main_module().collection_via_directory_and_schema(
            collection_directory_path=dir_path,
            collection_schema=_always_same_schema(),
            **injections)


@memoize
def _dir_path_most_common():
    return functions_for('toml').fixture_directory_path('056-single-file')


@memoize
def _always_same_schema():
    from kiss_rdb.storage_adapters_.toml.schema_via_file_lines import Schema_
    return Schema_(storage_schema='32^2')


def _main_module():
    from kiss_rdb.storage_adapters_.toml import collection_via_directory as _
    return _


def _throwing_listener():
    from kiss_rdb import THROWING_LISTENER
    return THROWING_LISTENER


_no_listener = None


if __name__ == '__main__':
    unittest.main()

# #born.
