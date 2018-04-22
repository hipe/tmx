import _init  # noqa: F401
import unittest

from modality_agnostic.memoization import (  # noqa: E402
        memoize,
        )


class Case010_XXX(unittest.TestCase):

    def test_010_magnet_loads(self):
        self.assertIsNotNone(_subject_module())


@memoize
def _subject_module():
    import grep_dump._magnetics.indexed_tree_via_dump_and_job as x  # #[#204]
    return x


if __name__ == '__main__':
    unittest.main()

# #born.
