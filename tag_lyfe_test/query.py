import modality_agnostic.test_support.common as em
from modality_agnostic.test_support.common import \
        dangerous_memoize as shared_subject, lazy


class _ScaryCommonCaseWatcher(type):

    def __init__(cls, name, bases, clsdict):
        if len(cls.mro()) > 2:
            _add_scary_common_case_memoizing_methods(cls)
        super().__init__(name, bases, clsdict)


class ScaryCommonCase(metaclass=_ScaryCommonCaseWatcher):

    def does_not_match_against(self, tup):
        _did = self._yes_no_match(tup)
        self.assertFalse(_did)

    def matches_against(self, tup):
        _did = self._yes_no_match(tup)
        self.assertTrue(_did)

    def _yes_no_match(self, tup):

        cache = _yikes_cache_of_tag_subtrees
        if tup in cache:
            subtree = cache[tup]
        else:
            subtree = _build_tag_subtree(tup)
            cache[tup] = subtree

        _query = self.end_state.result

        return _query.yes_no_match_via_tag_subtree(subtree)

    def point_at_word(self, w):
        offset_of_where_arrow_is_pointing_to, _1 = self._yikes_these()
        md = _word_regex().search(_1, offset_of_where_arrow_is_pointing_to)
        _act = md[0]  # ..
        self.assertEqual(_act, w)

    def point_at_offset(self, i):
        offset_of_where_arrow_is_pointing_to, _1 = self._yikes_these()
        self.assertEqual(offset_of_where_arrow_is_pointing_to, i)

    def _yikes_these(self):
        _1, _2 = self.end_state.first_emission_messages[1:3]
        return len(_2) - 1, _1

    def says(self, s):
        _act = self.end_state.first_emission_messages[0]
        self.assertEqual(_act, s)

    def fails(self):
        self.assertIsNone(self.end_state.result)

    def unparses_to(self, s):
        _wat = self.end_state.result
        _actual = _wat.to_string()
        self.assertEqual(_actual, s)

    def query_compiles(self):
        sta = self.end_state
        self.assertIsNotNone(sta.result)
        self.assertIsNone(sta.first_emission_messages)


def _add_scary_common_case_memoizing_methods(cls):
    @shared_subject
    def end_state(self):
        return _EndState(self)
    cls.end_state = end_state


def _build_tag_subtree(tag_emblems):
    import tag_lyfe.the_tagging_model as lib
    import re

    cache = _yikes_cache_of_tags

    def f(tag_emblem):
        if tag_emblem in cache:
            return cache[tag_emblem]
        else:
            tag = build(tag_emblem)
            cache[tag_emblem] = tag
            return tag

    def build(tag_emblem):
        """due to [#707.D] the catch-22 of our development, we can't yet
        robustly parse such taggings. so, this rough work instead.
        """

        post_hashtag = pass_1_rx.search(tag_emblem)[1]  # ..
        if ':' in post_hashtag:
            return lib.tagging_via_sanitized_pieces(post_hashtag.split(':'))
        else:
            return lib.tagging_via_sanitized_tag_stem(post_hashtag)

    pass_1_rx = re.compile(r'^#([a-z:0-9.]+)$')

    return lib.tag_subtree_via_tags(f(x) for x in tag_emblems)


class _EndState:

    def __init__(self, tc):
        listener, emissions = em.listener_and_emissions_for(tc, limit=1)

        tox = tc.given_tokens()

        from tag_lyfe.magnetics import query_via_token_stream as mag

        from tag_lyfe import NULL_BYTE_

        query_s = NULL_BYTE_.join(tox)

        itr = mag.MAKE_CRAZY_ITERATOR_THING(query_s)

        next(itr)  # ignore the model

        unsani = next(itr)

        x = unsani.sanitize(listener)

        if len(emissions):
            emi, = emissions
            self.first_emission_messages = tuple(emi.payloader())
        else:
            self.first_emission_messages = None

        if x is None:
            self.result = None
        else:
            self.result = x


@lazy
def _word_regex():
    import re
    return re.compile(r'[^ ]+')


_yikes_cache_of_tag_subtrees = {}
_yikes_cache_of_tags = {}


# #history-A.2: this used to be the _init file but took the history DNA
# #history-A.1: things changed at upgrade to python 3.7
# #born.
