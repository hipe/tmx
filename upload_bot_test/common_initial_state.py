"""this is *the* [#019.file-type-D]. see."""

import os
path = os.path


def _():
    import sys

    dn = path.dirname
    a = sys.path
    head = a[0]

    top_test_dir = dn(__file__)
    mono_repo_dir = dn(top_test_dir)

    if mono_repo_dir == head:

        pass  # assume low entrypoint loaded us to use for resources

    elif top_test_dir == head:
        None if mono_repo_dir == a[1] else sanity()
        a[0] = mono_repo_dir
        a[1] = top_test_dir  # [#019.why-this-in-the-second-position]

    else:
        sanity()

    return top_test_dir


def sanity():
    raise Exception('assumption failed')


top_test_dir = _()


from modality_agnostic.memoization import (  # noqa: E402
        memoize,
        )


@lazy
def writable_tmpdir():
    return path.join(top_test_dir, 'writable-tmpdir')


@lazy
def file_with_content_path():
    return path.join(_fixture_files_directory(), '001-file-with-content.txt')


@lazy
def no_ent_path():
    return path.join(_fixture_files_directory(), 'the-no-ent-path.file')


@lazy
def _fixture_files_directory():
    return path.join(top_test_dir, 'fixture-files')


"""NOTE - this is NOT for REAL values!

this is a VERSIONED file. it is *not* secure.
put PHONY values in here and refer to those values in the tests.

(values that look like they might be real are probably copy-pasted from
postman docs here: https://api.slack.com/events/url_verification)
"""

BOT_USER_OATH_ACCESS_TOKEN_EXAMPLE_ = 'xoxb-987-exampleEXAMPLEexample987'
VERIFICATION_TOKEN_EXAMPLE_ = 'Jhj5dZrVaK7ZwHHjRyZWjbDl'


# #born.
