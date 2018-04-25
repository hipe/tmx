import _init  # noqa: F401
from modality_agnostic.memoization import (
        memoize,
        )
import unittest


_CommonCase = unittest.TestCase


class Case010_hello(_CommonCase):

    def test_010_magnetic_loads(self):
        self.assertIsNotNone(_subject_module())

    def test_020_if_you_fail_to_pass_mandatory_parameters_it_borks(self):
        e = None
        try:
            _subject_module()()
        except TypeError as e_:
            e = e_
        _yes = 'required positional arguments' in str(e)
        self.assertTrue(_yes)

    def test_030_the_subject_is_built_with_particular_functions(self):
        subject_one()
        subject_one()
        self.assertIsNotNone(subject_one())


@memoize
def subject_one():
    return _subject_module()(
            item_via_collision=None,
            item_stream_via_native_stream=None,
            natural_key_via_object=None,
            )


def _subject_module():
    import sakin_agac.magnetics.format_adapter_via_definition as x
    return x


if __name__ == '__main__':
    unittest.main()

# #born.
