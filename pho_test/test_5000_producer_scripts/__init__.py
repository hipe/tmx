from modality_agnostic.memoization import lazy
from os import path as os_path


def executable_fixture(tail):
    return os_path.join(_top_test_dir(), 'fixture_executables', tail)


def fixture_directory_for(tail):
    return os_path.join(_top_test_dir(), 'fixture-directories', tail)


@lazy
def _top_test_dir():
    return os_path.dirname(__file__)

# #partial-copy (lost DNA)
