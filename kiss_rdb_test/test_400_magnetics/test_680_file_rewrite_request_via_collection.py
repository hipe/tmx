from _common_state import fixture_directory_path
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        memoize,
        )
import unittest


class _CommonCase(unittest.TestCase):

    # == DSL-ish for test assertions

    def entity_file_rewrite(self):
        return self.recorded_file_rewrites()[0]  # (per [#867.Q], is first)

    def index_file_rewrite(self):
        return self.recorded_file_rewrites()[1]  # (per [#867.Q], is second)

    @property
    def left_half(self):
        return self.two_halves()[0]

    @property
    def right_half(self):
        return self.two_halves()[1]

    # == for creating result state under test

    # -- CUD expecting success

    def update_expecting_success(self, id_s, cuds):
        return self._recording_of_success(_function_for_update(id_s, cuds))

    def create_expecting_success(self, id_s, wats):
        raise Exception('cover me')  # #todo
        return self._recording_of_success(_function_for_create(id_s, wats))

    def delete_expecting_success(self, id_s):
        return self._recording_of_success(_function_for_delete(id_s))

    # -- CUD expecting failure and recording

    def delete_expecting_failure_and_recordings(self, id_s):
        return self._struct_and_recording_of_fail(_function_for_delete(id_s))

    # -- CUD expecting failure

    def create_expecting_failure(self, wats):
        return self._payload_of_failure(_function_for_create(wats))

    def delete_expecting_failure(self, id_s):
        return self._payload_of_failure(_function_for_delete(id_s))

    # == THESE

    def _payload_of_failure(self, f):
        col = self.subject_collection()

        def use_f(listener):
            return f(col, listener)
        return self.run_this_expecting_failure(use_f)

    def _struct_and_recording_of_fail(self, f):

        col = self.subject_collection()
        fs = col._filesystem

        def use_f(listener):
            return f(col, listener)

        sct = self.run_this_expecting_failure(use_f)
        recs = fs._recorded_file_rewrites_from_finish()
        return (sct, recs)

    def run_this_expecting_failure(self, f):  # #open #[867.H] DRY these
        count = 0
        only_emission = None

        def listener(*a):
            nonlocal count
            nonlocal only_emission
            count += 1
            if 1 < count:
                self.fail('too many emissions')
            only_emission = a

        res = f(listener)
        self.assertIsNone(res)  # [#867.R] provision: None not False :#here2
        self.assertEqual(count, 1)

        *chan, payloader = only_emission
        chan = tuple(chan)
        # ..

        self.assertEqual(chan, ('error', 'structure', 'input_error'))
        return payloader()

    def _recording_of_success(self, f):

        col = self.subject_collection()
        fs = col._filesystem
        listener = self.listener

        # --

        res = f(col, listener)
        self.assertTrue(res)  # :#here1

        return fs._recorded_file_rewrites_from_finish()

    def listener(self):
        if False:
            return _selib().debugging_listener()


def _function_for_update(id_s, cuds):
    def f(col, listener):
        return col.update_entity(id_s, cuds, listener)
    return f


def _function_for_create(wats):
    def f(col, listener):
        return col.create_entity(wats, listener)
    return f


def _function_for_delete(id_s):
    def f(col, listener):
        return col.delete_entity(id_s, listener)
    return f


class Case701_collection_can_be_built_with_noent_dir(_CommonCase):

    def test_100(self):
        self.assertIsNotNone(_collection_with_noent_dir())


class Case702_identifier_with_invalid_chars(_CommonCase):

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


class Case703_identifier_too_short_or_long(_CommonCase):

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


class Case704_some_top_directory_not_found(_CommonCase):

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


class Case705_file_not_found(_CommonCase):

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


class Case706_entity_not_found(_CommonCase):

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
                filesystem=_filesystem_expecting_no_rewrites())


# Case707 - not found because bad ID
# Case708 - not found because no dir
# Case709 - not found because no file
# Case710 - not found because no ent in file
# Case711 - win


class Case710_retrieve_no_ent_in_file(_CommonCase):

    def test_100_emits_error_structure(self):
        col = _collection_with_NO_filesystem()

        def f(listener):
            return col.retrieve_entity('B9F', listener)
        sct = self.run_this_expecting_failure(f)

        # ~(Case253-Case384) cover the detailed components from this.
        # this is just sort of a "curb-check" contact point integration check

        self.assertEqual(sct['input_error_type'], 'not_found')
        self.assertEqual(sct['identifier_string'], 'B9F')


class Case711_retrieve(_CommonCase):

    def test_100_identifier_is_in_result_dictionary(self):
        _actual = self._this_dict()['identifier_string']
        self.assertEqual(_actual, 'B9H')

    def test_200_simple_immediate_values_are_there(self):
        dct = self._this_dict()['SIMPLE_AND_IMMEDIATE_ATTRIBUTES']
        self.assertEqual(dct['thing-A'], 'hi H')
        self.assertEqual(dct['thing-B'], 'hey H')

    @shared_subject
    def _this_dict(self):
        _col = _collection_with_NO_filesystem()
        return _col.retrieve_entity('B9H', _no_listener)


class Case712_delete_simplified_typical(_CommonCase):

    def test_100_would_have_succeeded(self):  # we didn't really write a file
        self.recorded_file_rewrites()  # because #here1

    def test_200_path_is_path(self):
        path = self.entity_file_rewrite().path
        import re
        tail = re.search(r'/([^/]+/[^/]+/[^/]+)$', path)[1]
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
        return _build_collection(
                dir_path=_dir_path_most_common(),
                filesystem=_build_filesystem_expecting_num_file_rewrites(2))


