#!/usr/bin/env python3 -W error::Warning::0

"""
generate a stream of JSON from {url}

(this is the content-producer of the producer/consumer pair)
"""


"""
origin story:

when we were just about finished writing this it occurred to us how cludgy
it was that we were scraping HTML to in effect generate markdown from content
that "started" as markdown in the first place.

(at a high level this works fine, but when it comes to trying to do
.#html2markdown on links it starts to feel kind of silly.)

but A) by the time we realized this the script was done and covered and
B) this script is the only guy that gives coverage to the html adaptation
of the [#410.J] record mapper; a something that seems useful to have in the
toolkit..
"""

_url = 'https://github.com/webmaven/python-parsing-tools'

_first_selector = ('div', {'id': 'readme'})


def _my_CLI(error_monitor, sin, sout, serr, _SOON):
    _cm = open_traversal_stream(None, error_monitor.listener)
    with _cm as lines:
        _top_html_lib().flush_JSON_stream_into(sout, serr, lines)
    return 0 if error_monitor.ok else 456


_my_CLI.__doc__ = __doc__


def open_traversal_stream(html_document_path, listener):

    def my_generator(el, _emit):

        table, = el.select('table')

        from data_pipes.format_adapters.html.magnetics import (
                dictionary_stream_via_table)

        table_o = dictionary_stream_via_table(
                special_field_instructions={
                    'name': ('string_via_cel', _this_typical_humkey_via_td()),
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

    _cm = _top_html_lib().OPEN_DICTIONARY_STREAM_VIA(
        url=_url,
        first_selector=_first_selector,
        second_selector=my_generator,
        html_document_path=html_document_path,
        listener=listener)

    return _cm


class _Memoized:

    def __init__(self):
        self._is_first_call = True

    def via_update(self, s):
        if self._is_first_call:
            self._is_first_call = False
            from script.producer_scripts import (
                script_180618_22_parser_generators_via_bernstein as mod)
            self._function = mod.updated_and_version_via_string
        return self._function(s)


_via_upda = _Memoized().via_update


def _this_typical_humkey_via_td():
    def f(td):
        a_tag, = _filter('a', td)
        url = a_tag['href']
        # ..
        return markdown_link_via(_string_via_el(a_tag), url)
    markdown_link_via = _md_lib().markdown_link_via
    return f


def _string_via_el(el):  # td.text() would be same, but this gives sanity
    navigable_string, = el.children
    return navigable_string.strip()


def _filter(sel, el):
    import soupsieve as sv
    return sv.filter(sel, el)


def _md_lib():
    from data_pipes import common_producer_script as mod
    return mod.LEGACY_markdown_lib()


def execute_as_CLI_(open_dictionary_stream):
    """
    this is the implementation of :[#410.H]
    """

    flush_into = _top_html_lib().flush_JSON_stream_into
    import sys as o
    with open_dictionary_stream(None, None) as dcts:
        flush_into(o.stdout, o.stderr, dcts)
    return 0


def _top_html_lib():
    import data_pipes.format_adapters.html.script_common as lib
    return lib


if __name__ == '__main__':
    from script_lib.magnetics.argument_parser_index_via_stderr_and_command_stream import (  # noqa: E501
            CHEAP_ARG_PARSE)
    import sys as o
    _exitstatus = CHEAP_ARG_PARSE(
        cli_function=_my_CLI,
        stdin=o.stdin, stdout=o.stdout, stderr=o.stderr, argv=o.argv,
        formal_parameters=(
            ('-s', '--for-sync', 'COMING SOON'),
            ),
        description_template_valueser=lambda: {'url': _url},
        )
    exit(_exitstatus)

# #DNA-fissure
