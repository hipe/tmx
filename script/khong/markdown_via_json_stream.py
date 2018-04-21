#!/usr/bin/env python3 -W error::Warning::0

"""produce the markdown (custom format) for Dr. K Hong's excellent thing

(this is the content-consumer of the producer/consumer pair)
"""


def _my_CLI(listener, sin, sout, serr):
    import script_lib as sl
    if sin.isatty():
        o = sl.leveler_via_listener('error', listener)
        o('currently, non-interactive from STDIN only')
        o('e.g: blab_blah | {}', _PROGRAM_NAME)
        return 5
    else:
        info = sl.leveler_via_listener('info', listener)
        import json

        def f():
            for line in sin:
                _hsh = json.loads(line)
                yield _hsh
        n1, n2 = flush_markdown_into_via_object_stream(sout, f(), listener)
        info('emitted {} row-items, {} bytes', n1, n2)
        return 0


_my_CLI.__doc__ = __doc__


def flush_markdown_into_via_object_stream(sout, itr, listener):
    """result in number of bytes written"""

    import script_lib as sl

    from json_stream_via_website import domain

    o = sl.putser_via_IO(sout)

    o('| Lesson | Read | Emoji | Notes |')
    o('|----|:---|:---|---:|')

    byts = 0
    items = 0
    for hsh in itr:
        items += 1
        url = hsh['href']
        name = hsh['text']
        # for probably one particular erroneous guy
        _escaped_url = url.replace(' ', '%20')
        _long_url = domain + _escaped_url
        _use_name = __markdownify_name(name)
        byts += o('|[{}]({})|◻️|◻️||'.format(_use_name, _long_url))

    return (items, byts)


def __markdownify_name(name):
    if _max_name_width < len(name):
        short_name = name[:(_max_name_width-3)] + '...'
    else:
        short_name = name
    _ = short_name.replace('*', '\\*')
    _ = _.replace('_', '\\_')
    return _


_max_name_width = 70


if __name__ == '__main__':
    import sys as o
    o.path.insert(0, '')
    import script_lib as sl
    _PROGRAM_NAME = o.argv[0]  # ick/meh
    _exitstatus = sl.CHEAP_ARG_PARSE(
        cli_function=_my_CLI,
        std_tuple=(o.stdin, o.stdout, o.stderr, o.argv),
        )
    exit(_exitstatus)


# #born: abstracted from sibling
