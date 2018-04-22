"""this test file corresponds to an isomporphically named model file..

..that explains its own objective & scope.
"""

from _init import (
        file_with_content_path,
        no_ent_path,
        writable_tmpdir,
        )

from upload_bot._models import (
        filesystem,
        )

from modality_agnostic.memoization import (
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
        fs = filesystem.FakeFilesystem()
        path = '/aa/bb'
        with fs.open(path, 'x') as fh:
            fh.write("content\n")
        self._same_test(path, fs)

    def test_020_real(self):
        _fs = _real_filesystem()
        _path = __file__  # YIKES
        self._same_test(_path, _fs)

    def _same_test(self, path, fs):
        _yes = fs.file_exists(path)
        self.assertTrue(_yes)


class Case350_new_way_not_exists_not_exist(_TestCase):

    @same_test_for_mock('_not_exists')
    def test_010_not_exists_mock():
        pass

    @same_test_for_real('_not_exists')
    def test_020_not_exists_real():
        pass

    def _not_exists(self, details):
        self.assertFalse(details.did_exist)

    @shared_subject
    def _mock_subject(self):
        _fs = _this_same_fake_filesystem()
        return _same_details('/cc/dd', _fs)

    @shared_subject
    def _real_subject(self):
        _fs = _real_filesystem()
        _path = no_ent_path()
        return _same_details(_path, _fs)


class Case375_new_way_yes_exist_yes_exists(_TestCase):

    @same_test_for_mock('_yes_exists')
    def test_010_yes_exists_mock():
        pass

    @same_test_for_real('_yes_exists')
    def test_020_yes_exists_real():
        pass

    @same_test_for_mock('_read_that_content')
    def test_030_yes_exists_mock():
        pass

    @same_test_for_real('_read_that_content')
    def test_040_yes_exists_real():
        pass

    def _yes_exists(self, details):
        self.assertTrue(details.did_exist)

    def _read_that_content(self, details):
        self.assertEqual(details.content, 'ohai i am content\n')

    @shared_subject
    def _mock_subject(self):
        _fs = _this_same_fake_filesystem()
        return _same_details('/aa/bb', _fs)

    @shared_subject
    def _real_subject(self):
        _fs = _real_filesystem()
        _path = file_with_content_path()
        return _same_details(_path, _fs)


def _same_details(path, fs):
    def recv(fh):
        return fh.read()
    content = fs.open_if_exists(path, recv)
    if content is None:
        did_exist = False
    else:
        did_exist = True

    return _DetailsTwo(did_exist, content)


@memoize
def _this_same_fake_filesystem():
    fs = filesystem.FakeFilesystem()
    with fs.open('/aa/bb', 'x') as fh:
        fh.write("ohai i am content\n")
    return fs


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
        fs = filesystem.FakeFilesystem()
        _touch('/aa/xx', fs)
        _touch('/bb/qq', fs)
        return _this_same_story('/zz/mm', fs)

    @shared_subject
    def _real_subject(self):
        _fs = _real_filesystem()
        path = os.path.join(writable_tmpdir(), 'some.file')
        x = _this_same_story(path, _fs)

        # ==
        # (do our own cleanup of the file "manually", after the story)
        if os.path.exists(path):
            os.remove(path)
        # ==

        return x


def _this_same_story(path, fs):

    did_exist_before = fs.file_exists(path)

    with fs.open(path, 'x') as fh:
        byte_count = fh.write('xx\nyy\n')

    did_exist_after = fs.file_exists(path)

    return _DetailsOne(did_exist_before, byte_count, did_exist_after)


class _DetailsOne:

    def __init__(self, did_exist_before, byte_count, did_exist_after):
        self.did_exist_before = did_exist_before
        self.number_of_bytes_wrote = byte_count
        self.did_exist_after = did_exist_after


class _DetailsTwo:

    def __init__(self, did_exist, content):
        self.did_exist = did_exist
        self.content = content


def _touch(path, fs):
    with fs.open(path, 'x'):
        pass


def _real_filesystem():
    return filesystem.real_filesystem()


@memoize
def _subject_model():
    import upload_bot._models.filesystem as mod
    return mod


if __name__ == '__main__':
    unittest.main()

# #born.
