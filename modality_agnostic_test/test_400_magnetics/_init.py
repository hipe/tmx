"""this is a *100% copy-paste* of the inelegant #[#019.file-type-C]. see."""

import sys


def _():
    import os

    path = os.path
    dn = path.dirname

    a = sys.path
    head = a[0]

    test_sub_dir = dn(__file__)
    top_test_dir = dn(test_sub_dir)
    mono_repo_dir = dn(top_test_dir)

    if test_sub_dir == head:
        a[0] = mono_repo_dir
    elif mono_repo_dir == head:
        # one of two possibilities:
        #
        # 1. unittest is running the whole tree. the specific test files
        # nearby by specific resources in this file.
        #
        # 2. we are running only the nearby file in standalone mode, but
        # we need specific resources here. the nasty thing is happening
        # and file gets loaded twice.
        pass
    else:
        raise Exception('sanity')


_()


from modality_agnostic_test._init import (  # noqa: F402
        fixture_directory as _fixture_directory,
        )


def empty_command_module():
    from modality_agnostic_test.public_support import empty_command_module as x
    return x()


fixture_directory = _fixture_directory

# #born.
