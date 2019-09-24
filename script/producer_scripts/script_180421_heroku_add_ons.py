#!/usr/bin/env python3 -W error::Warning::0

"""generate a stream of JSON from the heroku page:
{url}

(this is the content-producer of the producer/consumer pair)
"""
# This producer script is covered by (Case2013DP).


_domain = 'https://devcenter.heroku.com'

_url = _domain + '/categories/add-on-documentation'

_first_selector = ('ul', {'class': 'list-icons'})

_my_doc_string = __doc__


def _my_CLI(error_monitor, sin, sout, serr, is_for_sync):
    with open_traversal_stream(error_monitor.listener) as dcts:
        if is_for_sync:
            dcts = stream_for_sync_via_stream(dcts)
        _ps_lib().flush_JSON_stream_into(sout, serr, dcts)
    return 0 if error_monitor.OK else 456


_my_CLI.__doc__ = _my_doc_string


stream_for_sync_is_alphabetized_by_key_for_sync = True


def stream_for_sync_via_stream(dcts):
    lib = _ps_lib()
    markdown_link_via = lib.the_function_called_markdown_link_via()
    normal_via_str = lib.the_function_called_normal_field_name_via_string()
    simple_via_normal = lib.the_function_called_simple_key_via_normal_key()
    for dct in dcts:
        _ = normal_via_str(dct['label'])
        _key_for_sync = simple_via_normal(_)
        _markdown_link = markdown_link_via(dct['label'], dct['url'])
        yield (_key_for_sync, {'add_on': _markdown_link})


def open_traversal_stream(listener, html_document_path=None):
    def my_generator(el, _listener):
        for el in el.find_all('li', recursive=False):
            a_el = el.findChild('a')
            _href = a_el['href']
            _label = a_el.text
            yield {'url': _domain + _href, 'label': _label}
    return _ps_lib().open_dictionary_stream_via(
        url=_url,
        first_selector=_first_selector,
        second_selector=my_generator,
        html_document_path=html_document_path,
        listener=listener)


def _ps_lib():
    import data_pipes.format_adapters.html.script_common as lib
    return lib


if __name__ == '__main__':
    import sys as o
    from script_lib.magnetics.argument_parser_index_via_stderr_and_command_stream import (  # noqa: E501
            cheap_arg_parse)
    exit(cheap_arg_parse(
            CLI_function=_my_CLI,
            stdin=o.stdin, stdout=o.stdout, stderr=o.stderr, argv=o.argv,
            formal_parameters=(
                ('-s', '--for-sync',
                 'translate to a stream suitable for use in [#447] syncing'),),
            description_template_valueser=lambda: {'url': _url}))

# #history-A.1: gets coverage, reverts to "raw" style of output
# #born
