from kiss_rdb_test.common_initial_state import (
        debugging_listener as _debugging_listener,
        functions_for,
        unindent_with_dot_hack,
        unindent as _unindent,
        )
from kiss_rdb_test.CUD import (
        CUD_Methods,
        filesystem_expecting_no_rewrites,
        build_filesystem_expecting_num_file_rewrites,
        )
from kiss_rdb_test import storage_adapter_canon
from modality_agnostic.test_support import structured_emission as se_lib
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        memoize,
        )
import unittest


canon = storage_adapter_canon.produce_agent()


class _CommonCase(CUD_Methods, unittest.TestCase):

    @property
    def left_half(self):
        return self.two_halves()[0]

    @property
    def right_half(self):
        return self.two_halves()[1]

    # == THESE

    def listener(self):
        if False:
            return _debugging_listener()


class Case4316_collection_can_be_built_with_noent_dir(_CommonCase):

    def test_100(self):
        self.assertIsNotNone(_collection_with_noent_dir())


class Case4317_identifier_with_invalid_chars(_CommonCase):

    def test_100_reason(self):
        _actual = self.left_half
        self.assertEqual(_actual, "invalid character 'b' in identifier")

    def test_200_suggestion(self):
        _actual = self.right_half
        _expected = 'identifier digits must be [0-9A-Z] minus 0, 1, O and I.'
        self.assertEqual(_actual, _expected)

    @shared_subject
    def two_halves(self):
        _ = self.delete_expecting_failure('AbC')
        return _['reason'].split(' - ')

    def subject_collection(self):
        return _collection_with_NO_filesystem()


class Case4318_identifier_too_short_or_long(_CommonCase):

    def test_100_complaint(self):
        _actual = self.left_half
        self.assertEqual(_actual, "too many digits in identifier 'ABCD'")

    def test_200_reason(self):
        _actual = self.right_half
        self.assertEqual(_actual, "need 3, had 4")

    @shared_subject
    def two_halves(self):
        _ = self.delete_expecting_failure('ABCD')
        return _['reason'].split(' - ')

    def subject_collection(self):
        return _collection_with_NO_filesystem()


class Case4319_some_top_directory_not_found(_CommonCase):

    def test_100_complaint(self):
        _actual = self.left_half
        _expect = "for 'entities/A/B.toml', no such directory"
        self.assertEqual(_actual, _expect)

    def test_200_reason(self):
        actual = self.right_half
        _tail = actual[(actual.rindex('/') + 1):]
        self.assertEqual(_tail, '000-no-ent')

    @shared_subject
    def two_halves(self):
        _ = self.delete_expecting_failure('ABC')
        return _['reason'].split(' - ')

    def subject_collection(self):
        return _collection_with_noent_dir()


class Case4320_file_not_found(_CommonCase):

    def test_100_complaint(self):
        _actual = self.left_half
        self.assertEqual(_actual, 'no such file')

    def test_200_reason(self):
        _tail = _last_three_path_parts(self.right_half)
        self.assertEqual(_tail, 'entities/B/4.toml')

    @shared_subject
    def two_halves(self):
        _ = self.delete_expecting_failure('B4F')
        return _['reason'].split(' - ')

    def subject_collection(self):
        return _build_collection(
                dir_path=_dir_path_most_common(),
                filesystem=None)


class Case4322_entity_not_found(_CommonCase):

    def test_100_failed_to_rewrite(self):
        self._structure_and_recordings()  # because #here2

    def test_200_message_sadly_has_no_context_yet(self):
        sct = self._structure_and_recordings()[0]
        self.assertEqual(sct['reason'], "entity 'B7D' is not in file")

    def test_300_no_files_rewritten(self):
        recs = self._structure_and_recordings()[1]
        self.assertEqual(recs, 'hi there were no file rewrites')

    @shared_subject
    def _structure_and_recordings(self):
        sct, recs = self.delete_expecting_failure_and_recordings('B7D')
        return sct, recs

    def subject_collection(self):
        return _build_collection(
                dir_path=_dir_path_most_common(),
                filesystem=filesystem_expecting_no_rewrites())


# Case4323 - not found because bad ID
# Case4324 - not found because no dir
# Case4325 - not found because no file
# ✔️ Case4326 - not found because no ent in file
# ✔️ Case4259 - win


class Case4326_retrieve_no_ent_in_file(_CommonCase):  # #midpoint

    def test_100_emits_error_structure(self):
        col = _collection_with_NO_filesystem()

        def f(listener):
            return col.retrieve_entity('B9F', listener)
        sct = self.run_this_expecting_failure(f)

        # ~(Case4116-Case4134) cover the detailed components from this.
        # this is just sort of a "curb-check" contact point integration check

        self.assertEqual(sct['input_error_type'], 'not_found')
        self.assertEqual(sct['identifier_string'], 'B9F')


