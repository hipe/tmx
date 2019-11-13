from kiss_rdb_test.common_initial_state import (
        StubCollectionIdentity,
        functions_for,
        unindent_with_dot_hack,
        unindent as _unindent)
from kiss_rdb_test.CUD import (
        run_for,
        wrap_collection,
        filesystem_recordings_of,
        filesystem_expecting_no_rewrites,
        build_filesystem_expecting_num_file_rewrites)
from kiss_rdb_test import storage_adapter_canon
from modality_agnostic.memoization import (
        Counter,
        dangerous_memoize as shared_subject,
        lazy)
import unittest


canon = storage_adapter_canon.produce_agent()


def common_component(f):  # decorator
    def use_f(tc):
        return getattr(tc.end_components(), component_name)
    component_name = f.__name__
    return use_f


class _CommonCase(unittest.TestCase):

    @property
    @common_component
    def left_half(self):
        pass

    @property
    @common_component
    def right_half(self):
        pass

    @property
    @common_component
    def error_category(self):
        pass

    def entity_file_rewrite(self):
        return self.recorded_file_rewrites()[0]  # (per [#867.Q], is first)

    def index_file_rewrite(self):
        return self.recorded_file_rewrites()[1]  # (per [#867.Q], is second)

    # -- used when preparing end states

    def build_common_components_for_failed_delete(self, id_s):
        coll = self.subject_collection()
        run = run_for(coll, 'delete', id_s)
        chan, payloader = _se_lib().one_and_none(self, run)
        return three_components_via_channel_and_payloader(
                self, chan, payloader)

    def flush_filesystem_recordings(self):
        coll = self.end_state()['collection']
        return coll._filesystem.FINISH_AS_HACKY_SPY()

    def listener(self):
        pass


# (Case4334) is a "collection not found" case


class Case4315_collection_can_be_built_with_noent_dir(_CommonCase):

    def test_100(self):
        self._canon_case.confirm_collection_is_not_none(self)

    def subject_collection(self):
        return _collection_with_noent_dir()

    @property
    def _canon_case(self):
        return canon.case_of_empty_collection_found


# Case4316 non-empty collection found


class Case4317_identifier_with_invalid_chars(_CommonCase):

    def test_100_channel(self):
        self.assertEqual(self.error_category, 'input_error')

    def test_200_reason(self):
        _actual = self.left_half
        self.assertEqual(_actual, "invalid character 'b' in identifier")

    def test_300_suggestion(self):
        _actual = self.right_half
        _expected = 'identifier digits must be [0-9A-Z] minus 0, 1, O and I.'
        self.assertEqual(_actual, _expected)

    @shared_subject
    def end_components(self):
        return self.build_common_components_for_failed_delete('AbC')

    def subject_collection(self):
        return _wrapped_collection_with_NO_filesystem()


class Case4318_identifier_too_short_or_long(_CommonCase):

    def test_100_result_is_none(self):
        self._canon_case.confirm_result_is_none(self)

    def test_200_emitted_accordingly(self):
        self._canon_case.confirm_emitted_accordingly(self)

    @shared_subject
    def end_state(self):
        return self._canon_case.build_end_state(self)

    def subject_collection(self):
        return _collection_with_NO_filesystem()

    @property
    def _canon_case(self):
        return canon.case_of_entity_not_found_because_identifier_too_deep


class Case4319_some_top_directory_not_found(_CommonCase):

    def test_100_channel(self):
        self.assertEqual(self.error_category, 'entity_not_found')

    def test_200_complaint(self):
        _actual = self.left_half
        _expect = "for 'entities/A/B.toml', no such directory"
        self.assertIn(_expect, _actual)

    def test_300_reason(self):
        actual = self.right_half
        _tail = actual[(actual.rindex('/') + 1):]
        self.assertEqual(_tail, '000-no-ent')

    @shared_subject
    def end_components(self):
        return self.build_common_components_for_failed_delete('ABC')

    def subject_collection(self):
        return wrap_collection(_collection_with_noent_dir())


