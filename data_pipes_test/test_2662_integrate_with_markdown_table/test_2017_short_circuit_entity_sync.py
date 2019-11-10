"""
objectives are severalfold:
    - cover scraping of this one page format
    - cover behavior about avoiding no-op entity sync
"""

from data_pipes_test.common_initial_state import (
        html_fixture,
        ProducerCaseMethods)
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        lazy)
import unittest


class _CommonCase(unittest.TestCase):

    def _assert_equal_dictionaries(self, act_dct, exp_dct):
        # dct.items() no, strange order

        act_keys = act_dct.keys()
        exp_keys = exp_dct.keys()

        self.assertEqual(act_keys, exp_keys)

        def of(dct):
            return list(dct[k] for k in exp_keys)

        self.assertSequenceEqual(of(act_dct), of(exp_dct))


# Case2013DP  # is used to refer to the whole test file


class Case2014_does_scrape_work(ProducerCaseMethods, _CommonCase):

    def test_010_scrape_works(self):
        self.assertEqual(_reduced_number, len(self._dictionaries()))

    def test_050_pseudo_real_scrape_looks_like_our_raw_dump(self):
        act = self._dictionaries()
        exp = _these_dictionaries()

        self._assert_equal_dictionaries(act[0], exp[0])

        use_len = max(len(act), len(exp))

        for i in range(1, use_len):
            self.assertEqual(act[i], exp[i])

    @shared_subject
    def _dictionaries(self):
        return self.build_dictionaries_tuple_from_traversal_()

    def producer_script(self):
        return _production_producer_script()

    def cached_document_path(self):
        return html_fixture('0160-heroku-add-ons.html')


class Case2016_does_sync_preview_work(ProducerCaseMethods, _CommonCase):

    def test_010_runs__does_not_have_schema_row(self):
        _act = self._pairs()
        self.assertEqual(_reduced_number, len(_act))
        # (the number being N and not N+1 implies there is no schema item)

    def test_020_see_only_the_cooked_not_the_raw_things(self):
        # before #history-A.1 this would test "raw things and cooked things"

        count = 0
        same = ('add_on',)
        for pair in self._pairs():
            dct = pair[1]
            assert(tuple(dct.keys()) == same)
            count += 1

        assert(2 < count)

    def test_030_look_at_this_fuzzification_from_keyer(self):
        pair = self._pairs()[2]
        self.assertEqual(pair[0], 'addinginappnotificationswithpusher')

    @shared_subject
    def _pairs(self):
        return self.build_pair_list_for_inspect_()

    def producer_script(self):
        return _production_producer_script()

    def cached_document_path(self):
        return _these_dictionaries()  # 👀 LOOK


class Case2018DP_scrape_AND_sync_preview(ProducerCaseMethods, _CommonCase):

    def test_100_produces_something(self):
        self.assertEqual(len(self._pairs()), 2)

    def test_200_each_key_looks_fuzzy(self):
        def f(pair):
            return pair[0]
        self.assertSequenceEqual(self._map(f), ('minimo', 'navigatorhugo'))

    def test_300_each_business_item_has_only_the_thing(self):
        def f(pair):
            assert(tuple(pair[1].keys()) == same)
        same = ('hugo_theme',)
        self._walk(f)

    def _walk(self, f):  # experiment
        for x in self._pairs():
            f(x)

    def _map(self, f):  # experiment
        return [f(x) for x in self._pairs()]
        # we can't leave it as generator and use `assertSequenceEqual`

    @shared_subject
    def _pairs(self):
        return self.build_pair_list_for_inspect_()

    def producer_script(self):
        return 'script/producer_scripts/script_180905_hugo_themes.py'

    def cached_document_path(self):
        return html_fixture('0180-hugo-themes.html')


