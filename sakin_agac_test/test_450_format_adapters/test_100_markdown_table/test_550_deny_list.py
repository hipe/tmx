"""
.#covers script.heroku_add_ons.json_stream_via_website #[#410.A.1]

objectives are severalfold:
    - cover scraping of this one page format
    - cover that syncing still works here with our crazy new deny list

.:#coverpoint16
"""

from _init import (
        fixture_file_path,
        ProducerCaseMethods,
        )
from modality_agnostic.memoization import (
       dangerous_memoize as shared_subject,
       memoize,
       )
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


class Case100_does_scrape_work(ProducerCaseMethods, _CommonCase):

    def test_010_scrape_works(self):
        self.assertEqual(_reduced_number + 1, len(self._dictionaries()))

    def test_050_pseudo_real_scrape_looks_like_our_raw_dump(self):
        act = self._dictionaries()
        exp = _these_dictionaries()

        self._assert_equal_dictionaries(act[0], exp[0])

        use_len = max(len(act), len(exp))

        for i in range(1, use_len):
            self.assertEqual(act[i], exp[i])

    @shared_subject
    def _dictionaries(self):
        return self.build_raw_list_()

    def far_collection_identifier(self):
        return 'script/heroku_add_ons/json_stream_via_website.py'

    def cached_document_path(self):
        return fixture_file_path('0160-heroku-add-ons.html')


class Case250_does_sync_preview_work(ProducerCaseMethods, _CommonCase):

    def test_010_runs__does_not_have_schema_row(self):
        _act = self._pairs()
        self.assertEqual(_reduced_number, len(_act))
        # (the number being N and not N+1 implies there is no schema item)

    def test_020_see_the_raw_things_and_the_cooked_things(self):

        # for the purposes of inspection, we want you to be able to see
        # the raw thing and the .. cooked things

        for pair in self._pairs():
            dct = pair[1]
            dct['add_on']
            dct['url']
            dct['label']

    def test_030_look_at_this_fuzzification_from_keyer(self):
        pair = self._pairs()[2]
        self.assertEqual(pair[0], 'addinginappnotificationswithpusher')

    @shared_subject
    def _pairs(self):
        return self.build_pair_list_for_inspect_()

    def far_collection_identifier(self):
        return _these_dictionaries()


class Case300_omg_syncing(ProducerCaseMethods, _CommonCase):

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

    def far_collection_identifier(self):
        return _these_dictionaries()

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


@memoize
def _these_dictionaries():
    return tuple(x for x in _yield_these_dictionaries())


def _yield_these_dictionaries():
    yield {
            '_is_sync_meta_data': True,
            'natural_key_field_name': 'add_on',
            'custom_far_keyer_for_syncing': 'script.markdown_document_via_json_stream.COMMON_FAR_KEY_SIMPLIFIER_',  # noqa: E501
            'custom_near_keyer_for_syncing': 'script.markdown_document_via_json_stream.COMMON_NEAR_KEY_SIMPLIFIER_',  # noqa: E501
            'custom_mapper_for_syncing': 'script.markdown_document_via_json_stream.this_one_mapper_("add_on")',  # noqa: E501
            'far_deny_list': ('url', 'label')
    }

    def o(tail):
        return f'{_url}{tail}'
    yield {'url': o('/articles/ably'), 'label': 'Ably'}
    yield {'url': o('/articles/ackfoundry'), 'label': 'ACK Foundry'}
    yield {'url': o('/articles/pusher-in-app-notifications'), 'label': 'Adding In-app Notifications with Pusher'}  # noqa: E501
    yield {'url': o('/articles/adept-scale'), 'label': 'Adept Scale'}


_reduced_number = 4  # how many business items in our reduced collection?


if __name__ == '__main__':
    unittest.main()

# #born.
