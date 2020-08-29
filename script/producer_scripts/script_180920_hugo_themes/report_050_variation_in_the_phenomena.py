#!/usr/bin/env python3 -W error::Warning::0

"""
## defining a term and offering a metric: normalcy

the question is simply: is there variation in terms of capitalization and
word separation (like underscore vs space vs dash vs CamelCase) to a point
where different "surface forms" of the phenomena actually refer to the same
"deep instance"?

  - one possible approach: machine-driven super-simplification
    (possible cons)

  - we offer a metric: use machine-driven simplification and see if there's
    different "surface forms" for each "deep form"

what variations are there on each phenomena? for example, the phenomena
of "google analytics" appears in *four* different surface forms, at writing:

    (google analytics, Google Analytics, google-analytics, Google analytics)

also:

  - this fellow rolls up the less interesting case of those phenomena
    that have only one variation.
"""
# This producer script is one of several covered by (Case5025NC).


class Report:

    def __init__(self, dispatcher, modality, listener):
        assert('CLI' == modality)
        dispatcher.receive_subscription_to_phenomenon_variation(self)

    def receive_phenomenon_variation(self, surface_phenomena_index):
        yield 'PHENOMENON VARIATIONS:'
        _ = MEMOIZED_THING_A_.value(surface_phenomena_index)
        buckets = _bucket_by_count(_)
        sorted_buckets, ones = _sort_buckets(buckets)

        for count, pairs in sorted_buckets:
            yield f'  phenomena with {count} variations:'
            for normal, parseds in pairs:
                _ = ', '.join(o.surface for o in parseds)
                yield f'    {normal} ({_})'

        if ones is None:
            use_len_ones = 0
        else:
            use_len_ones = len(ones)

        yield f'  ({use_len_ones} phenomena with no variations.)'


def _sort_buckets(buckets):

    counts = list(buckets.keys())
    sorted_counts = sorted(counts, reverse=True)
    if 1 == sorted_counts[-1]:
        use_sorted_counts = sorted_counts[0:-1]
        use_ones = buckets.pop(1)
    else:
        use_sorted_counts = counts
        use_ones = None

    def f():
        for count in use_sorted_counts:
            yield (count, buckets[count])
    return f(), use_ones


def _bucket_by_count(parseds_via_normal):
    count_buckets = {}
    for normal, parseds in parseds_via_normal.items():
        count = len(parseds)
        if count in count_buckets:
            ls = count_buckets[count]
        else:
            ls = []
            count_buckets[count] = ls
        ls.append((normal, parseds))

    def ff(normal_and_parseds):
        # display the list of phenomena be in lexcial order - sort by normal
        return normal_and_parseds[0]

    def f(lis):
        return sorted(lis, key=ff)
    return {count: f(lis) for count, lis in count_buckets.items()}


class _MemoizedThing:

    def __init__(self):
        self._state = '_calculate_and_memoize'

    def value(self, arg):
        return getattr(self, self._state)(arg)

    def _calculate_and_memoize(self, arg):
        del(self._state)
        value = _invert_sort_of(arg.dictionary_READ_ONLY__)
        self.__memoized_value = value
        self._state = '_result_in_memoized_value'
        return self.value(None)

    def _result_in_memoized_value(self, _):
        return self.__memoized_value


MEMOIZED_THING_A_ = _MemoizedThing()


def _invert_sort_of(in_dct):
    out_dct = {}
    for surface, parsed in in_dct.items():
        normal = parsed.normal
        if normal in out_dct:
            lis = out_dct[normal]
        else:
            lis = []
            out_dct[normal] = lis
        lis.append(parsed)
    return out_dct


if __name__ == '__main__':
    import sys
    _me = sys.modules[__name__]
    from all import CLI_for_Report as _
    _CLI = _(_me)
    o = sys
    _exitstatus = _CLI(o.stdin, o.stdout, o.stderr, o.argv).execute()
    exit(_exitstatus)

# #born.
