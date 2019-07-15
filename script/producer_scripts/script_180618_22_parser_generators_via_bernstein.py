#!/usr/bin/env python3 -W error::Warning::0

"""
generate a stream of JSON from {raw_url}

(this is the content-producer of the producer/consumer pair)
"""

"""
orginally this scraped HTML but more conveniently the raw markdown is
available to us, exposed by github over plain old HTTP. so at #history-A.1
this refactored quite smoothly into pioneering the idea of scraping
markdown instead (sidestepping the #html2markdown problem).

This producer script is covered by multiple test files:
((Case1640DP), (Case3306DP))
"""


_raw_url = (
        'https://raw.githubusercontent.com'
        '/webmaven/python-parsing-tools/master/README.md'
        )

_my_doc_string = __doc__


class open_traversal_stream:  # #[#410.F] class as context manager

    def __init__(self, markdown_path, listener):
        self.raw_url = _raw_url
        self._markdown_path = markdown_path
        self._listener = listener

    def __enter__(self):
        self._OK = True
        self._OK and self.__resolve_cached_doc()
        if not self._OK:
            return
        with self.__open_traversal_stream() as dcts:
            coll_metadata = next(dcts)  # ..
            far_field_names = coll_metadata.field_names
            dic_via_cels = self.__build_dict_via_cels(far_field_names)
            schema = coll_metadata.to_dictionary()

            yield self.__meta_record_via(dic_via_cels, schema)

            for dct in dcts:
                def _custom_generator():  # risky. no closure scope
                    for k in far_field_names:
                        if k in dct:
                            yield dct[k]
                        else:
                            yield ''  # #[#410.M] how sparseness (holes) must
                yield dic_via_cels(_custom_generator())

    def __exit__(self, *_3):
        return False  # never swallow an exception

    def __meta_record_via(self, dic_via_cels, schema_record):
        """whatever "collection meta record" is emitted by our upstream,

        we emit a meta record based off that one BUT with the field names
        changed to reflect etc.

          - assume #provision [#458.I.2] that the natural key field name
            is leftmost (here in the near field names (which are derived))

        #abstraction-candidate: the format adaptation of [#410.J] the record
        mapper should probably be the one doing this (maybe?)
        """

        near_field_names = dic_via_cels.near_field_names
        o = {k: v for k, v in schema_record.items()}
        o['natural_key_field_name'] = near_field_names[0]  # (per above provis)
        o['field_names'] = near_field_names
        o['custom_keyer_for_syncing'] = 'data_pipes.format_adapters.html.script_common.simplify_keys_',  # noqa: E501
        # above is broken for syncing,
        # #not-covered since #history-A.3 or before
        o['traversal_will_be_alphabetized_by_human_key'] = False
        return o

    def __build_dict_via_cels(self, far_field_names):
        import data_pipes.magnetics.dictionary_via_cels_via_definition as _
        return _(
                unsanitized_far_field_names=far_field_names,
                special_field_instructions={
                    'name': ('string_via_cel', _string_via_cel_one),
                    'parses': ('rename_to', 'grammar'),
                    'updated': ('split_to', ('updated', 'version'), _via_upda),
                    },
                string_via_cel=_string_via_cel_two,
                )

    def __open_traversal_stream(self):
        from data_pipes import common_producer_script as mod
        _ = mod.common_CLI_library().open_traversal_stream_TEMPORARY_LOCATION
        return _(
                cached_document_path=None,
                collection_identifier=self._cached_doc.cache_path,
                intention=None,
                listener=self._listener)

    def __resolve_cached_doc(self):
        from script_lib import CACHED_DOCUMENT_VIA_TWO as _
        doc = _(self._markdown_path, self.raw_url, 'markdown', self._listener)
        if doc is None:
            self._OK = False
        else:
            self._cached_doc = doc


def updated_and_version_via_string(s):  # #testpoint (sort of)
    """
    given a string that has (usually) two pieces of information in it,
    break it up into the two pieces (defaultng to None for max one of them).

    we try not to be overly sentimental re: ourobouros center-of-the-universe
    spots, but if there was one it would be the part where we try to write a
    regex to parse all the various version expressions and date strings of a
    collection of parser generators 👹

    broad provisions:
      - we never have to check for empty string or blank string.
      - which is to say there is always some "content" to parse.

    heuristically:
      - if it has a date:
        - it's always anchored to the end
        - it's always of the psuedo format ' ?MM?/YYYY$'
        - which is to say always the month, never the day.
        - a date may appear alone or it may appear after a version expression.
        - there's the separator space IFF preceding version expression.
      - if it has a version expression:
        - circa one version expression doesn't have any periods
        - circa one version expression doesn't begin with a '^v ?'
        - if you strip out the any leading '^v ?' and any interceding periods,
          all version expressions are '^[0-9a-z]+'

    corollaries of all the above:
      - it has a date IFF it contains '/'. (it will have at most one).
      - after you lop off the any date matched by above (and any separator
        space), the any remaining head-anchored content is the version
        expression
      - we may simply want to normalize
    """

    import re

    final_date = None
    final_version = None
    unsanitized_version = None

    if '/' in s:
        md = re.search(r'( )?(\d\d?)/(\d{4})$', s)
        sep_s, month, year = md.groups()
        final_date = '%s-%02d' % (year, int(month))
        if sep_s is not None:
            unsanitized_version = s[0:md.start()]
    else:
        unsanitized_version = s

    if unsanitized_version is not None:
        md = re.search('^v (.+)', unsanitized_version)
        if md is None:
            final_version = unsanitized_version
        else:
            final_version = 'v%s' % md.group(1)

    return (final_date, final_version)


_via_upda = updated_and_version_via_string


def _string_via_cel_two(some_value_string):
    return some_value_string  # #hi.


def _string_via_cel_one(human_key):
    return human_key  # #hi.


if __name__ == '__main__':

    from data_pipes.format_adapters.html.script_common import (
            common_CLI_for_json_stream_)

    _exitstatus = common_CLI_for_json_stream_(
            traversal_function=open_traversal_stream,
            doc_string=_my_doc_string,
            help_values={'raw_url': _raw_url},
            )
    exit(_exitstatus)

# #history-A.3: key simplifier found to be not covered and left broken
# #history-A.1: birth of the expression "collection meta-record"
# #history-A.1: wow rewrite half so it scrapes markdown not HTML
# #born
