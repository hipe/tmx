def _build_end_state(cc, tc):
    from kiss_rdb.magnetics_.entities_via_filter_by_tags import (
            stats_future_and_results_via_entity_stream_and_query,
            prepare_query)

    itr = stats_future_and_results_via_entity_stream_and_query(
            tc.given_collection(), prepare_query(cc.query()))

    future = next(itr)
    flush_first = tuple(itr)

    return {'stats': future(), 'result_list': flush_first}


class _Case:
    build_end_state = _build_end_state

    def expect_these_stats(self, tc, **expected_dct):
        _actual = tc.end_state()['stats']
        tc.assertEqual(_actual, expected_dct)


class _CaseOfSimplifiedTypical(_Case):

    def expect_these_two_entities(self, tc):
        these = tc.end_state()['result_list']
        tc.assertEqual(len(these), 2)
        _actual = tuple(ent.identifier_string for ent in these)
        tc.assertSequenceEqual(_actual, ('ENA', 'ENC'))

    def expect_the_appropriate_statistics(self, tc):
        self.expect_these_stats(
                tc,
                count_of_items_that_did_not_have_taggings=0,
                count_of_items_that_had_taggings=3,
                count_of_items_that_did_not_match=1,
                count_of_items_that_matched=2,
                )

    def query(self):
        return ('#red', 'or', '#blue')


case_of_one_column_match_two_out_of_three = _CaseOfSimplifiedTypical()


class _CaseOfEmptyCollection(_Case):

    def expect_no_entities(self, tc):
        these = tc.end_state()['result_list']
        tc.assertEqual(len(these), 0)

    def expect_the_appropriate_statistics(self, tc):
        self.expect_these_stats(
                tc,
                count_of_items_that_did_not_have_taggings=0,
                count_of_items_that_had_taggings=0,
                count_of_items_that_did_not_match=0,
                count_of_items_that_matched=0,
                )

    def query(self):
        return ('#aa:bb',)


case_of_empty_collection = _CaseOfEmptyCollection()


# #history-A.1: full rewrite
# #born.