class Case2019DP_omg_syncing(ProducerCaseMethods, _CommonCase):

    def test_100_did_something(self):
        a = self._output_lines()
        self.assertGreaterEqual(len(a), 6)
        # at least as many as we started with

    def test_200_left_this_one_alone__LEFT_ONLY__(self):
        a = self._output_lines()
        self.assertEqual(a[4], _same_ablzton_live)

    def test_300_added_these_three_at_the_end__RIGHT_ONLY__(self):
        a = self._output_lines()
        self.assertEqual(a[-3][0:8], '|[ACK Fo')
        self.assertEqual(a[-2][0:8], '|[Adding')
        self.assertEqual(a[-1][0:8], '|[Adept ')

    def test_400_far_items_came_in_but_were_identical__CENTER_SAME__(self):
        a = self._output_lines()
        self.assertEqual(a[5], _same_ack_foundry)

    def test_400_see_how_the_url_got_fixed_here__CENTER_UPDATE__(self):
        a = self._output_lines()
        self.assertEqual(a[3], f'|[Ably]({_url}/articles/ably)| keep B1 | keep C1 |\n')  # noqa: E501

    @shared_subject
    def _output_lines(self):
        return self.build_YIKES_SYNC_()

    def producer_script(self):
        from kiss_rdb.storage_adapters_.markdown_table.LEGACY_markdown_document_via_json_stream import (  # noqa: E501
                markdown_link_via, simple_key_via_normal_key)
        from kiss_rdb import normal_field_name_via_string

        def stream_for_sync_via_stream(dcts):
            for dct in dcts:
                _md_link = markdown_link_via(dct['label'], dct['url'])
                _ = normal_field_name_via_string(dct['label'])
                _ = simple_key_via_normal_key(_)
                yield (_, {'add_on': _md_link})
        return {
                'stream_for_sync_is_alphabetized_by_key_for_sync': False,
                'stream_for_sync_via_stream': stream_for_sync_via_stream,
                'dictionaries': _these_dictionaries(),
                'near_keyerer': near_keyerer_common,
                }

    def near_collection_identifier(self):
        return _this_markdown_fellow()


def _this_markdown_fellow():
    yield '| Add-On | Tags | Notes |\n'
    yield '|:--|:--|:--|\n'
    yield '| (example) | #example  | #example  |\n'
    yield '|[Ably](fix this url)| keep B1 | keep C1 |\n'
    yield _same_ablzton_live
    yield _same_ack_foundry


_url = 'https://devcenter.heroku.com'
_same_ablzton_live = '|[Ablzton Live](xx) | keep B2 ||\n'
_same_ack_foundry = f'|[ACK Foundry]({_url}/articles/ackfoundry)|||\n'  # noqa: #501


@lazy
def _these_dictionaries():
    return tuple(_yield_these_dictionaries())


def _yield_these_dictionaries():
    def o(tail):
        return f'{_url}{tail}'
    yield {'url': o('/articles/ably'), 'label': 'Ably'}
    yield {'url': o('/articles/ackfoundry'), 'label': 'ACK Foundry'}
    yield {'url': o('/articles/pusher-in-app-notifications'), 'label': 'Adding In-app Notifications with Pusher'}  # noqa: E501
    yield {'url': o('/articles/adept-scale'), 'label': 'Adept Scale'}


def _production_producer_script():
    return 'script/producer_scripts/script_180421_heroku_add_ons.py'


def near_keyerer_common(key_via_native, schema, listener):  # pure pass-thru

    from kiss_rdb.storage_adapters_.markdown_table.LEGACY_markdown_document_via_json_stream import (  # noqa: E501
            simplified_key_via_markdown_link_er)

    # (reminder: function takes a row_DOM and returns a sync_key)

    simplified_key_via_markdown_link = simplified_key_via_markdown_link_er()

    def simplified_key_via_row_DOM(row_DOM):
        _orig_key = key_via_native(row_DOM)
        return simplified_key_via_markdown_link(_orig_key)

    return simplified_key_via_row_DOM


_reduced_number = 4  # how many business items in our reduced collection?


if __name__ == '__main__':
    unittest.main()

# #history-A.1: no more sync-side item-mapping
# #born.
