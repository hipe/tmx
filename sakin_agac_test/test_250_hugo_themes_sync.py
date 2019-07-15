from sakin_agac_test.common_initial_state import (
        fixture_directory_for)
import unittest


_CommonCase = unittest.TestCase


# Case200SA is used to reference this whole file


class Case250_HI(_CommonCase):

    def test_010_HI(self):
        these = []

        _report = _subject_module()
        _ = _themes_dir_A()
        _cm = _report.open_dictionary_stream(_, None)

        with _cm as dcts:
            for dct in dcts:
                these.append(dct)

        these[0]['_is_sync_meta_data']
        tags_k = 'tags_generated'
        label_k = 'label'

        # == BEGIN fix near [#410.Z] order is indeterminate
        order_me = these[1:]
        order_me.sort(key=lambda dct: dct[label_k])
        one, two = order_me
        # ==

        tags_one = one[tags_k]
        tags_two = two[tags_k]

        self.assertEqual(one[label_k], 'Academic')
        self.assertEqual(two[label_k], 'Facka formic')

        self.assertEqual(tags_one, tags_two)


def _subject_module():
    from script.producer_scripts.script_180920_hugo_themes import (
            report_200_alternatives_and_their_useful_phenomena as _)
    return _


def _themes_dir_A():
    return fixture_directory_for('0190-a-few-hugo-themes')


if __name__ == '__main__':
    unittest.main()

# #born.