class Case4328_retrieve(_CommonCase):

    def test_100_identifier_is_in_result_dictionary(self):
        _actual = self._this_dict()['identifier_string']
        self.assertEqual(_actual, 'B9H')

    def test_200_simple_immediate_values_are_there(self):
        dct = self._this_dict()['core_attributes']
        self.assertEqual(dct['thing-A'], "hi i'm B9H")
        self.assertEqual(dct['thing-B'], "hey i'm B9H")

    @shared_subject
    def _this_dict(self):
        _col = _collection_with_NO_filesystem()
        return _col.retrieve_entity('B9H', _no_listener)


class Case4329_delete_simplified_typical(_CommonCase):

    def test_100_would_have_succeeded(self):  # we didn't really write a file
        self.recorded_file_rewrites()

    def test_200_path_is_path(self):
        path = self.entity_file_rewrite().path
        tail = _last_3_of_path(path)
        self.assertEqual(tail, 'entities/B/7.toml')

    def test_300_entities_file_lines_look_good(self):
        expect = tuple(_unindent("""
        [item.B7E.attributes]
        thing-1 = "hi E"
        thing-2 = "hey E"

        [item.B7G.attributes]
        thing-1 = "hi G"
        thing-2 = "hey G"
        """))

        self.assertSequenceEqual(self.entity_file_rewrite().lines, expect)

    def test_400_index_was_rewritten(self):
        _1, _2, _3, _4, _5, _6 = self.index_file_rewrite().lines  # yuck #here3
        self.assertEqual(_4, '7 (                        E   G)\n')
        # NOTE there is no 'F' here -----------------------^

    @shared_subject
    def recorded_file_rewrites(self):
        return self.delete_expecting_success('B7F')

    def subject_collection(self):
        return _build_collection_expecting_common_number_of_rewrites()


class Case4330_delete_that_leaves_file_empty(_CommonCase):

    def test_100_would_have_succeeded(self):
        self.recorded_file_rewrites()

    def test_200_path_is_path(self):
        path = self.entity_file_rewrite().path
        import re
        tail = re.search(r'/([^/]+/[^/]+/[^/]+)$', path)[1]
        self.assertEqual(tail, 'entities/B/8.toml')

    def test_300_entities_file_IS_TRUCATED_TO_ZERO(self):
        self.assertSequenceEqual(self.entity_file_rewrite().lines, ())

    def test_400_index_was_rewritten(self):
        _1, _2, _3, _4, _5 = self.index_file_rewrite().lines  # yuck #here3

        # we're gonna look at the fourth line and the fifth line:

        self.assertEqual(_4[0:3], '7 (')
        # (this "spot" here used to be 8)
        self.assertEqual(_5[0:3], '9 (')

    @shared_subject
    def recorded_file_rewrites(self):
        return self.delete_expecting_success('B8H')

    def subject_collection(self):
        return _build_collection_expecting_common_number_of_rewrites()


# Case4331: delete when index file is left empty! (delete the last entity)


