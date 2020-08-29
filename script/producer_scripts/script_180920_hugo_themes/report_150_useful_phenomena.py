#!/usr/bin/env python3 -W error::Warning::0

"""
mainly, we want to eliminate from the set of phenomena those phenomena that
do not have "wide" usage; namely those that are only associated with one
alternative.

secondarily we want to see the phenomena ordered from most popular to least.
"""
# This producer script is one of several covered by (Case5025NC).


import re


class Report:

    def __init__(self, dispatcher, modality, listener):
        assert('CLI' == modality)
        dispatcher.receive_subscription_to_big_index(self._big_money)

    def _big_money(self, big_index):

        yield 'MOST POPULAR PHENOMENA'

        o = MEMOIZED_THING_B_.value(big_index)
        buckets = o.buckets
        singletons = o.singletons
        surface_via_normal = o.surface_via_normal

        class Once:  # #[#510.5] a "oncer"
            def __init__(self):
                self._is_first_call = True

            def __call__(self):
                if self._is_first_call:
                    self._is_first_call = False
                    return ' surface variations'

        once = Once()

        for count in sorted(buckets.keys(), reverse=True):
            phenomena = buckets[count]
            _num = len(phenomena)
            yield f'  associated with {count} alternatives ({_num}{once()}):'
            for phenomenon_k in sorted(buckets[count]):
                _ = surface_via_normal(phenomenon_k)
                yield f'    {_}'

        if singletons is not None:
            _ = [surface_via_normal(s) for s in singletons]
            _really_long_line = ', '.join(sorted(_))
            yield f'  (singleton phenomena (useless): {_really_long_line})'


class _MemoizedThing:

    def __init__(self):
        self._state = '_calculate_and_memoize'

    def value(self, arg):
        return getattr(self, self._state)(arg)

    def _calculate_and_memoize(self, big_index):
        del(self._state)
        _1 = big_index.assoc_type_via_alternative_via_phenomenon__

        from . import report_050_variation_in_the_phenomena as _  # noqa: E501

        # (see "breaking with tradition ..")
        _2 = _.MEMOIZED_THING_A_.value(big_index.surface_phenomena_index__)
        surface_via_normal = _build_surface_via_normal(_2)

        buckets = _mutable_buckets_of_popularity(_1)

        if 1 in buckets:
            singletons = buckets.pop(1)
        else:
            singletons = None

        self._guy = _Guy(singletons, buckets, surface_via_normal)
        self._state = '_memoized_value'
        return self.value(None)

    def _memoized_value(self, _):
        return self._guy


MEMOIZED_THING_B_ = _MemoizedThing()


class _Guy:
    def __init__(self, _1, _2, _3):
        self.singletons = _1
        self.buckets = _2
        self.surface_via_normal = _3


def _build_surface_via_normal(parseds_via_normal):
    """there's the internal normal name and there's the external "idealized"
    normal name.

    our design policy is that the only place there should be capital letters
    is in acronyms.

    we look at the surface forms to try to detect if there are any of those.

    examples:
        (yes)                  (no)
        AMP                    amp
        SVG                    svg
        SEO-site-verification  seo-site-verification
        google-analytics       Google Analytics

    this is nice to report out but will be annoying..

    sadly it won't magically do the right thing if the input surface forms
    never did the "right" thing.
    so (at writing) we've got:
        css-grid
        css-only
        css3
        html5
        ogp
        rss
        sass
        scss
        seo
        w3css
        ux

    our conclusion is that the only reasonable choice is to require ALL
    lower case for tags 😞. PROS:
    PROS:
      - user doesn't have to think about it
      - we don't have to think about or code for edge cases like above
    CONS:
      - sadly not aesthetic.
    """

    def use_surface_via_normal(normal):

        return normal  # et voila

        parseds = parseds_via_normal[normal]

        # this is "wasteful" but meh ..

        mutable = normal.split('-')
        assert_length = len(mutable)
        r = range(0, assert_length)

        did_change = False
        for parsed in parseds:
            wordishes = parsed.wordishes
            num_wordishes = len(wordishes)

            if num_wordishes is not assert_length:
                raise Exception('cover me .. hm..')

            for i in r:
                wordish = wordishes[i]
                if _looks_like_acronym_rx.match(wordish):
                    did_change = True
                    mutable[i] = wordish  # might be clobbering another one

        if did_change:
            return '-'.join(mutable)
        else:
            return normal  # (would be same as above)

    return use_surface_via_normal


def _mutable_buckets_of_popularity(assoc_type_via_alternative_via_phenomenon):

    buckets = {}
    for phenom_k, xx in assoc_type_via_alternative_via_phenomenon.items():
        count = len(xx)
        if count in buckets:
            ls = buckets[count]
        else:
            ls = []
            buckets[count] = ls
        ls.append(phenom_k)
    return buckets

# --


_looks_like_acronym_rx = re.compile('^[A-Z]{2,}$')


if __name__ == '__main__':
    import sys
    _me = sys.modules[__name__]
    from all import CLI_for_Report as _
    _CLI = _(_me)
    o = sys
    _exitstatus = _CLI(o.stdin, o.stdout, o.stderr, o.argv).execute()
    exit(_exitstatus)

# #born.
