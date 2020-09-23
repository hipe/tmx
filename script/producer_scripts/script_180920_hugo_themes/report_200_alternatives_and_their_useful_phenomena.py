#!/usr/bin/env python3 -W default::Warning::0

"""
for each alternative, show a list of its phenomena, having subtracted out
those phenomena we aren't interested in because they're singletons. YAY!
"""
# This producer script is one of several covered by (Case5025NC).


def stream_for_sync_via_stream(dcts):
    import re
    rx = re.compile(r'/([^/]+)/$')

    for dct in dcts:
        url = dct['url']
        _sync_key = rx.search(url)[1]
        # _f"[{dct['label']}]({dct['url']})",  # meh
        _dct_ = {
                'label': dct['label'],
                'tags_generated': dct['tags_generated']
                }
        yield (_sync_key, _dct_)


class open_traversal_stream:

    def __init__(self, listener, themes_dir):
        self._themes_dir = themes_dir
        self._listener = listener

    def __enter__(self):
        from .all import API_for_Report__ as _
        return _(self._themes_dir, _me_as_module(), self._listener)

    def __exit__(self, *_4):
        return False


class Report:

    def __init__(self, dispatcher, modality, listener):
        a = []

        def tap(three, alternative):
            a.append((three, alternative))
        self._memoized_list = a

        if 'CLI' == modality:
            use = self._yield_lines
        else:
            assert('API' == modality)
            use = self._yield_dictionaries

        dispatcher.receive_subscription_to_big_index(use)
        dispatcher.receive_subscription_to_tap_each_alternative(tap)

    def _yield_lines(self, big_index):

        yield 'THE FINAL REPORT (alternatives and their useful phenomenon):'

        _dicts = self._yield_dictionaries(big_index)

        for dct in _dicts:
            _use_label = dct['label']
            dct['url']  # ignored, but hi
            _tags = dct['tags_generated']
            yield f'  {_use_label} ({_tags})'

    def _yield_dictionaries(self, big_index):
        from . import report_150_useful_phenomena as _
        o = _.MEMOIZED_THING_B_.value(big_index)
        buckets = o.buckets
        singletons = o.singletons  # hi.
        surface_via_normal = o.surface_via_normal

        def hashtag_etc(normal):
            return f'#{surface_via_normal(normal)}'

        yes_or_no_via_phenomenon = _build_yes_or_no_via(singletons, buckets)

        sort_me = []
        for three, alternative in self._memoized_list:
            sort_me.clear()
            for phenomenon in _flatten_three(*three):
                if yes_or_no_via_phenomenon[phenomenon]:
                    sort_me.append(phenomenon)

            _tags = ' '.join(hashtag_etc(x) for x in sorted(sort_me))
            _label = alternative.dictionary['name']
            _url = f'https://themes.gohugo.io/{alternative.basename}/'

            yield {
                    'label': _label,
                    'url': _url,
                    'tags_generated': _tags,
                    }


def _flatten_three(left_only, both, right_only):
    for x in left_only:
        yield x
    for x in both:
        yield x
    for x in right_only:
        yield x


def _build_yes_or_no_via(singeltons, buckets):
    """
    from the indexes of phenomena grouped by frequency of association,
    make a map that tells you per phenomenon simply NO or YES based on if
    the count of the associations was one or more than one.
    """

    dct = {}
    for _count, phenomena in buckets.items():
        for phenomenon in phenomena:
            assert(phenomenon not in dct)
            dct[phenomenon] = True

    for phenomena in singeltons:
        dct[phenomena] = False

    return dct


def _me_as_module():
    import sys
    return sys.modules[__name__]


if __name__ == '__main__':
    from all import CLI_for_Report as func
    _CLI = func(_me_as_module())
    import sys as o
    exit(_CLI(o.stdin, o.stdout, o.stderr, o.argv))

# #born.
