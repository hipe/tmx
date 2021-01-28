from modality_agnostic.test_support.common import \
    listener_and_emissions_for, lazy, \
    dangerous_memoize_in_child_classes as shared_subject_in_child_classes
from kiss_rdb_test.common_initial_state import functions_for
import unittest


class CommonCase(unittest.TestCase):

    def expect_expected_message(self):
        act, = self.exactly_one_emission.to_messages()
        needle = self.expected_message_needle()
        self.assertIn(needle, act)

    def expect_expected_failure_category(self):
        exp = 'error', 'structure', self.expected_failure_category()
        act = self.exactly_one_emission.channel
        self.assertSequenceEqual(act, exp)

    @property
    def exactly_one_emission(self):
        dct = self.end_state
        assert 'result' not in dct
        emis = dct['emissions']
        emi, = emis
        return emi

    @property
    @shared_subject_in_child_classes
    def end_state(self):
        return {k: v for k, v in self.end_state_keys_and_values()}

    def end_state_keys_and_values(self):
        listener, emis = listener_and_emissions_for(self)

        # Hack a builder function that you inspect the result from
        def fsr(ci):
            my_reader = sm.Caching_FS_Reader_(ci, max_num_lines_to_cache=mn)
            yuck.append(my_reader)
            yuck.append(self.take_snapshot_before(my_reader))
            return my_reader
        yuck = []
        mn = self.given_max_num_lines_to_cache()

        sm = subject_module()

        # Build the collection
        coll_path = this_one_dir()
        from kiss_rdb.storage_adapters_.eno import \
            mutable_eno_collection_via as func
        coll = func(coll_path, fsr=fsr)

        rest = () if (eid := self.given_EID()) is None else (eid,)
        for k, v in self.given_performance(listener, coll, *rest):
            yield k, v

        my_reader, before = yuck
        after = self.take_snapshot_after(my_reader)

        do_BA = (before is not None or after is not None)
        if do_BA:
            yield 'before', before

        if 0 != len(emis):
            yield 'emissions', tuple(emis)

        if do_BA:
            yield 'after', after

    def take_snapshot_before(self, _):
        pass

    def given_performance(self, listener, coll, eid):
        res = coll.retrieve_entity(eid, listener)
        if res is not None:
            yield 'result', res

    def take_snapshot_after(self, _):
        pass

    # ==

    def given_max_num_lines_to_cache(_):
        return 0  # for each next file required, rotate out the last one

    def given_EID(_):
        pass

    do_debug = True


# [4854-4860]  👀

# for i in {1..14} ; do print "thing-$i $i" ; done > x
# cat x | ./script/dev/distribute-space 4854 4860


class Case4854_029_no_file_no_ent(CommonCase):

    def test_010_failure_category(self):
        self.expect_expected_failure_category()

    def test_020_message(self):
        self.expect_expected_message()

    def expected_message_needle(_):
        return 'No such file or directory'

    def expected_failure_category(_):
        return 'entity_not_found'

    def given_EID(_):
        return 'PBR'


class Case4854_114_yes_file_no_ent(CommonCase):

    def test_010_failure_category(self):
        self.expect_expected_failure_category()

    def test_020_message(self):
        self.expect_expected_message()

    def expected_message_needle(_):
        return '3 entities in file'

    def expected_failure_category(_):
        return 'entity_not_found'

    def given_EID(_):
        return 'B7J'


class Case4854_257_retrieve_OK_intro(CommonCase):

    def test_010_retrieve_OK(self):
        dct = self.end_state
        assert 'emissions' not in dct
        res = dct['result']
        assert 'B7G' == res.identifier.to_string()

    def test_020_it_looks_like_it_cached(self):
        dct = self.end_state
        (b_paths, b_ents), (a_paths, a_ents) = dct['before'], dct['after']
        act = b_paths, b_ents, a_paths, a_ents
        exp = 0, 0, 1, 3
        self.assertSequenceEqual(act, exp)

    def take_snapshot_after(_, myfsr):
        return num_cached_paths_and_num_cached_entities_of(myfsr)

    def take_snapshot_before(_, myfsr):
        return num_cached_paths_and_num_cached_entities_of(myfsr)

    def given_EID(_):
        return 'B7G'