class Case4320_delete_but_file_not_found(_CommonCase):

    def test_050_channel(self):
        self.assertEqual(self.error_category, 'entity_not_found')

    def test_100_result_is_none(self):
        self._canon_case.confirm_result_is_none(self)

    def test_200_emitted_accordingly(self):
        self._canon_case.confirm_emitted_accordingly(self)

    def test_600_complaint(self):
        _actual = self.left_half
        self.assertIn('no such file', _actual)

    def test_700_reason(self):
        _tail = _last_three_path_parts(self.right_half)
        self.assertEqual(_tail, 'entities/B/4.toml')

    @shared_subject
    def end_components(self):
        es = self.end_state()
        return three_components_via_channel_and_payloader(
                self, es['channel'], es['payloader_CAUTION_HOT'])

    @shared_subject
    def end_state(self):
        return self._canon_case.build_end_state(self)

    def IDENTIFIER_STRING(self):
        return 'B42'

    def subject_collection(self):
        return _build_collection(
                dir_path=_dir_path_most_common(),
                filesystem=None)

    @property
    def _canon_case(self):
        return canon.case_of_delete_but_entity_not_found


class Case4322_entity_not_found(_CommonCase):

    def test_100_result_is_none(self):
        self._canon_case.confirm_result_is_none(self)

    def test_200_emitted_accordingly(self):
        self._canon_case.confirm_emitted_accordingly(self)

    def test_600_message_sadly_has_no_context_yet(self):
        sct = self.end_state()['payloader_CAUTION_HOT']()
        self.assertEqual(sct['reason'], "'B7J' not in file")

    def test_700_no_files_rewritten(self):
        recs = self.flush_filesystem_recordings()  # NOTE
        self.assertEqual(recs, 'hi there were no file rewrites')

    @shared_subject
    def end_state(self):
        return self._canon_case.build_end_state(self)

    def IDENTIFIER_STRING(self):
        return 'B7J'

    def subject_collection(self):
        return _build_collection(
                dir_path=_dir_path_most_common(),
                filesystem=filesystem_expecting_no_rewrites())

    @property
    def _canon_case(self):
        return canon.case_of_entity_not_found


# Case4323 - not found because bad ID
# Case4324 - not found because no dir
# Case4325 - not found because no file


class Case4326_retrieve_no_ent_in_file(_CommonCase):  # #midpoint

    def test_100_emits_error_structure(self):
        coll = _wrapped_collection_with_NO_filesystem()
        run = run_for(coll, 'retrieve', 'B9F')
        _, payloader = _se_lib().one_and_none(self, run)
        sct = payloader()

        # ~(Case4116-Case4134) cover the detailed components from this.
        # this is just sort of a "curb-check" contact point integration check

        self.assertEqual(sct['input_error_type'], 'not_found')
        self.assertEqual(sct['identifier_string'], 'B9F')


class Case4327_retrieve_OK(_CommonCase):

    def test_100_entity_is_retrieved_and_looks_ok(self):
        self._canon_case.confirm_entity_is_retrieved_and_looks_ok(self)

    def end_state(self):  # NOTE  not memoized
        return self._canon_case.build_end_state(self)

    def subject_collection(self):
        return _collection_with_NO_filesystem()

    @property
    def _canon_case(self):
        return canon.case_of_retrieve_OK


# #hole


class Case4329_delete_OK(_CommonCase):

    def test_100_result_is_the_deleted_entity(self):
        self._canon_case.confirm_result_is_the_deleted_entity(self)

    def test_200_emitted_accordingly(self):
        self._canon_case.confirm_emitted_accordingly(self)

    def CONFIRM_THIS_LOOKS_LIKE_THE_DELETED_ENTITY(self, table_block):
        _expected = tuple(_unindent("""
        [item.B7F.attributes]
        thing-1 = "hi F"
        thing-2 = "hey F"

        """))
        _actual = tuple(table_block.to_line_stream())
        self.assertSequenceEqual(_actual, _expected)

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
        return self.flush_filesystem_recordings()

    @shared_subject
    def end_state(self):
        return self._canon_case.build_end_state_for_delete(self, 'B7F')

    def subject_collection(self):
        return _build_collection_expecting_common_number_of_rewrites()

    @property
    def _canon_case(self):
        return canon.case_of_delete_OK_resulting_in_non_empty_collection


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
        return filesystem_recordings_of(self, 'delete', 'B8H')

    def subject_collection(self):
        _ = _build_collection_expecting_common_number_of_rewrites()
        return wrap_collection(_)


