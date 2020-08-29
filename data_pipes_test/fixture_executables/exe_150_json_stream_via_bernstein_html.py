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
of the [#459.E] record mapper; a something that seems useful to have in the
toolkit..
"""

_url = 'https://github.com/webmaven/python-parsing-tools'

_first_selector = ('div', {'id': 'readme'})


# == BEGIN LIB

def exit_code_via_path(producer_script_path):
    # (NOTE this is called from sakin_agac_test at writing #history-A.2)
    _ps = __producer_script_via_producer_script_path(producer_script_path)
    return _exit_code_via_producer_script(_ps)


def __producer_script_via_producer_script_path(producer_script_path):
    # hard-coded depth of 3. ick/meh
    import re
    md = re.search(r'(?:^|/)([^/]+/[^/]+/[^/.]+)\.py$', producer_script_path)
    _module_name = '.'.join(md[1].split('/'))
    from importlib import import_module
    return import_module(_module_name)


def _exit_code_via_producer_script(ps):
    _my_CLI = __CLI_function_via_producer_script(ps)
    from script_lib.cheap_arg_parse import cheap_arg_parse
    import sys as o
    return cheap_arg_parse(
        CLI_function=_my_CLI,
        stdin=o.stdin, stdout=o.stdout, stderr=o.stderr, argv=o.argv,
        formal_parameters=(
            ('-s', '--for-sync', 'show the traveral stream mapped thru etc'),
            ),
        description_template_valueser=lambda: {'url': _url},
        )


def __CLI_function_via_producer_script(ps):
    open_trav_stream = ps.open_traversal_stream
    stream_via_stream = ps.stream_for_sync_via_stream
    doc = ps.__doc__
    del ps

    def my_CLI(error_monitor, sin, sout, serr, is_for_sync):

        opened = open_trav_stream(error_monitor.listener)

        with opened as dcts:
            if is_for_sync:
                use_this_stream = stream_via_stream(dcts)
            else:
                use_this_stream = dcts
            _top_html_lib().flush_JSON_stream_into(sout, serr, use_this_stream)

        if error_monitor.OK:
            return 0
        return 456

    my_CLI.__doc__ = doc
    return my_CLI

# == END


stream_for_sync_is_alphabetized_by_key_for_sync = False


def stream_for_sync_via_stream(dcts):  # #copy-pasted from prod #history-A.1
    from kiss_rdb.storage_adapters.markdown import \
            simplified_key_via_markdown_link_er
    key_via = simplified_key_via_markdown_link_er()

    for dct in dcts:
        yield (key_via(dct['name']),  dct)


def open_traversal_stream(listener, html_document_path=None):

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

        for dct in table_o:
            yield dct

    _cm = _top_html_lib().open_dictionary_stream_via(
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

    from kiss_rdb.storage_adapters.markdown import markdown_link_via

    return f


def _string_via_el(el):  # td.text() would be same, but this gives sanity
    navigable_string, = el.children
    return navigable_string.strip()


def _filter(sel, el):
    import soupsieve as sv
    return sv.filter(sel, el)


def _top_html_lib():
    import data_pipes.format_adapters.html.script_common as lib
    return lib


if __name__ == '__main__':
    import sys
    _me_as_module = sys.modules[__name__]
    exit(_exit_code_via_producer_script(_me_as_module))

# #history-A.2
# #history-A.1
# #DNA-fissure
