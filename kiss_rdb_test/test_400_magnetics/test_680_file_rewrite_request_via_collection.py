from _common_state import fixture_directory_path
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        memoize,
        )
import unittest


class _CommonCase(unittest.TestCase):

    # -- CUD expecting succeess

    def update_expecting_success(self, id_s, cuds):
        def f(col, listener):
            return col.update_entity(id_s, cuds, listener)

        x, rec = self.CUD_expecting_success(f)
        self.assertEqual(x, True)
        return rec

    def delete_expecting_success(self, id_s):

        def f(col, listener):
            return col.delete_entity(id_s, listener)

        x, rec = self.CUD_expecting_success(f)
        self.assertEqual(x, True)
        return rec

    # -- CUD expecting failure and recording

    def delete_expecting_failure_and_recordings(self, id_s):

        col = self.subject_collection()
        fs = col._filesystem

        def f(listener):
            return col.delete_entity(id_s, listener)

        sct = self.run_this_expecting_failure(f)

        rec = fs.finish_vis_a_vis_script()

        return (sct, rec)

    # -- CUD expecting failure

    def delete_expecting_failure(self, id_s):
        def f(listener):
            return self.subject_collection().delete_entity(id_s, listener)

        return self.run_this_expecting_failure(f)

    # == general

    @property
    def left_half(self):
        return self.two_halves()[0]

    @property
    def right_half(self):
        return self.two_halves()[1]

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

        x = f(listener)
        self.assertIsNone(x)
        self.assertEqual(count, 1)

        *chan, payloader = only_emission
        chan = tuple(chan)
        # ..

        self.assertEqual(chan, ('error', 'structure', 'input_error'))
        return payloader()

    def CUD_expecting_success(self, f):

        col = self.subject_collection()
        fs = col._filesystem

        x = f(col, self.listener())

        recs = fs.finish_vis_a_vis_script()
        rec, = recs
        return x, rec

    def subject_collection(self):
        return _default_subject()

    def listener(self):
        if False:
            return _selib().debugging_listener()


class Case700_collection_can_be_built_with_noent_dir(_CommonCase):

    def test_100(self):
        self.assertIsNotNone(_subject_from_noent_dir())


class Case703_identifier_with_invalid_chars(_CommonCase):

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


class Case704_identifier_too_short_or_long(_CommonCase):

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


class Case705_some_top_directory_not_found(_CommonCase):

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


class Case706_file_not_found(_CommonCase):

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
        return _build_collection_via_directory_and_filesystem(
                _this_one_collection_path(), None)


class Case707_entity_not_found(_CommonCase):

    def test_100_failed_to_rewrite(self):
        rec = self._structure_and_recordings()[1]
        self.assertEqual(rec[0][0], False)  # ick

    def test_200_message_sadly_has_no_context_yet(self):
        sct = self._structure_and_recordings()[0]
        self.assertEqual(sct['reason'], "entity 'B7D' is not in file")

    @shared_subject
    def _structure_and_recordings(self):
        sct, recs = self.delete_expecting_failure_and_recordings('B7D')
        return sct, recs

    def subject_collection(self):
        _filesystem = _FilesystemSpy(_one_call_to_rewrite, self)
        return _build_collection_via_directory_and_filesystem(
                _this_one_collection_path(), _filesystem)


class Case708_delete_simplified_typical(_CommonCase):

    def test_100_would_have_succeeded(self):  # we didn't really write a file
        self.assertTrue(self.record_of_call.did_succeed)

    def test_200_path_is_path(self):
        path = self.record_of_call.path
        import re
        tail = re.search(r'/([^/]+/[^/]+/[^/]+)$', path)[1]
        self.assertEqual(tail, 'entities/B/7.toml')

    def test_300_LINES(self):
        from kiss_rdb_test.structured_emission import unindent
        expect = tuple(unindent("""
        [item.B7E.attributes]
        thing-1 = "hi E"
        thing-2 = "hey E"

        [item.B7G.attributes]
        thing-1 = "hi G"
        thing-2 = "hey G"
        """))

        self.assertSequenceEqual(self.record_of_call.lines, expect)

    @property
    @shared_subject
    def record_of_call(self):
        _ = self.delete_expecting_success('B7F')
        return _RecordOfCall(*_)

    def subject_collection(self):
        _filesystem = _FilesystemSpy(_one_call_to_rewrite, self)
        return _build_collection_via_directory_and_filesystem(
                _this_one_collection_path(), _filesystem)