# Case4331: delete when index file is left empty! (delete the last entity)


class Case4332_update_OK(_CommonCase):
    """
    at #history-A.1 we had to un-cover this issue, but re-cover it by creating
    "thing-C" instead of "thing-2" (numbers come before letters lexically)

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

        recs = self.flush_filesystem_recordings()
        rec, = recs  # only one file rewrite
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
        return 'B9H', (
            ('delete_attribute', 'thing-A'),
            ('update_attribute', 'thing-B', "I'm modified \"thing-B\""),
            ('create_attribute', 'thing-2', "I'm created \"thing-2\""))

    def subject_collection(self):
        return _build_collection(
                dir_path=_dir_path_most_common(),
                filesystem=build_filesystem_expecting_num_file_rewrites(1))

    @property
    def _canon_case(self):
        return canon.case_of_update_OK


class Case4334_simplified_typical_traversal_when_no_collection_dir(_CommonCase):  # noqa: E501

    def test_100_result_is_none(self):
        self._canon_case.confirm_result_is_none(self)

    def test_200_channel_looks_right(self):
        self._canon_case.confirm_channel_looks_right(self)

    def test_300_expression_looks_right(self):
        self._canon_case.confirm_expression_looks_right(self)

    def test_550_reason(self):
        self.assertEqual(
                self.left_half,
                'collection does not exist because no such directory')

    def test_575_detail(self):
        # regexp schmegex
        expect = '000-no-ent/entities'
        _actual = self.right_half[-len(expect):]
        self.assertEqual(_actual, expect)

    @shared_subject
    def end_components(self):
        # build the whole message again, meh
        _payloader = self.end_state()['payloader_CAUTION_HOT']
        message, = tuple(_payloader())  # assert only one line
        return _TwoComponents(* two_strings_via_message(message))

    @shared_subject
    def end_state(self):
        def run(listener):
            _itr = coll.to_identifier_stream_as_storage_adapter_collection(listener)  # noqa: E501
            for _ in _itr:
                self.fail()
        coll = self.subject_collection()
        return canon.end_state_via_run(self, run)

    def subject_collection(self):
        return _build_collection(
                dir_path=_dir_path_of_no_ent(),
                filesystem=None)

    @property
    def _canon_case(self):
        return canon.case_of_collection_not_found


class Case4335_traverse_IDs_ok(_CommonCase):
    # "simplified typical traversal"

    def test_100_everything(self):
        _ = canon.case_of_traverse_IDs_from_non_empty_collection
        _.confirm_all_IDs_in_any_order_no_repeats(self)

    def subject_collection(self):
        return _build_collection(
                dir_path=_dir_path_most_common(),
                filesystem=None)


class Case4336_create_into_existing_file(_CommonCase):

    def test_100_result_is_created_entity(self):
        self._canon_case.confirm_result_is_the_created_entity(self)

    def test_200_emitted_accordingly(self):
        self._canon_case.confirm_emitted_accordingly(self)

    # #pending-long-running #pending-mock-filesystem
    # self._canon_case.confirm_entity_now_in_collection(self)

    def test_250_entities_file_rewrite_OK(self):
        efr = self.entity_file_rewrite()
        self.assertEqual(_last_3_of_path(efr.path), 'entities/2/H.toml')

        expect = tuple(_unindent("""
        [item.2HG.attributes]
        thing-2 = -2.718
        thing-B = false
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
        return self.flush_filesystem_recordings()

    @shared_subject
    def end_state(self):
        return self._canon_case.build_end_state(self)

    def subject_collection(self):

        random_number_generator = _random_number_generator_for(494)
        # "2HG" as int per [#867.S] CLI

        return _build_collection(
                dir_path=_dir_path_most_common(),
                random_number_generator=random_number_generator,
                filesystem=build_filesystem_expecting_num_file_rewrites(2))

    @property
    def _canon_case(self):
        return canon.case_of_create_OK_into_non_empty_collection


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
        dct = {
                'abc': '456',
                'de-fg': 'false',
                }

        entities_path = _entities_file_path_for_2J()

        res = filesystem_recordings_of(self, 'create', dct)

        # == BEGIN NASTY - don't actually leave that new file in the fixture
        import os
        os.unlink(entities_path)  # results in none. raises on failure. NASTY
        # == END

        return res

    def subject_collection(self):
        random_number_generator = _random_number_generator_for(512)  # 2J2 but

        return wrap_collection(_build_collection(
                dir_path=_dir_path_most_common(),
                random_number_generator=random_number_generator,
                filesystem=build_filesystem_expecting_num_file_rewrites(2)))