class Case4854_714_long_story_show_stock_rotate(CommonCase):
    """
    Break this up into two (or more?) smaller stories if you want:

    We re-request a same entity twice in a row while trying to assert that
    we got the cached entity the second time. Also:

    To activate the case of "stock rotation", we had set a "max number of lines
    to cache" that is low enough that we exceed it during the course of our
    performance, but high enough that it is not exceeded until sometime after
    the first request.

    Finally, we re-request the first entity again to see that its file
    gets cached again (that stale-ing purged all index of it).

    At writing here's the lengths of our files:

    - 2/H.eno:  6 lines
    - B/7.eno: 17 lines
    - B/8.eno:  9 lines
    - B/9.eno: 17 lines

    The sum of the two smallest files is 15 lines.
    Set that as your max number of lines to cache.

    Retrieve an entity from one of those two files. Assert we cached the file.
    Retrieve the same entity. Assert no change in cache consituency.
    Furthermore assert same internal python object ID's yikes.
    Retrieve an entity from the other file. Assert BOTH files cached.
    (Note we take it right up to the max number of lines. Exact number.)
    Retrieve an entity from a file other than those two files.
    Assert only that last file is cached. (Both previous files rotated out.
    """

    def given_performance(self, listener, coll):
        def go(eid):
            ent = coll.retrieve_entity(eid, coll)
            act = ent.identifier.to_string()
            assert eid == act
            return ent

        def snapshot():
            paths_dct, eid_dct = these_two_yikes(myfsr)
            f = path_cleaner()
            paths = tuple(f(p) for p in paths_dct.keys())
            return paths, tuple(eid_dct.keys())

        # Retrieve an entity from the second smallest file
        ent = go('B8H')
        myfsr = self.awful
        delattr(self, 'awful')
        yield 'object_ID_of_the_first_entity', id(ent)
        yield 'snapshot_ONE', snapshot()

        # Retrieve the same entity again
        ent = go('B8H')
        yield 'object_ID_of_the_first_entity_AGAIN', id(ent)
        yield 'snapshot_TWO', snapshot()

        # Retrieve an entity from the smallest file
        ent = go('2HJ')
        yield 'snapshot_THREE', snapshot()

        # Retrieve any entity to trip the limit
        ent = go('B9J')
        yield 'snapshot_FOUR_pete_tong_essential_mix', snapshot()

        # Retrieve that one entity a third time
        ent = go('B8H')
        yield 'object_ID_of_the_first_entity_a_third_time', id(ent)
        yield 'final_snapshot', snapshot()

    def take_snapshot_before(self, fsr):
        self.awful = fsr

    def given_max_num_lines_to_cache(_):
        return 15

    def test_010_retrieving_the_entity_again_got_same_object(self):
        dct = self.end_state
        before = dct['object_ID_of_the_first_entity']
        after = dct['object_ID_of_the_first_entity_AGAIN']
        assert before == after

    def test_020_snapshot_after_cache_looks_right_and_cache_is_same(self):
        dct = self.end_state
        before = dct['snapshot_ONE']
        after = dct['snapshot_TWO']
        self.assertSequenceEqual(before, (('B/8',), ('B8H',)))
        self.assertSequenceEqual(before, after)

    def test_030_adding_a_seconcd_cached_file_didnt_stale_the_prev_file(self):
        paths, eids = self.end_state['snapshot_THREE']
        self.assertSequenceEqual(paths, ('B/8', '2/H'))
        self.assertSequenceEqual(eids, ('B8H', '2HJ'))

    def test_040_holy_smokes_the_cache_purged(self):
        paths, eids = self.end_state['snapshot_FOUR_pete_tong_essential_mix']
        self.assertSequenceEqual(paths, ('B/9',))
        self.assertSequenceEqual(eids, ('B9G', 'B9H', 'B9J'))

    def test_050_made_old_entity_anew(self):
        dct = self.end_state
        oid_before = dct['object_ID_of_the_first_entity']
        oid_after = dct['object_ID_of_the_first_entity_a_third_time']
        assert oid_before != oid_after
        paths, eids = dct['final_snapshot']
        self.assertSequenceEqual(paths, ('B/8',))
        self.assertSequenceEqual(eids, ('B8H',))


class Case4855_400_traverse_when_caching(CommonCase):

    def test_010(self):
        es = self.end_state
        tup = es['WOW_ENTITIES']
        act = tuple(ent.identifier.to_string() for ent in tup)
        exp = '2HJ', 'B7E', 'B7F', 'B7G', 'B8H', 'B9G', 'B9H', 'B9J'
        self.assertSequenceEqual(act, exp)

    def take_snapshot_before(_, myfsr):
        return num_cached_paths_and_num_cached_entities_of(myfsr)

    def given_performance(self, listener, coll):
        with coll.open_schema_and_entity_traversal(listener) as (_, ents):
            res = tuple(ents)
        yield 'WOW_ENTITIES', res

    def take_snapshot_after(_, myfsr):
        return num_cached_paths_and_num_cached_entities_of(myfsr)

    do_debug = True


def num_cached_paths_and_num_cached_entities_of(myfsr):
    paths_dct, eids_dct = these_two_yikes(myfsr)
    num_paths = len(paths_dct)
    num_ents = len(eids_dct)
    return num_paths, num_ents


def these_two_yikes(myfsr):
    one = myfsr._file_reader_via_path
    two = myfsr._cached_path_via_EID
    return one, two


@lazy
def path_cleaner():   # "/foo/bar/8/J.eno"  =>  "8/J"
    def clean_path(path):
        return rx.search(path)[1]
    import re
    from os.path import sep
    s = re.escape(sep)
    rx = re.compile(''.join((s, '([A-Z0-9]', s, r'[A-Z0-9])\.eno\Z')))
    return clean_path


def this_one_dir():
    return fixture_directory_for('050-canon-main')


fixture_directory_for = functions_for('eno').fixture_directory_for


def subject_module():
    import kiss_rdb.storage_adapters_.eno._caching_layer as m
    return m


if __name__ == '__main__':
    unittest.main()

# #born
