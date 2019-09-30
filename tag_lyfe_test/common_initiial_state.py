from modality_agnostic.memoization import (
        lazy)
import os.path as os_path


def fixture_file_path(stem):
    return os_path.join(_top_test_dir(), 'fixture-files', stem)


@lazy
def _top_test_dir():
    return os_path.dirname(__file__)

# #pending-rename: typo
# #extracted from sibling
