from modality_agnostic_test.public_support import (
        empty_command_module)
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject)
import unittest


class Case8063_the_only_case(unittest.TestCase):

    def test_050_subject_module_loads(self):
        self.assertIsNotNone(_subject_module())  # ..

    def test_100_subject_builds(self):
        self.assertIsNotNone(self._subject())

    def test_120_you_can_read_the_name(self):
        _guy = self._subject()
        self.assertEqual(_guy.name, 'hello_there')

    @shared_subject
    def _subject(self):
        return _subject_module()(
                name='hello_there',
                command_module=empty_command_module(),
        )


def _subject_module():
    import modality_agnostic.magnetics.command_via_formal_parameters as x
    return x.SELF


if __name__ == '__main__':
    unittest.main()

# #born.
