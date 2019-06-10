# (keeping track of clients for now: kiss_rdb_test)


def expect(tc, expect_channel):  # EXPERIMENTAL name for 1 line
    return ExpectEmission(tc, expect_channel=expect_channel)


def one_and_none(run, tc):
    ee = ExpectEmission(tc)
    result_value = run(ee.listener)
    tc.assertIsNone(result_value)
    ee.ran()
    return ee.channel, ee.payloader


def listener_and_emissioner_for(tc):
    def emissioner():
        ee.ran()
        return ee.channel, ee.payloader
    ee = ExpectEmission(tc)
    return ee.listener, emissioner


def one_and_done(recv, tc):
    ee = ExpectEmission(tc, receive_emission=recv)
    return ee.listener, ee.ran


class ExpectEmission:

    def __init__(
            self,
            text_context,
            expect_channel=None,
            receive_emission=None,
            ):

        tc = text_context

        # -- the listener receives every emission and ..

        self._emission_count = 0

        def listener(*a):
            if 0 != self._emission_count:
                tc.fail('more than one emission')
            self._emission_count += 1
            *chan, payloader = a
            receive_emission(tuple(chan), payloader)

        # -- every emission we receive goes ..

        if expect_channel is None:
            if receive_emission is None:

                def receive_emission(chan, payloader):
                    self.channel = chan
                    self.payloader = payloader

        elif receive_emission is None:

            def receive_emission(chan, payloader):
                tc.assertSequenceEqual(chan, expect_channel)
                self.payloader = payloader

        else:
            raise Exception("can't have both")

        # -- we must know when we are done running, to assert hardcoded min

        self._mutex = None

        def ran():
            del self._mutex
            if 1 != self._emission_count:
                tc.fail('expected one emission, had none')

        # --

        self.listener = listener
        self.ran = ran


def debugging_listener():
    from modality_agnostic.test_support import (
            listener_via_expectations as _,
            )
    return _.for_DEBUGGING


# #history-A.1: move state stuff into a class
# #abstracted.
