from modality_agnostic.test_support.common import lazy
import os.path as os_path


@lazy
def writable_tmpdir():
    return os_path.join(top_test_dir(), 'writable-tmpdir')


@lazy
def file_with_content_path():
    return os_path.join(
            _fixture_files_directory(), '001-file-with-content.txt')


@lazy
def no_ent_path():
    return os_path.join(_fixture_files_directory(), 'the-no-ent-path.file')


@lazy
def _fixture_files_directory():
    return os_path.join(top_test_dir(), 'fixture-files')


@lazy
def top_test_dir():
    return os_path.dirname(__file__)


"""NOTE - this is NOT for REAL values!

this is a VERSIONED file. it is *not* secure.
put PHONY values in here and refer to those values in the tests.

(values that look like they might be real are probably copy-pasted from
postman docs here: https://api.slack.com/events/url_verification)
"""

BOT_USER_OATH_ACCESS_TOKEN_EXAMPLE_ = 'xoxb-987-exampleEXAMPLEexample987'
VERIFICATION_TOKEN_EXAMPLE_ = 'Jhj5dZrVaK7ZwHHjRyZWjbDl'


# #born.
