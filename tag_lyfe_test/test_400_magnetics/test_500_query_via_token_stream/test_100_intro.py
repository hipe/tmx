from _init import (
        hello_you,
        )
from modality_agnostic.memoization import (
        memoize,
        )
import unittest


_CommonCase = unittest.TestCase


hello_you()


class Case100_hello(_CommonCase):

    def test_100_hi(self):
        self.assertIsNotNone(_subject_magnetic())


@memoize
def _subject_magnetic():
    import tag_lyfe as x  # NOTE
    return x


if __name__ == '__main__':
    unittest.main()

# #born.
