import unittest
import sys
import os

# boilerplate
p = os.path
d = p.dirname
my_test_dir = d(d(p.abspath(__file__)))
omni_project_path = d(my_test_dir)
a = sys.path
if a[0] != omni_project_path:
    a.insert(0, omni_project_path)
del omni_project_path
del d
# end boilerplate

from game_server import (  # noqa: E402
        memoize,
        )


class Case010_XXX(unittest.TestCase):

    def test_010_magnet_loads(self):
        self.assertIsNotNone(_subject_module())


@memoize
def _subject_module():
    import grep_dump._magnetics.indexed_tree_via_dump_and_job as x
    return x


if __name__ == '__main__':
    unittest.main()

# #born.
