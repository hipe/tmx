from modality_agnostic.test_support.common import lazy, \
        dangerous_memoize_in_child_classes as shared_subect_in_child_classes
from unittest import TestCase as unittest_TestCase, main as unittest_main
from collections import namedtuple


class CommonCase(unittest_TestCase):

    @property
    @shared_subect_in_child_classes
    def end_state(self):
        return tuple(self.build_end_state())

    def build_end_state(self):
        def business_items():
            for verb_lexeme_key, dt_string in self.given_these():
                dt = strptime(dt_string, '%Y-%m-%d %H:%M:%S')
                yield business_item_via(verb_lexeme_key, dt)

        lexi = this_lexicon()
        from datetime import datetime
        strptime = datetime.strptime

        """
        This is how the asset does and doesn't inflect with respect to "now":
        The asset produces expressions that will still read correctly
        whether it's read tomorrow or 100 years from now; (so it does NOT
        produce expressions like "3 days ago"); HOWEVER it DOES change the
        precision with which it expresses times based on how long ago the
        event is (from some "now"); SO, we have to pass in a "fixture now"
        so that the asset doesn't change its behavior under test over time.

        (We didn't realize this until the test broke "on its own" with the
        passage of time whoopsie. The "fixture now" we are using happens to
        be the minute we made the commit originally:)
        """
        dt_now = datetime(2021, 2, 20, 0, 17, 39)

        func = subject_module().time_bucket_expressers_via_business_items_
        return func(business_items(), lexi, datetime_now=dt_now)


class Case3850_the_only_case(CommonCase):

    def test_010_each_time_bucket_you_can_see_earliest_and_latest_dateti(self):
        tbe = self.end_state[-1]
        dt1 = tbe.earliest_datetime
        dt2 = tbe.latest_datetime
        st1 = dt1.isoformat()
        st2 = dt2.isoformat()
        assert '2021-02-19T17:25:54' == st1
        assert '2021-02-19T17:25:56' == st2

    def test_090_TO_LINE_has_periods_but_no_newlines(self):
        act = tuple(tb.to_line_no_end() for tb in self.end_state)
        exp = tuple(self.expected_lines())
        self.assertSequenceEqual(act, exp)

    def expected_lines(_):
        yield 'Caught a red fish and a blue fish in March of 2017.'
        yield 'Caught a big blue fish in April of 2020.'
        yield 'Caught a blue fish on February 14th, 2021.'
        yield 'Caught 2 blue fishes and a big blue fish on the 19th at 5:25pm.'

    def given_these(_):
        yield 'red',      '2017-03-12 16:20:31'
        yield 'blue',     '2017-03-14 16:20:31'
        yield 'big blue', '2020-04-12 16:20:31'
        yield 'blue',     '2021-02-14 16:25:54'
        yield 'blue',     '2021-02-19 17:25:54'
        yield 'blue',     '2021-02-19 17:25:55'
        yield 'big blue', '2021-02-19 17:25:56'


@lazy
def this_lexicon():
    class Lexicon:
        def words_via_frame_ish(_, context_stack, counts):
            pp_words = pp_via_cstack(context_stack)
            pp_words = * pp_words[:-1], ''.join((pp_words[-1], '.'))
            words_es = words_es_via_counts(counts)
            my_words = 'Caught', * tuple(words_of_oxford_join(words_es, 'and'))
            return *my_words, *pp_words

    def words_es_via_counts(counts):
        for verb_lexeme_key, count in counts:
            if 1 == count:
                yield 'a', verb_lexeme_key, 'fish'
                continue
            yield str(count), verb_lexeme_key, 'fishes'  # lol

    mod = subject_module()
    words_of_oxford_join = mod.words_of_oxford_join_

    from text_lib.magnetics.words_via_time import \
        prepositional_phrase_words_via_context_stack as pp_via_cstack

    return Lexicon()


business_item_via = namedtuple('_IDK', ('verb_lexeme_key', 'datetime'))


def subject_module():
    import pho_plugins.for_pelican.article_history_through_VCS.\
        pelican.plugins.article_history_through_VCS.\
        _words_via_frames as module
    return module


def xx(msg=None):
    raise RuntimeError(''.join(('not covered', *((': ', msg) if msg else ()))))


if '__main__' == __name__:
    unittest_main()

# #born
