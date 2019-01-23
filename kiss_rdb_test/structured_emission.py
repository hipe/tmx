def unindent(big_string):
    import re

    s = big_string

    md = re.match(r'^(\n)([ ]+)', s)
    margin = md[2]

    margin_rx = re.compile(margin)  # yikes
    line_rx = re.compile('([^\n]*\n)')

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
        md = line_rx.match(s, cursor)
        yield md[1]
        cursor = md.end()


def debugging_listener():
    from modality_agnostic.test_support import (
            listener_via_expectations as _,
            )
    return _

# #abstracted.
