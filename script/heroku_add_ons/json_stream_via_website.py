#!/usr/bin/env python3 -W error::Warning::0

"""generate a stream of JSON from the heroku page {url}

(this is the content-producer of the producer/consumer pair)
"""

_url = 'https://devcenter.heroku.com/categories/add-on-documentation'

_first_selector = ('ul', {'class': 'list-icons'})


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

    def my_generator(these):
        for el in these[0].find_all('li', recursive=False):
            a_el = el.findChild('a')
            yield {'href': a_el['href'], 'label': a_el.text}

    _itr = o.EXPERIMENT(
        url=_url,
        first_selector=_first_selector,
        second_selector=my_generator,
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
        help_values={'url': _url},
        )
    exit(_exitstatus)

# #born
