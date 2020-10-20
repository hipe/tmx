# == Emissions Testing (simple)

def listener_and_done_via(expected_emissions, tc=None):
    recvrs = []
    if tc:
        recvrs.append(_emission_receiver_for_debugging(tc))
    recv_emi, done = _expectation_stack(expected_emissions, tc)
    recvrs.append(recv_emi)
    listener = _listener_via_receivers(recvrs)
    return listener, done


def listener_and_emissions_for(tc, limit=None):
    emissions, recvrs = [], []
    if tc:
        recvrs.append(_emission_receiver_for_debugging(tc))
    if limit is not None:
        recvrs.append(_emission_receiver_via_limit(limit, tc))
    recvrs.append(emissions.append)
    listener = _listener_via_receivers(recvrs)
    return listener, emissions


def _emission_receiver_via_limit(limit, tc=None):
    def expected_emissions():
        for _ in range(0, limit):
            yield ('?+',)  # match any channel (assert that channel >= 1 cmp)
    assert(-1 < limit and limit < 4)  # just sanity check based on real world
    recv_emi, _ = _expectation_stack(expected_emissions(), tc)
    return recv_emi


def _build_expectation_stack_function():  # :[#509]

    def build_expectation_stack(expected_emissions, tc=None):

        stack = list(reversed(tuple(expected_emissions)))
        orig_stack_height = len(stack)

        def receive_emission(emi):
            if not len(stack):
                msg = repr(emi.to_debugging_tuple_())
                fail(''.join((f'expecting no{more()} emissions, had: ', msg)))
            chan_exp_typ, exp_chan, store_as_name = parse_expect(stack.pop())
            if 'channel_head' == chan_exp_typ:
                tc.assertSequenceEqual(emi.channel[0:len(exp_chan)], exp_chan)
                tc.assertLess(len(exp_chan), len(emi.channel))  # because ?+
            else:
                assert('exact_match_entire_channel' == chan_exp_typ)
                tc.assertSequenceEqual(emi.channel, exp_chan)
            if not store_as_name:
                return
            assert(store_as_name not in stored)
            stored[store_as_name] = emi

        def more():
            return ' more' if orig_stack_height else ' more'

        def done():
            if len(stack):
                moniker = repr(stack[-1])
                xx(f"was expecting such an emission next: {moniker}")
            return stored

        stored = {}

        def fail(msg):
            if tc:
                tc.fail(msg)
            raise RuntimeError(msg)

        return receive_emission, done

    def parse_expect(horizontal_tuple):
        channel_expectation_type = None
        expected_channel = []
        store_as_name = None
        horizontal_stack = list(reversed(horizontal_tuple))
        while len(horizontal_stack):
            token = horizontal_stack.pop()
            if token not in keywords:
                expected_channel.append(token)
                continue
            if '?+' == token:
                channel_expectation_type = 'channel_head'
                if not len(horizontal_stack):
                    break
                token = horizontal_stack.pop()
            assert('as' == token)
            store_as_name = horizontal_stack.pop()
            assert not len(horizontal_stack)
            break
        if channel_expectation_type is None:
            channel_expectation_type = 'exact_match_entire_channel'
        return channel_expectation_type, tuple(expected_channel), store_as_name

    keywords = {'?+', 'as'}
    return build_expectation_stack


_expectation_stack = _build_expectation_stack_function()


def listener_via_receive_channel_and_payloader(receive_channel_and_payloader):
    def receive_emission(emi):
        receive_channel_and_payloader(emi.channel, emi.payloader)
    return _listener_via_receivers((receive_emission,))


def _emission_receiver_for_debugging(tc):
    def receive_emission(emi):
        if not tc.do_debug:
            return

        # BEGIN super hacky: break out of in-progress unittest txt block if nec
        if hasattr((cls := tc.__class__), '_MA_DEBUG_EMI_'):
            nl = ''
        else:
            setattr(cls, '_MA_DEBUG_EMI_', None)
            nl = '\n'
        # END
        _echo_emi_for_debugging(stderr, emi, nl)
    tc.do_debug  # fail early if this isn't implemented
    from sys import stderr
    return receive_emission


def debugging_listener():
    def receive_emission(emi):
        _echo_emi_for_debugging(stderr, emi)
    from sys import stderr
    return _listener_via_receivers((receive_emission,))


def _echo_emi_for_debugging(stderr, emi, nl='\n'):
    pcs = (nl, 'DEBUG EMI: ', repr(emi.to_debugging_tuple_()), '\n')
    stderr.write(''.join(pcs))


def throwing_listener(sev, *rest):
    if sev not in ('error', 'fatal'):
        return
    from modality_agnostic import throwing_listener
    throwing_listener(sev, *rest)


def _listener_via_receivers(emission_receivers):
    def listener(*emission):
        emi = emi_via(emission)
        for receive_emission in emission_receivers:
            receive_emission(emi)
    from modality_agnostic import emission_via_tuple as emi_via
    return listener


# == Memoizers

def dangerous_memoize_in_child_classes(orig_f):
    # #open [#507.6] integrate this with teardown so the memory is reclaimed
    # :[#507.10] this is the central, shared memoizer for child classes

    k = orig_f.__name__

    def use_f(tc):
        o = tc.__class__
        if not hasattr(o, '_modality_agnostic_memoization_'):
            setattr(o, '_modality_agnostic_memoization_', {})
        memo = o._modality_agnostic_memoization_
        if k not in memo:
            memo[k] = orig_f(tc)
        return memo[k]
    return use_f


def memoize_into(attr):
    def decorator(f):
        def use_f(self):
            if not hasattr(self, attr):
                setattr(self, attr, f(self))
            return getattr(self, attr)
        return use_f
    return decorator


def dangerous_memoize(orig_f):  # #decorator
    # we want to implement this with a class like we do elsewhere for some
    # [#510.6] custom memoizy decorators, bu it breaks weirdly like at
    # [#510.7.2] (grep dump test)

    def use_f(self_maybe_ignored):
        if state.is_first_call:
            state.is_first_call = False
            state.memoized_value = orig_f(self_maybe_ignored)
        return state.memoized_value

    class state:  # #class-as-namespace
        is_first_call = True

    return property(use_f)  # wrapped as property because of how it's used


def lazify_method_safely(build_value):  # 1x
    def use_method(ignore_invocation_context):
        return valuer()
    valuer = lazy(build_value)
    return use_method


class lazy:  # #[#510.8]

    def __init__(self, f):
        self._function = f
        self._is_first_call = True

    def __call__(self):
        if self._is_first_call:
            self._is_first_call = False
            f = self._function
            del self._function
            self._value = f()
        return self._value


class Counter:  # #[#510.13]
    def __init__(self):
        self.value = 0

    def increment(self):
        self.value += 1


def xx(msg=None):
    use_msg = ''.join(('cover me/write me', *((': ', msg) if msg else ())))
    raise RuntimeError(use_msg)

# #history-B.1: absorb two emission testing modules
# #history-A.6: get rid of all nonlocal
# #history-A.5: experimental memoizing into a class attribute
# #history-A.4: fun bit of trivia, things were even uglier before nonlocal
# #history-A.3: a memoizer method moved here from elsewhere
# #history-A.2: a memoizer method moved here from elsewhere
# #history-A.1: a memoizer method moved here from elsewhere