class Case709_delete_that_leaves_file_empty(_CommonCase):

    def test_100_would_have_succeeded(self):
        self.assertTrue(self.record_of_call.did_succeed)

    def test_200_path_is_path(self):
        path = self.record_of_call.path
        import re
        tail = re.search(r'/([^/]+/[^/]+/[^/]+)$', path)[1]
        self.assertEqual(tail, 'entities/B/8.toml')

    def test_300_LINES(self):
        self.assertSequenceEqual(self.record_of_call.lines, ())

    @property
    @shared_subject
    def record_of_call(self):
        _ = self.delete_expecting_success('B8H')
        return _RecordOfCall(*_)

    def subject_collection(self):
        _filesystem = _FilesystemSpy(_one_call_to_rewrite, self)
        return _build_collection_via_directory_and_filesystem(
                _this_one_collection_path(), _filesystem)


class Case715_update_CAPTURE_FORMATTING_ISSUE(_CommonCase):
    """
    .#open [#867.H] it "thinks of" {whitespace|comments} as being

    associated with the attribute not the entity block so the behavior
    here in terms of where blank lines end up is not what would probably
    be expected..

    wait till after multilines maybe, because this is ugly but only cosmetic
    """

    def test_100_everything(self):
        ok, path, lines = self.update_expecting_success('B9H', (
            ('delete', 'thing-A'),
            ('update', 'thing-B', 'modified hey'),
            ('create', 'thing-C', 'woot'),
            ))

        self.assertTrue(ok)
        self.assertEqual(_last_three_path_parts(path), 'entities/B/9.toml')
        _expected = tuple(_selib().unindent(self._expecting_these()))
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
        _filesystem = _FilesystemSpy(_one_call_to_rewrite, self)
        return _build_collection_via_directory_and_filesystem(
                _this_one_collection_path(), _filesystem)


@memoize
def _this_one_collection_path():
    return fixture_directory_path('050-rumspringa')


@memoize
def _subject_from_noent_dir():
    _ = fixture_directory_path('000-no-ent')
    return _build_collection_via_directory_and_filesystem(_, None)


_default_subject = _subject_from_noent_dir


class _FilesystemSpy:
    """NOTE

    our objective here is to be light & easy & to the point. however we
    duplicate the very thinnest of responsibility from a real filesystem
    façade..
    """

    def __init__(self, expected_calls, test_context):
        self._expected_calls_stack = list(reversed(expected_calls))
        self._test_context = test_context
        self.recordings = []

    def rewrite_file(self, f, file_path, listener):

        fname, = self._expected_calls_stack.pop()
        self._test_context.assertEqual(fname, 'rewrite')

        from kiss_rdb.magnetics_.identifiers_via_file_lines import (
                ErrorMonitor_,
                )

        monitor = ErrorMonitor_(listener)

        with open(file_path) as fh:
            new_lines = tuple(f(fh, monitor.listener))

        self.recordings.append((monitor.ok, file_path, new_lines))

        if monitor.ok:
            return True
        else:
            return None  # (Case707) - not False for now..

    def finish_vis_a_vis_script(self):
        if len(self._expected_calls_stack):
            self._test_context.fail("still had unexpected yadda")

        x = tuple(self.recordings)
        del(self.recordings)
        return x


def _last_three_path_parts(path):
    import re
    return re.search(r'[^/]+(?:/[^/]+){2}$', path)[0]


class _RecordOfCall:

    def __init__(self, did_succeed, path, lines):
        self.did_succeed = did_succeed
        self.path = path
        self.lines = lines


def _build_collection_via_directory_and_filesystem(dir_path, fs):
    return _subject_module().collection_via_directory_and_filesystem(
            dir_path, fs)


def _subject_module():
    from kiss_rdb.magnetics_ import collection_via_directory as _
    return _


def _selib():
    from kiss_rdb_test import structured_emission as _
    return _


_one_call_to_rewrite = (('rewrite',),)

if __name__ == '__main__':
    unittest.main()

# #born.
