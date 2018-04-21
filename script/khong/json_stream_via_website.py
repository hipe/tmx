#!/usr/bin/env python3 -W error::Warning::0

"""generate a stream of JSON from the TOC Dr. K Hong's excellent {domain}

(this is the content-producer of the producer/consumer pair)
"""


_domain = 'http://www.bogotobogo.com'
domain = _domain  # expose it
_url = _domain + '/python/pytut.php'  # ..
_first_selector = (None, 'side_menu')


def _my_CLI(listener, sin, sout, serr):
    itr = procure_object_stream(listener)
    if itr is None:
        return 5
    else:
        import script.json_stream_via_url_and_selector as o
        return o.flush_JSON_stream_into(sout, serr, itr)


_my_CLI.__doc__ = __doc__


def procure_object_stream(listener):

    import script.json_stream_via_url_and_selector as o

    def hello(these):
        for el in these[0].find_all('a'):
            yield {'href': el['href'], 'text': el.text}

    _itr = o.EXPERIMENT(
        url=_url,
        first_selector=_first_selector,
        second_selector=hello,
        listener=listener,
        )

    return _itr


if __name__ == '__main__':
    import sys as o
    o.path.insert(0, '')
    import script_lib as sl
    _exitstatus = sl.CHEAP_ARG_PARSE(
        cli_function=_my_CLI,
        std_tuple=(o.stdin, o.stdout, o.stderr, o.argv),
        help_values={'domain': _domain},
        )
    exit(_exitstatus)

# #born: abstracted from sibling
