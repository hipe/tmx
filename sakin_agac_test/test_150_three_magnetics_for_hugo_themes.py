"""
.#covers script.SSGs.hugo_themes_deep.relevant_themes_collection_metadata_via_themes_dir #[#410.A.1]  # noqa: E501
.#covers script.SSGs.hugo_themes_deep.theme_directory_stream_via_themes_dir #[#410.A.1]  # noqa: E501
.#covers script.SSGs.hugo_themes_deep.theme_toml_stream_via_themes_dir #[#410.A.1]  # noqa: E501
"""

from sakin_agac_test.common_initial_state import (
        fixture_directory_for)
from modality_agnostic.memoization import lazy
import unittest


_CommonCase = unittest.TestCase


# Case100SA is used to reference this whole file


class Case140_magenetic_one(_CommonCase):

    def test_010_loads(self):
        self.assertIsNotNone(_subject_module_one())

    def test_100_HI(self):
        self.assertIsNotNone(self._subject())

    def test_110_thing_one(self):
        x = self._subject().deny_tuple
        self.assertIsInstance(x, tuple)
        self.assertGreater(len(x), 2)

    def test_120_thing_two(self):
        x = self._subject().no_demo_tuple
        self.assertIsInstance(x, tuple)
        self.assertGreater(len(x), 2)

    def test_130_thing_one(self):
        x = self._subject().find_command
        self.assertIsInstance(x, str)
        self.assertGreater(len(x), 40)

    def test_210_to_dictionary(self):
        x = self._subject()
        dct = x.to_dictionary()
        self.assertIsNotNone(dct['deny_list'])
        self.assertIsNotNone(dct['no_demo_list'])
        self.assertIsNotNone(dct['find_command'])

    def _subject(self):
        return _product_of_magnet_one()


class Case150_magenetic_two(_CommonCase):

    def test_010_loads(self):
        self.assertIsNotNone(_subject_module_two())

    def test_100_HI(self):
        self.assertIsNotNone(self._subject())

    def test_110_content(self):
        paths = self._subject()
        from os import path as os_path

        f = os_path.basename
        sorted_basenames = sorted(f(x) for x in paths)
        # #[#410.Z] it is not specified that the result list is sorted.
        # so the order of the list is indeterminate. but we need it to
        # be determinate to test it (or use sets or something crazy).)

        def o(target_basename):
            _actual_basename = sorted_basenames[indexer.value]
            self.assertEqual(_actual_basename, target_basename)
            indexer.increment()

        indexer = Counter()

        # (you should not see a '.github' directory here, per [#410.Z.2])
        o('acka-dormic')
        o('facka-formic')
        self.assertEqual(len(sorted_basenames), 2)

    def _subject(self):
        return _product_of_magnet_two()


class Case160_magnetic_three(_CommonCase):

    def test_010_loads(self):
        self.assertIsNotNone(_subject_module_three())

    def test_100_HI(self):
        self.assertIsNotNone(self._subject())

    def test_110_content(self):
        dcts = self._subject()
        # near [#410.Z] order is indeterminate
        names = [x['name'] for x in dcts]
        names.sort()

        def o(expected_name):
            self.assertEqual(names[indexer.value], expected_name)
            indexer.increment()

        indexer = Counter()
        dct = dcts[0]  # pick any one MAYBE ..
        isinstance(dct['features'], list)
        isinstance(dct['tags'], list)

    def _subject(self):
        return _product_of_magnet_three()


@lazy
def _product_of_magnet_three():
    prev = _product_of_magnet_two()  # or not
    dictionary_via_toml_via_path = _subject_module_three()._make_toml_parser(None)  # noqa: E501
    return tuple(dictionary_via_toml_via_path(x) for x in prev)


@lazy
def _product_of_magnet_two():
    o = _product_of_magnet_one()  # or not
    __ = _themes_dir_A()

    _ = _subject_module_two()._open_theme_directory_stream_via_these(
            themes_dir=__,
            find_command=o.find_command,
            bash_interpolation_expression=o.bash_interpolation_expression,
            listener=__file__)

    with _ as exes:
        result = tuple(x for x in exes)
    return result


@lazy
def _product_of_magnet_one():
    _ = _subject_module_one().relevant_themes_collection_metadata_via_themes_dir  # noqa: E501
    __ = _themes_dir_A()
    return _(themes_dir=__, listener=__file__)


@lazy
def _themes_dir_A():
    return fixture_directory_for('0190-a-few-hugo-themes')


def _subject_module_three():
    from script.producer_scripts import (
            script_180920_hugo_theme_toml_stream_via_themes_dir as _)
    return _


def _subject_module_two():
    from script.producer_scripts import (
            script_180920_hugo_theme_directory_stream_via_themes_dir as _)
    return _


def _subject_module_one():
    from script.producer_scripts import (
            script_180920_hugo_relevant_themes_collection_metadata_via_themes_dir as _)  # noqa: E501
    return _


def Counter():
    from modality_agnostic.memoization import Counter
    return Counter()


if __name__ == '__main__':
    unittest.main()

# #born.
