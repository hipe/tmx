import re


def one_and_none(run, tc):
    listener, emissioner = listener_and_emissioner_for(tc)
    _x = run(listener)
    tc.assertIsNone(_x)
    chan, payloader = emissioner()
    return chan, payloader


def listener_and_emissioner_for(tc):

    two = None

    def recv(chan, payloader):
        nonlocal two
        two = chan, payloader

    listener, ran = one_and_done(recv, tc)

    def emissioner():
        ran()
        return two

    return listener, emissioner


def one_and_done(recv, tc):

    did = False

    def listener(*a):
        *chan, payloader = a

        nonlocal did
        if did:
            tc.fail('more than one emission')
        did = True

        recv(tuple(chan), payloader)

    def ran():
        if did:
            return
        tc.fail('expected one emission, had none')

    return listener, ran


def unindent(big_string):

    if '' == big_string:
        return  # (Case407_120)

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
