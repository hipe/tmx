#!/usr/bin/env python3 -W error::Warning::0

"""
generate a markdown table from the table of contents (TOC) of a web page.

    - this can assist in detecting *some* changes to the constituency
      of the lessons: if you save the output of this one-off in version
      control and run the one-off again at a later date, you can see what
      (if any) items have been added, removed, re-ordered etc since the
      last time you looked.

    - consider the structure of the markdown table totally experimental.

this started life as a one-off. now it serves as an experimetal pioneer
of a guy that uses the content producer/consumer model.

"""


"""
also:
    - this file is sparse now because of the spliter
"""


def _my_CLI(listener, sin, sout, serr):

    import script.khong.json_stream_via_website as js_v_w

    itr = js_v_w.procure_object_stream(listener)
    if itr is None:
        return 5
    else:
        return _work(sout, itr, listener)


_my_CLI.__doc__ = __doc__


def _work(sout, itr, listener):

    import script.khong.markdown_via_json_stream as m_v_js
    import script_lib as sl

    _ = m_v_js.flush_markdown_into_via_object_stream(sout, itr, listener)
    info = sl.leveler_via_listener('info', listener)
    info('emitted {} row-items, {} bytes', *_)
    return 0


if __name__ == '__main__':
    import sys as o
    o.path.insert(0, '')
    import script_lib as sl
    _exitstatus = sl.CHEAP_ARG_PARSE(
        cli_function=_my_CLI,
        std_tuple=(o.stdin, o.stdout, o.stderr, o.argv),
        )
    exit(_exitstatus)

# #history-A.1: splinter: separate content consumer from content producer
# #born.
