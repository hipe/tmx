"""
Lightweight listening testing library.
(Compare heavier-weight counterpart: [#509].)
"""
# :[508]
# (keeping track of clients for now: kiss_rdb_test)


def expect(tc, expect_channel):  # EXPERIMENTAL name for 1 line
    return ExpectEmission(tc, expect_channel=expect_channel)


def one_and_none(tc, run):
    ee = ExpectEmission(tc)
    result_value = run(ee.listener)
    tc.assertIsNone(result_value)
    ee.ran()
    return ee.channel, ee.payloader


def listener_and_emission_objecter_for(tc):
    listener, emissioner = listener_and_emissioner_for(tc)

    def emission_objecter():
        chan, payloader = emissioner()
        from .listener_via_expectations import ActualEmission_
        return ActualEmission_((*chan, payloader))
    return listener, emission_objecter


def listener_and_emissioner_for(tc):
    def emissioner():
        ee.ran()
        return ee.channel, ee.payloader
    ee = ExpectEmission(tc)
    return ee.listener, emissioner


def channel_and_payloader_and_result_via_run(tc, run):
    ee = ExpectEmission(tc)
    result_value = run(ee.listener)
    ee.ran_and_zero_emissions_is_OK()
    return ee.channel, ee.payloader, result_value


def one_and_done(tc, recv):  # 1x
    ee = ExpectEmission(tc, receive_emission=recv)
    return ee.listener, ee.ran


def minimal_listener_spy():
    """similar elsewhere. this one is minimal. DEPRECATED:

    .#history-A.2: even the below may be deprecated. moved here from elsewhere
    .#open [#507.C] the soul of this has been stolen and moved to [#509.2]
    """

    def listener(*a):
        severity, shape, *ignore, payloader = a
        assert('error' == severity)
        assert('expression' == shape)
        for line in payloader():
            mutable_message_array.append(line)
    mutable_message_array = []
    return (mutable_message_array, listener)


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

        self.channel = None
        self.payloader = None

        self.listener = listener
        self.ran = ran

    def ran_and_zero_emissions_is_OK(self):
        del self._mutex


def debugging_listener():
    from .listener_via_expectations import for_DEBUGGING
    return for_DEBUGGING


# #history-A.2
# #history-A.1: move state stuff into a class
# #abstracted.
