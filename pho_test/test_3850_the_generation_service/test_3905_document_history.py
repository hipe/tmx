from modality_agnostic.test_support.common import lazy
from unittest import TestCase as unittest_TestCase, main as unittest_main
from collections import namedtuple


class CommonCase(unittest_TestCase):

    def build_end_state(self):
        def these():
            for verb_lexeme_key, dt_string in self.given_these():
                dt = strptime(dt_string, '%Y-%m-%d %H:%M:%S')
                yield business_item_via(verb_lexeme_key, dt)

        lexi = this_lexicon()
        from datetime import datetime
        strptime = datetime.strptime
        func = subject_module()._words_via_business_items

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
        from datetime import datetime
        dt_now = datetime(2021, 2, 20, 0, 17, 39)
        return lines_via_words(func(these(), lexi, datetime_now=dt_now))


class Case1234_XXXX(CommonCase):

    def test_010_go(self):
        act = tuple(self.build_end_state())
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
    words_of_oxford_join = mod._words_of_oxford_join

    from text_lib.magnetics.words_via_time import \
        prepositional_phrase_words_via_context_stack as pp_via_cstack

    return Lexicon()


def lines_via_words(words):
    cache = []
    for w in words:
        cache.append(w)
        if -1 != w.rfind('.', -1):  # not robust
            # (not terminating with newline just because no need here)
            yield ' '.join(cache)
            cache.clear()
    if cache:
        yield ' '.join(cache)


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
