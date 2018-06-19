#!/usr/bin/env python3 -W error::Warning::0

"""
generate a stream of JSON from {url}

(this is the content-producer of the producer/consumer pair)

this one is kind of triggersome 
"""


_url = 'https://github.com/webmaven/python-parsing-tools'

_first_selector = ('div', {'id': 'readme'})


def _my_CLI(listener, sin, sout, serr):

    _cm = open_dictionary_stream(None, listener)
    with _cm as lines:
        exitstatus = _html_lib().flush_JSON_stream_into(sout, serr, lines)
    return exitstatus


_my_CLI.__doc__ = __doc__


def open_dictionary_stream(html_document_path, listener):

    def my_generator(el, _emit):

        table, = el.select('table')

        from sakin_agac.format_adapters.html.magnetics import (
                dictionary_stream_via_table
                )

        table_o = dictionary_stream_via_table(
                special_field_instructions={
                    'name': ('string_via_td', _this_typical_humkey_via_td()),
                    'parses': ('rename_to', 'grammar'),
                    'updated': ('split_to', ('updated', 'version'), _via_upda),
                    },
                table=table,
                )

        field_names = table_o.field_names

        yield {
                '_is_sync_meta_data': True,
                'natural_key_field_name': field_names[0],
                'field_names': field_names,
                'traversal_will_be_alphabetized_by_human_key': False,
                }

        for dct in table_o:
            yield dct

    _cm = _html_lib().OPEN_DICTIONARY_STREAM_VIA(
        url=_url,
        first_selector=_first_selector,
        second_selector=my_generator,
        html_document_path=html_document_path,
        listener=listener,
        )

    return _cm


def _via_upda(s):
    """
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


def _this_typical_humkey_via_td():
    """

    """

    o = _html_lib()
    markdown_link_via = o.markdown_link_via
    # url_via_href = o.url_via_href_via_domain(_domain)
    # label_via_string = o.label_via_string_via_max_width(70)
    del(o)

    def f(td):
        a_tag, = td.select('> a')
        url = a_tag['href']
        # ..
        return markdown_link_via(_string_via_el(a_tag), url)

    return f


def _string_via_el(el):  # td.text() would be same, but this gives sanity
    navigable_string, = el.children
    return navigable_string.strip()


def cover_me(s):
    raise Exception('cover me: %s' % s)


def _html_lib():
    import script.json_stream_via_url_and_selector as lib
    return lib


if __name__ == '__main__':
    import sys as o
    o.path.insert(0, '')
    import script_lib as _
    _exitstatus = _.CHEAP_ARG_PARSE(
        cli_function=_my_CLI,
        std_tuple=(o.stdin, o.stdout, o.stderr, o.argv),
        help_values={'url': _url},
        )
    exit(_exitstatus)

# #born