class Case4332_update_OK(_CommonCase):
    """
    at #history-A.1 we had to un-cover this issue, but re-cover it by creating
    "thing-C" instead of "thing-2" (numbers come before leters lexically)

    .#open [#867.H] it "thinks of" {whitespace|comments} as being

    associated with the attribute not the entity block so the behavior
    here in terms of where blank lines end up is not what would probably
    be expected..
    """

    def test_100_result_is_a_two_tuple_of_before_and_after_entities(self):
        self._canon_case.confirm_result_is_before_and_after_entities(self)

    def test_200_the_before_entity_has_the_before_values(self):
        self._canon_case.confirm_the_before_entity_has_the_before_values(self)

    def test_300_the_after_entity_has_the_after_values(self):
        self._canon_case.confirm_the_after_entity_has_the_after_values(self)

    def test_400_emitted_accordingly(self):
        self._canon_case.confirm_emitted_accordingly(self)

    """ABOUT THIS:

    def test_500_retrieve_afterwards_shows_updated_value(self):
       self._canon_case.confirm_retrieve_after_shows_updated_value(self)

    ☝️ that sure would be cool. but out of scope. Either ☞ use the real FS
    ☞ mock our fake FS ☞ just live with the fact that we aren't fully
    compliant ☞ introduce graded compliant where we aren't "long-running"
    certified (which, we aren't)
    """

    def test_600_new_file_content_looks_okay(self):

        es = self.end_state()
        coll = es['collection']
        recs = coll._filesystem.FINISH_AS_HACKY_SPY()

        rec, = recs  # onyl one file rewrite
        path = rec.path
        lines = rec.lines

        # --

        self.assertEqual(_last_three_path_parts(path), 'entities/B/9.toml')
        _expected = tuple(_unindent(self._expecting_these()))

        self.assertSequenceEqual(lines, _expected)

    def _expecting_these(self):
        return '''
        [item.B9G.attributes]
        hi-G = "hey G"

        [item.B9H.attributes]
        thing-2 = "I'm created \\"thing-2\\""
        thing-B = "I'm modified \\"thing-B\\""

        [item.B9J.attributes]
        hi-J = "hey J"
        '''

    @shared_subject
    def end_state(self):
        return self._canon_case.build_end_state(self)

    def request_tuple_for_update_that_will_succeed(self):
        # #todo should be delete_attribute etc
        return 'B9H', (
            ('delete', 'thing-A'),
            ('update', 'thing-B', "I'm modified \"thing-B\""),
            ('create', 'thing-2', "I'm created \"thing-2\""))

    def subject_collection(self):
        return _build_collection(
                dir_path=_dir_path_most_common(),
                filesystem=build_filesystem_expecting_num_file_rewrites(1))

    @property
    def _canon_case(self):
        return canon.case_of_update_OK


class Case4334_simplified_typical_traversal_when_no_collection_dir(_CommonCase):  # noqa: E501

    def test_100_channel(self):
        _channel = self._these_two()[0]
        _expect = (
                'error',
                'expression',
                'argument_error',
                'no_such_directory')
        self.assertSequenceEqual(_channel, _expect)

    def test_200_message(self):
        _payloader = self._these_two()[1]
        message, = tuple(_payloader())  # assert only one line
        head, path = message.split(' - ')  # assert has a dash in it
        _expect = 'collection does not exist because no such directory'
        self.assertEqual(head, _expect)

        # regexp schmegex
        expect = '000-no-ent/entities'
        _actual = path[-len(expect):]
        self.assertEqual(_actual, expect)

    @shared_subject
    def _these_two(self):

        listener, emissioner = se_lib.listener_and_emissioner_for(self)

        _itr = self.subject_collection().to_identifier_stream(listener)
        for x in _itr:
            self.fail()

        channel, payloader = emissioner()
        return channel, payloader

    def subject_collection(self):
        return _build_collection(
                dir_path=_dir_path_of_no_ent(),
                filesystem=None)


class Case4335_simplified_typical_traversal(_CommonCase):

    def test_100_everything(self):

        def f(id_obj):
            return id_obj.to_string()  # ..

        _these = self.subject_collection().to_identifier_stream(None)
        _actual = (f(o) for o in _these)

        _expected = (
                '2HJ',
                'B7E',
                'B7F',
                'B7G',
                'B8H',
                'B9G',
                'B9H',
                'B9J',
                )

        _actual = tuple(_actual)

        self.assertSequenceEqual(_actual, _expected)

    def subject_collection(self):
        return _build_collection(
                dir_path=_dir_path_most_common(),
                filesystem=None)


class Case4336_create_into_existing_file(_CommonCase):

    def test_100_succeeds(self):
        self.recorded_file_rewrites()

    def test_250_entities_file_rewrite_OK(self):
        efr = self.entity_file_rewrite()
        self.assertEqual(_last_3_of_path(efr.path), 'entities/2/H.toml')

        expect = tuple(_unindent("""
        [item.2HG.attributes]
        abc = "123"
        de-fg = "true"
        [item.2HJ.attributes]
        """))

        # no blank line to separate, huh?

        self.assertSequenceEqual(efr.lines, expect)

    def test_400_index_rewrite_OK(self):
        ifr = self.index_file_rewrite()
        actual = ifr.lines[0:2]

        expect = tuple(unindent_with_dot_hack("""
        .
         2
        H (                            G   J)
        """))

        self.assertSequenceEqual(actual, expect)

    @shared_subject
    def recorded_file_rewrites(self):
        cuds = (
            ('create', 'abc', '123'),
            ('create', 'de-fg', 'true'),
            )

        return self.create_expecting_success(cuds)

    def listener(self):
        return _throwing_listener()

    def subject_collection(self):

        random_number_generator = _random_number_generator_for(494)
        # "2HG" as int per [#867.S] CLI

        return _build_collection(
                dir_path=_dir_path_most_common(),
                random_number_generator=random_number_generator,
                filesystem=build_filesystem_expecting_num_file_rewrites(2))