class Case713_delete_that_leaves_file_empty(_CommonCase):

    def test_100_would_have_succeeded(self):
        self.recorded_file_rewrites()  # because #here1

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
        return _build_collection(
                dir_path=_dir_path_most_common(),
                filesystem=_build_filesystem_expecting_num_file_rewrites(2))


# Case714: delete when index file is left empty! (delete the last entity)


class Case715_update_CAPTURE_FORMATTING_ISSUE(_CommonCase):
    """
    .#open [#867.H] it "thinks of" {whitespace|comments} as being

    associated with the attribute not the entity block so the behavior
    here in terms of where blank lines end up is not what would probably
    be expected..

    wait till after multilines maybe, because this is ugly but only cosmetic
    """

    def test_100_everything(self):

        recs = self.update_expecting_success('B9H', (
            ('delete', 'thing-A'),
            ('update', 'thing-B', 'modified hey'),
            ('create', 'thing-C', 'woot'),
            ))

        rec, = recs  # onyl one file rewrite
        path = rec.path
        lines = rec.lines

        # --

        self.assertEqual(_last_three_path_parts(path), 'entities/B/9.toml')
        _expected = tuple(_unindent(self._expecting_these()))
        self.assertSequenceEqual(lines, _expected)

    def _expecting_these(self):
        return """
        [item.B9G.attributes]
        hi-G = "hey G"

        [item.B9H.attributes]
        thing-B = "modified hey"

        thing-C = "woot"
        [item.B9J.attributes]
        hi-J = "hey J"
        """

    def subject_collection(self):
        return _build_collection(
                dir_path=_dir_path_most_common(),
                filesystem=_build_filesystem_expecting_num_file_rewrites(1))


class Case720_simplified_typical_traversal_when_no_collection_dir(_CommonCase):

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
        count = 0
        channel = None
        payloader = None

        def listener(*args):
            nonlocal count, channel, payloader
            count += 1
            assert(count < 2)
            *channel, payloader = args
            channel = tuple(channel)

        _itr = self.subject_collection().to_identifier_stream(listener)
        for x in _itr:
            self.fail()

        assert(1 == count)
        return channel, payloader

    def subject_collection(self):
        return _build_collection(
                dir_path=_dir_path_of_no_ent(),
                filesystem=None)


class Case725_simplified_typical_traversal(_CommonCase):

    def test_100_everything(self):

        def f(id_obj):
            return id_obj.to_string()  # ..

        _these = self.subject_collection().to_identifier_stream(None)
        _actual = (f(o) for o in _these)

        _these = [
                '2HJ',
                'B7E',
                'B7F',
                'B7G',
                'B8H',
                'B9G',
                'B9H',
                'B9J',
                ]

        _expected = (x for x in _these)

        _actual = tuple(_actual)
        _expected = tuple(_expected)

        self.assertSequenceEqual(_actual, _expected)

    def subject_collection(self):
        return _build_collection(
                dir_path=_dir_path_most_common(),
                filesystem=None)


@memoize
def _collection_with_expecting_no_rewrites():
    return _build_collection(
            dir_path=_dir_path_most_common(),
            filesystem=_filesystem_expecting_no_rewrites())


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
def _dir_path_most_common():
    return fixture_directory_path('050-rumspringa')


@memoize
def _dir_path_of_no_ent():
    return fixture_directory_path('000-no-ent')


@memoize
def _filesystem_expecting_no_rewrites():

    def inj(*_):
        assert(False)

    def finish():
        return 'hi there were no file rewrites'

    return _build_filesystem_via_two_funcs(inj, finish)


def _build_filesystem_expecting_num_file_rewrites(expected_num):

    recs = []

    def INJECTED_FELLOW(from_fh, to_fh):

        if len(recs) == expected_num:
            raise Exception('too many doo-hahs')

        from_fh.seek(0)  # necessary
        _new_lines = tuple(iter(from_fh))

        recs.append(_RecordOfFileRewrite(
            path=to_fh.name,
            lines=_new_lines,))

    def finish():

        nonlocal recs
        if len(recs) != expected_num:
            raise Exception('still had unexpected yadda')

        res = tuple(recs)
        del(recs)  # works! (as a safety measure)
        return res

    return _build_filesystem_via_two_funcs(INJECTED_FELLOW, finish)


def _build_filesystem_via_two_funcs(INJECTED_FELLOW, finish):
    from kiss_rdb.magnetics_ import filesystem as _

    fs = _._Filesystem(INJECTED_FELLOW)

    fs._recorded_file_rewrites_from_finish = finish

    return fs


def _last_three_path_parts(path):
    import re
    return re.search(r'[^/]+(?:/[^/]+){2}$', path)[0]


class _RecordOfFileRewrite:

    def __init__(self, path, lines):
        self.path = path
        self.lines = lines


def _build_collection(dir_path, filesystem):
    return _subject_module().collection_via_directory_and_filesystem(
            dir_path, filesystem)


def _unindent(big_string):
    return _selib().unindent(big_string)


def _subject_module():
    from kiss_rdb.magnetics_ import collection_via_directory as _
    return _


def _no_listener(*chan, payloader):
    assert(False)  # when this trips, use _selib().debugging_listener()


def _selib():
    from kiss_rdb_test import structured_emission as _
    return _


if __name__ == '__main__':
    unittest.main()

# #born.
