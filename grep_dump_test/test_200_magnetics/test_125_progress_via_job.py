from contextlib import contextmanager
from modality_agnostic.test_support.common import \
        dangerous_memoize as shared_subject, lazy
import unittest


class _TestCase(unittest.TestCase):

    # -- assertions

    def expect_error_message(self, msg):

        _lines = self.line_string_array
        del self.line_string_array

        with self.assert_raises_common() as cm:
            _call_subject_commonly(0, _lines)

        self.assertEqual(msg, str(cm.exception))

    def assert_raises_common(self):
        return self.assertRaises(_subject_module().Exception)

    def response_says_not_complete(self):
        self.assertFalse(self._response_is_complete())

    def response_says_complete(self):
        self.assertTrue(self._response_is_complete())

    def response_has_items_one_two_and_three(self):
        _s_a = self.response_line_items()
        _exp = ['item 1', 'item 2', 'item 3']
        self.assertEqual(_exp, _s_a)

    def response_has_empty_array_of_line_items(self):
        _a = self.response_line_items()
        self.assertEqual(0, len(_a))

    # -- assertion support

    def _response_is_complete(self):
        return self._response_component('job_is_complete')

    def _response_share_complete(self):
        return self._response_component('share_complete')

    def response_line_items(self):
        return self._response_component(
                'zero_or_more_new_line_item_descriptions')

    def _response_component(self, key_s):
        _x = self.response
        return _x[key_s]

    # -- set up

    @contextmanager
    def given_lines(self):
        line_s_a = []
        yield _Lines(line_s_a)
        self.line_string_array = line_s_a


class Case496_Malformations(_TestCase):

    def test_010_magnet_loads(self):
        self.assertIsNotNone(_subject_module())

    def test_020_malformed_first_line(self):
        with self.given_lines() as lines:
            lines.append('rando first line')
        self.expect_error_message(
                'malformed logfile (first line): '
                "'rando first line'")

    def test_030_fail_to_parse_item_line(self):
        with self.given_lines() as lines:
            lines.begun()
            lines.append('cannot parse me')
        self.expect_error_message(
                'malformed item line: '
                r"'cannot parse me\n'")

    def test_040_unexpected_extra_line(self):
        with self.given_lines() as lines:
            lines.begun()
            lines.finished()
            lines.append('extra linezorzz')
        self.expect_error_message(
                'unexpected extra line in file: '
                r"'extra linezorzz\n'")


class Case497_AgainstJustBegunFile_AfterNoItems(_TestCase):  # :[#510.7.2]

    def test_010_response_says_not_complete(self):
        self.response_says_not_complete()

    def test_020_response_says_zero_percent_complete(self):
        self.assertEqual(0.0, self._response_share_complete())

    def test_030_response_has_empty_array_of_line_items(self):
        self.response_has_empty_array_of_line_items()

    @shared_subject
    def response(_):
        return _call_subject_commonly(0, _file_just_begun())


class Case499_AgainstFileBegunAndFinishedWithNoItems_AfterNoItems(_TestCase):

    def test_010_response_says_complete(self):
        self.response_says_complete()

    def test_020_response_says_one_hundred_percent_complete(self):
        self.assertEqual(1.0, self._response_share_complete())

    def test_030_response_has_empty_array_of_line_items(self):
        self.response_has_empty_array_of_line_items()

    @shared_subject
    def response(_):
        return _call_subject_commonly(
                0,
                _file_begun_and_finished_with_no_items())


class Case500_AgainstUnfinishedFileWithThreeItems_AfterNoItems(_TestCase):

    def test_010_response_says_not_complete(self):
        self.response_says_not_complete()

    def test_020_response_says_some_X_percent_complete(self):
        self.assertEqual(0.75, self._response_share_complete())

    def test_030_response_has_this_array_of_line_item_descriptions(self):
        self.response_has_items_one_two_and_three()

    @shared_subject
    def response(_):
        return _call_subject_commonly(0, _file_unfinished_with_three_items())


class Case502_AgainstFinishedFileWithThreeItems_AfterNoItems(_TestCase):

    def test_010_response_says_complete(self):
        self.response_says_complete()

    def test_020_response_says_one_hundred_percent_complete(self):
        self.assertEqual(1.0, self._response_share_complete())

    def test_030_response_has_this_array_of_line_item_descriptions(self):
        self.response_has_items_one_two_and_three()

    @shared_subject
    def response(_):
        return _call_subject_commonly(0, _file_finished_with_three_items())


class Case503_AgainstUnfinishedFileWithThreeItems_AfterThreeItems(_TestCase):

    def test_010_response_says_not_complete(self):
        self.response_says_not_complete()

    def test_020_response_says_some_X_percent_complete(self):
        self.assertEqual(0.75, self._response_share_complete())

    def test_030_response_has_empty_array_of_line_items__and_detail(self):
        self.response_has_empty_array_of_line_items()
        x = self.response
        self.assertEqual(3, x['last_known_number_of_line_items'])
        self.assertEqual(3, x['your_last_known_number_of_line_items'])

    @shared_subject
    def response(_):
        return _call_subject_commonly(3, _file_unfinished_with_three_items())


class Case505_Overreach(_TestCase):

    # (a long comment in the source explains this)

    def test_010_OHAI(self):

        with self.assert_raises_common() as cm:
            _call_subject_commonly(4, _file_unfinished_with_three_items())

        self.assertEqual(
                str(cm.exception),
                'expected 4 existing line items in logfile, had 3')


def file_lines(f):  # #decorator
    def first_time():
        mutable_lines = []
        f(_Lines(mutable_lines))
        return tuple(mutable_lines)
    return lazy(first_time)


@file_lines
def _file_finished_with_three_items(lines):
    lines.begun()
    lines.append('0.25 item 1')
    lines.append('0.50 item 2')
    lines.append('0.75 item 3')
    lines.finished()


@file_lines
def _file_unfinished_with_three_items(lines):
    lines.begun()
    lines.append('0.25 item 1')
    lines.append('0.50 item 2')
    lines.append('0.75 item 3')


@file_lines
def _file_begun_and_finished_with_no_items(lines):
    lines.begun()
    lines.finished()


@file_lines
def _file_just_begun(lines):
    lines.begun()


class _Lines:
    """(writes a pretend logfile. internal DSL-ish to DRY setup code)"""

    def __init__(self, line_s_a):
        self._line_string_array = line_s_a

    def begun(self):
        self._append('begun.\n')

    def finished(self):
        self._append('finished.\n')

    def append(self, line):
        self._append(line + '\n')

    def _append(self, line):
        self._line_string_array.append(line)


def okay(_=None):
    raise Exception('hello')


def _call_subject_commonly(num, lines):
    return _subject_module().SELF(
        last_known_number_of_line_items=num,
        logfile_line_upstream=iter(lines))


def _subject_module():
    import grep_dump._magnetics.progress_via_job as x  # #[#204]
    return x


if __name__ == '__main__':
    unittest.main()

# #born.
