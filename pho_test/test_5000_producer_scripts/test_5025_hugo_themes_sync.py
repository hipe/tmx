import unittest


_CommonCase = unittest.TestCase


class Case5025NC(_CommonCase):

    def test_010_HI(self):

        ps = _subject_module()
        _ = _themes_dir_A()
        with ps.open_traversal_stream(None, _) as dcts:
            order_me_pairs = list(ps.stream_for_sync_via_stream(dcts))

        tags_k = 'tags_generated'
        label_k = 'label'

        # == BEGIN fix near [#410.4] filesystem entry order is indeterminate
        order_me_pairs.sort(key=lambda pair: pair[0])
        pair_one, pair_two = order_me_pairs
        # ==

        key_one, one = pair_one
        key_two, two = pair_two

        assert('acka-dormic' == key_one)
        assert('facka-formic' == key_two)

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
    from pho_test.common_initial_state import fixture_directory
    return fixture_directory('hugo-themes', '0190-a-few-themes')


if __name__ == '__main__':
    unittest.main()

# #born.
