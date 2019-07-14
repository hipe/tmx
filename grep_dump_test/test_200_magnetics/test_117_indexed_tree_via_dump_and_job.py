import unittest


class Case010_XXX(unittest.TestCase):

    def test_010_magnet_loads(self):
        self.assertIsNotNone(_subject_module())


def _subject_module():
    import grep_dump._magnetics.indexed_tree_via_dump_and_job as x  # #[#204]
    return x


if __name__ == '__main__':
    unittest.main()

# #born.