# Case4337 create failure cleans up created file


"""☝️ The whole purpose of "cleanup functions" is to enable us to
handle the case of when we have created a new entities file and the
transaction fails. as it turns out, this case is perhaps logically impossible
for us to trigger except under exceedingly contrived circumstances:

- you want to start with a "corrupt" entities file? that means the file will
be seen as existing and won't hit this point.

- start with corrupt index file? A) that throws an exception and B) it doesn't
get us far enough.

- try to make an invalid "edit (create) entity" request? then it doesn't get
as far as creating the new entities file.
"""


class Case4338_create_into_noent_file(_CommonCase):
    """Case4338 Create into noent file - cleanup to this is NASTY
    """

    def test_100_succeeds(self):
        self.recorded_file_rewrites()

    def test_250_entities_file_rewrite_OK(self):
        efr = self.entity_file_rewrite()
        self.assertEqual(_last_3_of_path(efr.path), 'entities/2/J.toml')

        expect = tuple(_unindent("""
        [item.2J3.attributes]
        abc = "456"
        de-fg = "false"
        """))

        self.assertSequenceEqual(efr.lines, expect)

    def test_400_index_rewrite_OK(self):
        ifr = self.index_file_rewrite()
        actual = ifr.lines[2]
        self.assertEqual(actual, 'J (  3)\n')

    @shared_subject
    def recorded_file_rewrites(self):
        cuds = (
            ('create', 'abc', '456'),
            ('create', 'de-fg', 'false'),
            )

        entities_path = _entities_file_path_for_2J()

        res = self.create_expecting_success(cuds)

        # == BEGIN NASTY - don't actually leave that new file in the fixture
        import os
        os.unlink(entities_path)  # results in none. raises on failure. NASTY
        # == END

        return res

    def listener(self):
        return _throwing_listener()

    def subject_collection(self):
        random_number_generator = _random_number_generator_for(512)  # 2J2 but

        return _build_collection(
                dir_path=_dir_path_most_common(),
                random_number_generator=random_number_generator,
                filesystem=build_filesystem_expecting_num_file_rewrites(2))


def _last_3_of_path(path):
    import re
    return re.search(r'/([^/]+/[^/]+/[^/]+)$', path)[1]


@memoize
def _collection_with_expecting_no_rewrites():
    return _build_collection(
            dir_path=_dir_path_most_common(),
            filesystem=filesystem_expecting_no_rewrites())


@memoize
def _collection_with_noent_dir():
    return _build_collection(
            dir_path=_dir_path_of_no_ent(),
            filesystem='no filesystem xyz121')


@memoize
def _collection_with_NO_filesystem():
    return _build_collection(
            dir_path=_dir_path_most_common(),
            filesystem='no filesystem xyz122')


@memoize
def _entities_file_path_for_2J():
    import os.path as os_path
    return os_path.join(_dir_path_most_common(), 'entities', '2', 'J.toml')


@memoize
def _dir_path_most_common():
    return fixture_directory_path('050-rumspringa')


@memoize
def _dir_path_of_no_ent():
    return fixture_directory_path('000-no-ent')


fixture_directory_path = functions_for('toml').fixture_directory_path


def _last_three_path_parts(path):
    import re
    return re.search(r'[^/]+(?:/[^/]+){2}$', path)[0]


def _random_number_generator_for(random_number):
    count = 0

    def random_number_generator(pool_size):
        assert(32760 == pool_size)
        nonlocal count
        count += 1
        assert(1 == count)
        return random_number
    return random_number_generator


def _build_collection_expecting_common_number_of_rewrites():
    return _build_collection(
            dir_path=_dir_path_most_common(),
            filesystem=build_filesystem_expecting_num_file_rewrites(2))


def _build_collection(dir_path, filesystem, random_number_generator=None):
    return _subject_module().collection_via_directory_and_schema(
            collection_directory_path=dir_path,
            collection_schema=_always_same_schema(),
            random_number_generator=random_number_generator,
            filesystem=filesystem)


@memoize
def _always_same_schema():
    from kiss_rdb.storage_adapters_.toml import schema_via_file_lines as _
    return _._Schema(storage_schema='32x32x32')


def _subject_module():
    from kiss_rdb.storage_adapters_.toml import collection_via_directory as _
    return _


def _throwing_listener():
    from kiss_rdb import THROWING_LISTENER
    return THROWING_LISTENER


def _no_listener(*chan, payloader):
    assert(False)  # when this trips, use _debugging_listener()


if __name__ == '__main__':
    unittest.main()

# #history-A.1
# #born.
