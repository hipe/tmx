import re


def unindent(big_string):

    s = big_string

    md = _the_first_run_of_whitespace_rx.match(s)

    margin = md[2]

    margin_rx = re.compile(margin)  # yikes

    length = len(s)
    cursor = md.end(1)

    while True:
        # advance over the margin
        md = margin_rx.match(s, cursor)
        if md is not None:
            # if it didn't match then there's blank line
            cursor = md.end()
        if length == cursor:
            break
        md = _line_rx.match(s, cursor)
        yield md[1]
        cursor = md.end()


_the_first_run_of_whitespace_rx = re.compile(r'^(\n)([ ]+)')
_line_rx = re.compile('([^\n]*\n)')


def debugging_listener():
    from modality_agnostic.test_support import (
            listener_via_expectations as _,
            )
    return _.for_DEBUGGING

# #abstracted.
