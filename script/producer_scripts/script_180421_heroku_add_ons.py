#!/usr/bin/env python3 -W error::Warning::0

"""generate a stream of JSON from the heroku page {url}

(this is the content-producer of the producer/consumer pair)
"""
# #[#410.1.2] this is a producer script.


_domain = 'https://devcenter.heroku.com'

_url = _domain + '/categories/add-on-documentation'

_first_selector = ('ul', {'class': 'list-icons'})

_my_doc_string = __doc__


def open_dictionary_stream(html_document_path, listener):

    def my_generator(el, _listener):

        yield {
                '_is_sync_meta_data': True,
                'natural_key_field_name': 'add_on',
                'custom_far_keyer_for_syncing': 'script.markdown_document_via_json_stream.COMMON_FAR_KEY_SIMPLIFIER_',  # noqa: E501
                'custom_near_keyer_for_syncing': 'script.markdown_document_via_json_stream.COMMON_NEAR_KEY_SIMPLIFIER_',  # noqa: E501
                'custom_mapper_for_syncing': 'script.markdown_document_via_json_stream.this_one_mapper_("add_on")',   # noqa: E501
                'far_deny_list': ('url', 'label'),  # documented @ [#418.I.3.2]
                }

        for el in el.find_all('li', recursive=False):
            a_el = el.findChild('a')
            _href = a_el['href']
            _label = a_el.text
            yield {'url': _domain + _href, 'label': _label}

    _cm = _lib().OPEN_DICTIONARY_STREAM_VIA(
        url=_url,
        first_selector=_first_selector,
        second_selector=my_generator,
        html_document_path=html_document_path,
        listener=listener)
    return _cm


def _lib():
    import data_pipes.format_adapters.html.script_common as lib
    return lib


if __name__ == '__main__':
    common_CLI_for_json_stream_ = _lib().common_CLI_for_json_stream_
    _exitstatus = common_CLI_for_json_stream_(
            traversal_function=open_dictionary_stream,
            doc_string=_my_doc_string,
            help_values={'url': _url},
            )
    exit(_exitstatus)

# #history-A.1: gets coverage, reverts to "raw" style of output
# #born
