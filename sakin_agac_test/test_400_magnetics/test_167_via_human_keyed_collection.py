import _init  # noqa F401
from modality_agnostic.memoization import (
        memoize,
        )
import doctest
import unittest


def load_tests(loader, tests, ignore):  # (this is a unittest API hook-in)
    tests.addTests(doctest.DocTestSuite(_subject_module()))
    return tests


@memoize
def _subject_module():
    import sakin_agac.magnetics.via_human_keyed_collection as x
    return x


if __name__ == '__main__':
    unittest.main()

# #born.
