from kiss_rdb_test.CUD import \
        filesystem_recordings_of, build_filesystem_expecting_num_file_rewrites
from kiss_rdb_test.common_initial_state import functions_for, unindent
from modality_agnostic.test_support.common import \
        dangerous_memoize as shared_subject, lazy
import unittest


CommonCase = unittest.TestCase


# Case4358 traverse when fail


class Case4359_traversal_OK(CommonCase):

    def test_100_EVERYTHING(self):  # NOTE subject not memoized
        coll = self.given_collection()
        with coll.open_identifier_traversal(no_listener) as idens:
            act = tuple(iden.to_string() for iden in idens)
        self.assertSequenceEqual(act, ('24', '68'))

    # NOTE not memoized
    def given_collection(self):
        return build_collection()


# Case4360 retrieve fail


class Case4361_retrieve_OK(CommonCase):

    def test_100_EVERYTHING(self):  # NOTE subject not memoized
        ent = self.build_end_state()
        dct = ent.to_dictionary_two_deep_as_storage_adapter_entity()
        self.assertEqual(dct['identifier_string'], '68')
        dct = dct['core_attributes']
        self.assertEqual(dct, {'xx': 'xx of 68'})

    # NOTE not memoized
    def build_end_state(self):
        coll = build_collection(dir_path_most_common())
        return coll.retrieve_entity('68', no_listener)


# Case4362 delete fail


class Case4364_delete_OK_CAPTURE_GREEDY_COMMENTS_ISSUE(CommonCase):

    def test_100_EVERYTHING(self):  # NOTE subject not memoized

        rec, = self.recorded_file_rewrites

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
    @property
    def recorded_file_rewrites(self):
        return filesystem_recordings_of(self, 'delete', '68')

    def given_collection(self):  # (same as #here1)
        return build_collection(
                dir_path=dir_path_most_common(),
                filesystem=build_filesystem_expecting_num_file_rewrites(1))


# Case4365 update fail


class Case4366_update_OK(CommonCase):
    # remarkably, update for single file works with no modifcation to code
    # (beyond what we did to modify code for delete).

    def test_100_EVERYTHING(self):  # NOTE subject not memoized
        rec, = self.recorded_file_rewrites

        _expected = tuple(unindent("""
        [item.24.attributes]
        xw = "nü"
        xx = "xx of 24 updated"
        [item.68.attributes]
        """))

        _actual = rec.lines[0:4]

        self.assertSequenceEqual(_actual, _expected)

    # NOTE not memoized
    @property
    def recorded_file_rewrites(self):  # NOTE not memoized
        return filesystem_recordings_of(self, 'update', '24', (
            ('update_attribute', 'xx', 'xx of 24 updated'),
            ('create_attribute', 'xw', 'nü'),
            ))

    def given_collection(self):  # (same as #here1)
        return build_collection(
                dir_path=dir_path_most_common(),
                filesystem=build_filesystem_expecting_num_file_rewrites(1))


# Case4367 create fail


class Case4368_create_into_existing_file(CommonCase):
    """note that we only expect one file rewrite here as opposed to the usual 2
    """

    def test_100_succeeds(self):
        self.recorded_file_rewrites

    def test_200_entities_file_rewritten_OK(self):
        rec, = self.recorded_file_rewrites
        _actual = _last_1_of_path(rec.path)

        self.assertEqual(_actual, 'entities.toml')

        _hi = rec.lines[2:6]

        _expect = tuple(unindent("""
        [item.43.attributes]
        abc = "123"
        de_fg = "true"
        [item.68.attributes]
        """))

        self.assertSequenceEqual(_hi, _expect)

    @shared_subject
    def recorded_file_rewrites(self):
        cuds = {
                'abc': '123',
                'de_fg': 'true',
                }
        return filesystem_recordings_of(self, 'create', cuds)

    def given_collection(self):

        def random_number_generator(pool_size):
            assert(pool_size == 1022)  # 1024 - 2
            return 64  # (as iid) 42 per [#867.S] CLI

        return build_collection(
                dir_path=dir_path_most_common(),
                random_number_generator=random_number_generator,
                filesystem=build_filesystem_expecting_num_file_rewrites(1))


# == assertion support

def _last_1_of_path(path):
    import re
    return re.search(r'/([^/]+)$', path)[1]


# == setup support

def build_collection(dir_path=None, **injections):
    if dir_path is None:
        dir_path = dir_path_most_common()
    schema = _always_same_schema()
    from kiss_rdb_test.toml_support import build_collection as func
    return func(dir_path, schema, injections)

@lazy
def dir_path_most_common():
    return functions_for('toml').fixture_directory_for('056-single-file')


@lazy
def _always_same_schema():
    from kiss_rdb.storage_adapters_.toml.schema_via_file_lines import Schema_
    return Schema_(storage_schema='32^2')


def subject_module():
    from kiss_rdb.storage_adapters_.toml import collection_via_directory as _
    return _


def _throwing_listener():
    from modality_agnostic import throwing_listener as func
    return func


no_listener = None


if __name__ == '__main__':
    unittest.main()

# #born.