def _last_3_of_path(path):
    import re
    return re.search(r'/([^/]+/[^/]+/[^/]+)$', path)[1]


@lazy
def _collection_with_expecting_no_rewrites():
    return _build_collection(
            dir_path=_dir_path_most_common(),
            filesystem=filesystem_expecting_no_rewrites())


@lazy
def _collection_with_noent_dir():
    return _build_collection(
            dir_path=_dir_path_of_no_ent(),
            filesystem='no filesystem xyz121')


@lazy
def _wrapped_collection_with_NO_filesystem():
    return wrap_collection(_collection_with_NO_filesystem())


@lazy
def _collection_with_NO_filesystem():
    return _build_collection(
            dir_path=_dir_path_most_common(),
            filesystem='no filesystem xyz122')


@lazy
def _entities_file_path_for_2J():
    import os.path as os_path
    return os_path.join(_dir_path_most_common(), 'entities', '2', 'J.toml')


@lazy
def _dir_path_most_common():
    return fixture_directory_for('050-rumspringa')


@lazy
def _dir_path_of_no_ent():
    return fixture_directory_for('000-no-ent')


fixture_directory_for = functions_for('toml').fixture_directory_for


def _last_three_path_parts(path):
    import re
    return re.search(r'[^/]+(?:/[^/]+){2}$', path)[0]


def _random_number_generator_for(random_number):
    def random_number_generator(pool_size):
        assert(32760 == pool_size)
        counter.increment()
        assert(1 == counter.value)
        return random_number
    counter = Counter()
    return random_number_generator


def _build_collection_expecting_common_number_of_rewrites():
    return _build_collection(
            dir_path=_dir_path_most_common(),
            filesystem=build_filesystem_expecting_num_file_rewrites(2))


def _build_collection(dir_path, **injections):
    collection_identity = StubCollectionIdentity(dir_path)
    return _subject_module().collection_via_directory_and_schema(
            collection_identity=collection_identity,
            collection_schema=_always_same_schema(),
            **injections)


@lazy
def _always_same_schema():
    from kiss_rdb.storage_adapters_.toml.schema_via_file_lines import Schema_
    return Schema_(storage_schema='32x32x32')


def three_components_via_channel_and_payloader(tc, chan, payloader):
    sev, shape, ec = chan  # ..
    tc.assertEqual((sev, shape), ('error', 'structure'))
    left, right = two_strings_via_message(payloader()['reason'])
    return _ThreeComponents(left, right, ec)


def two_strings_via_message(message):
    left, right = message.split(' - ')  # assert exactly 2
    return left, right


class _TwoComponents:
    def __init__(self, aa, bb):
        self.left_half = aa
        self.right_half = bb


class _ThreeComponents(_TwoComponents):
    def __init__(self, aa, bb, cc):
        super().__init__(aa, bb)
        self.error_category = cc


def _subject_module():
    from kiss_rdb.storage_adapters_.toml import collection_via_directory as _
    return _


# ==

def _throwing_listener():
    from modality_agnostic import listening
    return listening.throwing_listener


def _no_listener(*chan, payloader):
    assert(False)  # when this trips, use _debugging_listener()


# ==

def _se_lib():
    from modality_agnostic.test_support import structured_emission as se_lib
    return se_lib


# ==

if __name__ == '__main__':
    unittest.main()

# #history-A.1
# #born.
