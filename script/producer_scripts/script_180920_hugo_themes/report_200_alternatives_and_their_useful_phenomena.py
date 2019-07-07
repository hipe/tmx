#!/usr/bin/env python3 -W error::Warning::0

"""
for each alternative, show a list of its phenomena, having subtracted out
those phenomena we aren't interested in because they're singletons. YAY!
"""
# #[#410.1.2] this is a producer script.


class open_dictionary_stream:

    def __init__(self, themes_dir, listener):
        self._themes_dir = themes_dir
        self._listener = listener

    def __enter__(self):
        from script.SSGs.hugo_themes_deep.tags_and_features_reports.all import API_for_Report__ as _  # noqa: E501
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
        elif 'API' == modality:
            use = self._yield_dictionaries
        else:
            self.sanity()

        dispatcher.receive_subscription_to_big_index(use)
        dispatcher.receive_subscription_to_tap_each_alternative(tap)

    def _yield_lines(self, big_index):

        yield 'THE FINAL REPORT (alternatives and thier useful phenomenon):'

        for dct in self._dictionario_dawson(big_index):
            _use_label = dct['label']
            dct['url']  # ignored, but hi
            _tags = dct['tags_generated']
            yield f'  {_use_label} ({_tags})'

    def _yield_dictionaries(self, big_index):

        yield {
                '_is_sync_meta_data': True,
                'natural_key_field_name': 'CHOO_CHA',
                'custom_far_keyer_for_syncing': 'script.markdown_document_via_json_stream.COMMON_FAR_KEY_SIMPLIFIER_',  # noqa: E501
                'custom_near_keyer_for_syncing': 'script.markdown_document_via_json_stream.COMMON_NEAR_KEY_SIMPLIFIER_',  # noqa: E501
                'custom_mapper_for_syncing': 'script.markdown_document_via_json_stream.this_one_mapper_("hugo_theme")',   # noqa: E501
                'far_deny_list': ('url', 'label'),  # documented @ [#418.I.3.2]  # noqa: E501
                }

        for dct in self._dictionario_dawson(big_index):
            yield dct

    def _dictionario_dawson(self, big_index):

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
            sanity() if phenomenon in dct else None
            dct[phenomenon] = True

    for phenomena in singeltons:
        dct[phenomena] = False

    return dct


def _me_as_module():
    import sys
    return sys.modules[__name__]


def sanity():
    raise Exception('sanity')


if __name__ == '__main__':
    from all import CLI_for_Report as _
    _CLI = _(_me_as_module())
    import sys as o
    _exitstatus = _CLI(o.stdin, o.stdout, o.stderr, o.argv).execute()
    exit(_exitstatus)

# #born.
