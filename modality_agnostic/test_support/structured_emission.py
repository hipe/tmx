# (keeping track of clients for now: kiss_rdb_test)


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


def debugging_listener():
    from modality_agnostic.test_support import (
            listener_via_expectations as _,
            )
    return _.for_DEBUGGING

# #abstracted.
