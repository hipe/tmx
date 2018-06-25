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
"""


_raw_url = (
        'https://raw.githubusercontent.com'
        '/webmaven/python-parsing-tools/master/README.md'
        )


def _my_CLI(listener, sin, sout, serr):

    _cm = open_dictionary_stream(None, listener)
    with _cm as lines:
        exitstatus = _top_html_lib().flush_JSON_stream_into(sout, serr, lines)
    return exitstatus


_my_CLI.__doc__ = __doc__


class open_dictionary_stream:  # #[#410.F]

    def __init__(self, markdown_path, listener):
        self.raw_url = _raw_url
        self._markdown_path = markdown_path
        self.__init_emitter(listener)
        self._listener = listener

    def __enter__(self):
        self._OK = True
        self._OK and self.__resolve_cached_doc()
        if not self._OK:
            return
        with self.__unsanitized_dictionaries() as dcts:
            schema_record = next(dcts)  # ..
            far_field_names = tuple(schema_record['field_names'])
            dic_via_cels = self.__build_dict_via_cels(far_field_names)

            yield self.__meta_record_via(dic_via_cels, schema_record)

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

          - assume #provision [#410.Q] that the natural key field name
            is leftmost (here in the near field names (which are derived))

        #abstraction-candidate: the format adaptation of [#410.J] the record
        mapper should probably be the one doing this (maybe?)
        """

        near_field_names = dic_via_cels.near_field_names
        mutable_dict = {k: v for k, v in schema_record.items()}
        mutable_dict['natural_key_field_name'] = near_field_names[0]  # YIKES
        mutable_dict['field_names'] = near_field_names
        return mutable_dict

    def __build_dict_via_cels(self, far_field_names):
        import sakin_agac.magnetics.dictionary_via_cels_via_definition as _
        return _(
                unsanitized_far_field_names=far_field_names,
                special_field_instructions={
                    'name': ('string_via_cel', _string_via_cel_one),
                    'parses': ('rename_to', 'grammar'),
                    'updated': ('split_to', ('updated', 'version'), _via_upda),
                    },
                string_via_cel=_string_via_cel_two,
                )

    def __unsanitized_dictionaries(self):
        from script.stream import open_dictionary_stream as dicts_via
        return dicts_via(self._cached_doc.cache_path, self._listener)

    def __resolve_cached_doc(self):
        markdown_path = self._markdown_path
        from sakin_agac.format_adapters.html.magnetics import (
                cached_doc_via_url_via_temporary_directory as cachelib,
                )
        if markdown_path is None:
            from script_lib import TEMPORARY_DIR
            _cached_doc_via = cachelib(TEMPORARY_DIR)
            self._cached_doc = _cached_doc_via(self.raw_url, self._emit)
        else:
            _tmpl = '(reading markdown from filesystem - {})'
            self._emit(
                    'info', 'expression', 'reading_from_filesystem',
                    _tmpl, markdown_path)
            self._cached_doc = cachelib.Cached_HTTP_Document(markdown_path)
        if self._cached_doc is None:
            self._OK = False

    def __init_emitter(self, listener):
        from modality_agnostic import listening
        self._emit = listening.emitter_via_listener(listener)


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


def _top_html_lib():
    import script.json_stream_via_url_and_selector as lib
    return lib


if __name__ == '__main__':
    import sys as o
    o.path.insert(0, '')
    import script_lib as _
    _exitstatus = _.CHEAP_ARG_PARSE(
        cli_function=_my_CLI,
        std_tuple=(o.stdin, o.stdout, o.stderr, o.argv),
        help_values={'raw_url': _raw_url},
        )
    exit(_exitstatus)

# #history-A.1: birth of the expression "collection meta-record"
# #history-A.1: wow rewrite half so it scrapes markdown not HTML
# #born
