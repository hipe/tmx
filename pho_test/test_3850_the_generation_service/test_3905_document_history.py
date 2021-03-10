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


class Case3850_exemplary_case(CommonCase):

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


class Case3854_when_its_long(CommonCase):

    def test_010_hello(self):
        act = tuple(tbe.to_line_no_end() for tbe in self.end_state)
        exp = tuple(self.expected_lines())
        self.assertSequenceEqual(act, exp)

    def expected_lines(_):
        yield 'Caught a zizzy fish in October of 2017.'
        yield 'Caught 35 zizzy fishes in 2018.'
        yield 'Caught 14 zizzy fishes in 2019.'
        yield 'Caught 9 zizzy fishes in 2020.'
        yield 'Caught 3 zizzy fishes in January of 2021.'
        yield 'Caught a zizzy fish on February 19th at 9:10pm.'

    def given_these(_):
        yield 'zizzy',      '2017-10-12 22:03:36'
        yield 'zizzy',      '2018-01-14 05:56:29'
        yield 'zizzy',      '2018-01-16 11:20:42'
        yield 'zizzy',      '2018-01-20 02:33:51'
        yield 'zizzy',      '2018-01-20 18:50:37'
        yield 'zizzy',      '2018-01-22 23:45:57'
        yield 'zizzy',      '2018-01-25 10:19:38'
        yield 'zizzy',      '2018-01-29 14:58:52'
        yield 'zizzy',      '2018-02-04 04:43:42'
        yield 'zizzy',      '2018-02-04 17:19:10'
        yield 'zizzy',      '2018-02-13 08:33:22'
        yield 'zizzy',      '2018-02-25 22:36:57'
        yield 'zizzy',      '2018-03-08 13:22:09'
        yield 'zizzy',      '2018-03-26 22:37:28'
        yield 'zizzy',      '2018-03-30 05:58:28'
        yield 'zizzy',      '2018-03-30 19:18:11'
        yield 'zizzy',      '2018-04-04 13:55:22'
        yield 'zizzy',      '2018-04-06 18:11:58'
        yield 'zizzy',      '2018-04-22 04:35:26'
        yield 'zizzy',      '2018-04-22 16:44:59'
        yield 'zizzy',      '2018-04-22 19:20:45'
        yield 'zizzy',      '2018-04-23 01:43:29'
        yield 'zizzy',      '2018-04-24 16:01:17'
        yield 'zizzy',      '2018-05-14 01:00:16'
        yield 'zizzy',      '2018-05-27 20:45:36'
        yield 'zizzy',      '2018-06-09 16:25:49'
        yield 'zizzy',      '2018-06-19 04:04:28'
        yield 'zizzy',      '2018-06-25 14:24:25'
        yield 'zizzy',      '2018-07-21 14:59:13'
        yield 'zizzy',      '2018-08-08 00:15:20'
        yield 'zizzy',      '2018-08-09 06:28:38'
        yield 'zizzy',      '2018-08-10 04:19:18'
        yield 'zizzy',      '2018-08-13 14:49:44'
        yield 'zizzy',      '2018-09-20 06:23:43'
        yield 'zizzy',      '2018-12-10 05:19:53'
        yield 'zizzy',      '2018-12-19 23:50:14'
        yield 'zizzy',      '2019-01-02 13:31:40'
        yield 'zizzy',      '2019-03-13 03:12:50'
        yield 'zizzy',      '2019-05-06 14:24:02'
        yield 'zizzy',      '2019-06-03 19:28:49'
        yield 'zizzy',      '2019-06-05 04:56:55'
        yield 'zizzy',      '2019-06-07 05:34:54'
        yield 'zizzy',      '2019-07-14 17:33:48'
        yield 'zizzy',      '2019-07-20 22:12:54'
        yield 'zizzy',      '2019-07-26 14:40:36'
        yield 'zizzy',      '2019-09-23 22:06:25'
        yield 'zizzy',      '2019-10-13 03:12:51'
        yield 'zizzy',      '2019-10-23 10:52:10'
        yield 'zizzy',      '2019-10-28 10:09:04'
        yield 'zizzy',      '2019-11-12 23:51:34'
        yield 'zizzy',      '2020-01-31 07:31:04'
        yield 'zizzy',      '2020-07-03 05:03:52'
        yield 'zizzy',      '2020-09-17 10:44:16'
        yield 'zizzy',      '2020-09-22 22:32:05'
        yield 'zizzy',      '2020-09-26 23:53:25'
        yield 'zizzy',      '2020-10-09 15:37:49'
        yield 'zizzy',      '2020-10-12 02:44:54'
        yield 'zizzy',      '2020-11-13 14:57:35'
        yield 'zizzy',      '2020-11-15 13:55:39'
        yield 'zizzy',      '2021-01-01 03:35:55'
        yield 'zizzy',      '2021-01-02 21:44:14'
        yield 'zizzy',      '2021-01-21 23:14:43'
        yield 'zizzy',      '2021-02-19 21:10:27'


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
