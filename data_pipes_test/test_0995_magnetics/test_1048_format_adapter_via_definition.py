import _init  # noqa: F401
from modality_agnostic.memoization import lazy
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
        _yes = 'required positional argument' in str(e)
        self.assertTrue(_yes)

    def test_030_the_subject_is_built_with_particular_functions(self):
        self.assertIsNotNone(subject_one())


@lazy
def subject_one():
    return _subject_module()(
            format_adapter_module_name=None,
            )


def _subject_module():
    import sakin_agac.magnetics.format_adapter_via_definition as x
    return x


if __name__ == '__main__':
    unittest.main()

# #born.
