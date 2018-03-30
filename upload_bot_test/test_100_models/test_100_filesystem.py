"""this test file corresponds to an isomporphically named model file..

..that explains its own objective & scope.
"""

from _init import (
        writable_tmpdir,
        )

from upload_bot._models import (
        filesystem,
        )

from game_server import (
        dangerous_memoize as shared_subject,
        memoize,
        )

import unittest
import os

path = os.path


_TestCase = unittest.TestCase


def same_test_for_mock(x=None):
    return _same_test_for('_mock_subject', x)


def same_test_for_real(x=None):
    return _same_test_for('_real_subject', x)


def _same_test_for(which, m):
    if m is None:
        def g(f):
            def use_f(self):
                f()  # in case user sets breakpoint in there
                _which_fs = getattr(self, which)()
                self.same_test(_which_fs)
            return use_f
    else:
        def g(f):
            def use_f(self):
                f()  # in case user sets breakpoint in there
                _which_details = getattr(self, which)()
                _which_test = getattr(self, m)
                _which_test(_which_details)

            return use_f
    return g


class Case100_not_exists_not_exists(_TestCase):

    def test_010_magentic_loads(self):
        self.assertIsNotNone(_subject_model())

    @same_test_for_mock()
    def test_020_mock():
        pass

    @same_test_for_real()
    def test_030_real():
        pass

    def same_test(self, fs):
        _yes = fs.file_exists('/foo/some_file')
        self.assertFalse(_yes)

    def _mock_subject(self):
        return filesystem.FakeFilesystem.the_empty_filesystem()

    def _real_subject(self):
        return _real_filesystem()


class Case200_yes_exists_yes_exists(_TestCase):

    def test_010_mock(self):
        _fs = filesystem.FakeFilesystem('/aa/bb')
        _path = '/aa/bb'
        self._same_test(_path, _fs)

    def test_020_real(self):
        _fs = _real_filesystem()
        _path = __file__  # YIKES
        self._same_test(_path, _fs)

    def _same_test(self, path, fs):
        _yes = fs.file_exists(path)
        self.assertTrue(_yes)


class Case300_write_file(_TestCase):

    @same_test_for_mock('_not_exists_before')
    def test_010_not_exists_before_for_mock():
        pass

    @same_test_for_real('_not_exists_before')
    def test_020_not_exists_before_for_real():
        pass

    @same_test_for_mock('_yes_exists_after')
    def test_030_yes_exists_after_for_mock():
        pass

    @same_test_for_real('_yes_exists_after')
    def test_040_yes_exists_after_for_real():
        pass

    @same_test_for_mock('_talkin_bout_bytes_wrote')
    def test_050_talkin_bout_bytes_wrote_for_mock():
        pass

    @same_test_for_real('_talkin_bout_bytes_wrote')
    def test_050_talkin_bout_bytes_wrote_for_real():
        pass

    def _not_exists_before(self, details):
        self.assertFalse(details.did_exist_before)

    def _yes_exists_after(self, details):
        self.assertTrue(details.did_exist_after)

    def _talkin_bout_bytes_wrote(self, details):
        self.assertEqual(6, details.number_of_bytes_wrote)

    @shared_subject
    def _mock_subject(self):
        _fs = filesystem.FakeFilesystem('/aa/xx', '/bb/qq')
        return _this_same_story('/zz/mm', _fs)

    @shared_subject
    def _real_subject(self):
        _fs = _real_filesystem()
        path = os.path.join(writable_tmpdir, 'some.file')
        x = _this_same_story(path, _fs)

        # ==
        # (do our own cleanup of the file "manually", after the story)
        if os.path.exists(path):
            os.remove(path)
        # ==

        return x


def _this_same_story(path, fs):

    did_exist_before = fs.file_exists(path)

    with fs.open(path, 'w') as fh:
        byte_count = fh.write('xx\nyy\n')

    did_exist_after = fs.file_exists(path)

    return _Details(did_exist_before, byte_count, did_exist_after)


class _Details:

    def __init__(self, did_exist_before, byte_count, did_exist_after):
        self.did_exist_before = did_exist_before
        self.number_of_bytes_wrote = byte_count
        self.did_exist_after = did_exist_after


def _real_filesystem():
    return filesystem.real_filesystem()


@memoize
def _subject_model():
    import upload_bot._models.filesystem as mod
    return mod


if __name__ == '__main__':
    unittest.main()

# #born.
