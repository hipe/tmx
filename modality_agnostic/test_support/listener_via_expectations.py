"""ahem..

:[#509]
"""

from modality_agnostic import cover_me
from modality_agnostic_test.common_initial_state import (
        MutexingReference)
import re
from collections import deque as deque


# --

def for_DEBUGGING(*a):

    *chan, emit = a
    shape = chan[1]

    from sys import stderr as io

    io.write(f'channel: {repr(chan)}\n')
    io.flush()

    if 'message' == shape:
        if 0 != _num_params(emit):
            raise Exception('«no expression agent yet»')  # near #open [#508]
        _s_a = tuple(emit())
        io.write(f'messages: {repr(_s_a)}')
    elif 'structure' == shape:
        io.write(f'meta-doh-dah: {repr(emit())}')
    else:
        raise Exception(f'strange shape: {repr(shape)}')

    io.write('\n')
    io.flush()


def listener_via_emission_receiver(receive_emission):  # :[#509.2]
    def listener(*a):
        stack = list(a)
        receive_emission(_ActualEmission(stack.pop(), tuple(stack)))
    return listener

# -- (☝️ don't forget to also put these #here)


class _EmissionsModel:

    def __init__(self, itr):
        _a = [_EmissionModel(s_a) for s_a in itr]
        self._emission_models = deque(_a)
        self._actual_emissions = []
        self._offset_via_name = {}

    def listener(self, *chan):
        """NOTE - you won't typically call this directly"""

        chan = list(chan)
        emission_payload_expresser = chan.pop()
        ae = _ActualEmission(emission_payload_expresser, tuple(chan))
        if self._some_emission_models_remain():
            self.__when_expecting_emission(ae)
        else:
            cover_me("unexpected emission - {}".format(repr(chan)))

    def __when_expecting_emission(self, actual_emission):

        emission_model = self._emission_models.popleft()
        emission_model.assert_against(actual_emission)

        d = self._offset_via_name
        a = self._actual_emissions

        name = emission_model.name
        offset = len(a)

        a.append(actual_emission)
        if name is not None:
            if name in d:
                _ = 'name collsion - multiple emission models named {}'.format(
                        name)
                cover_me(_)
            d[name] = offset

    def actual_emission_index_via_finish(self):
        if self._some_emission_models_remain():
            self.__when_some_emission_models_remain()
        del(self._emission_models)  # sanity

        _tup = tuple(self._actual_emissions)
        _dict = self._offset_via_name

        return _ActualEmissionIndex(_dict, _tup)

    def __when_some_emission_models_remain(self):
        _ = self._emission_models[0].channel
        _ = 'finished receiving emissions when expecting {}'.format(repr(_))
        cover_me(_)

    def _some_emission_models_remain(self):
        return 0 != len(self._emission_models)

    # :#here:
    listener_via_emission_receiver = listener_via_emission_receiver
    for_DEBUGGING = for_DEBUGGING


class _ActualEmissionIndex:

    def __init__(self, d, tup):
        self._offset_via_name = d
        self.actual_emissions = tup

    def actual_emission_via_name(self, name):
        _offset = self._offset_via_name[name]
        return self.actual_emissions[_offset]


class _ActualEmission:

    def __init__(self, emission_payload_function, chan):
        self.emission_payload_function = emission_payload_function
        self.channel = chan

    def to_first_string(self):  # #[#508] assumes simple new way strictly
        result = None
        for line in self.emission_payload_function():
            result = line
            break
        return result

    def to_string(self):
        return '\n'.join(self.to_strings())

    def to_strings(self):
        """NOTE:

        for one thing, this has been done elsewhere
        for another thing, this totally ignores expression agents
        for a third thing, this work isn't memoized here.

        finally, #open #[#508]: transitional solution (redundant)
        """

        msgs = []
        user_f = self.emission_payload_function
        length = _num_params(user_f)
        if 0 == length:
            for line in user_f():
                msgs.append(line)
        else:
            # (deprecated but still widespread emission signature at writing)
            def receive_nonterminated_message_string(message):
                msgs.append(message)
            if 1 == length:
                user_f(receive_nonterminated_message_string)
            elif 2 == length:
                user_f(receive_nonterminated_message_string, 'no expag [ma]')
            else:
                raise TypeError('no')

        return msgs


class _EmissionModel:

    def __init__(self, s_a):
        channel_model, name = _crazy_parse(s_a)
        self.channel_model = channel_model
        self.name = name

    def assert_against(self, actual_emission):
        model_deq = deque(self.channel_model)
        actual_deq = deque(actual_emission.channel)
        while True:
            if 0 == len(model_deq):
                if 0 == len(actual_deq):
                    break  # if no more in either, you win
                else:
                    cover_me('extra actual past end of literal model')
            else:
                head = model_deq[0]
                if 0 == len(actual_deq):
                    head.finish()
                    break
                else:
                    head.assert_against(actual_deq.popleft())
                    if head.does_get_consumed:
                        model_deq.popleft()


def _crazy_parse(s_a):

    channel_model = []

    self = _ParseState()

    def receive_token_initially(s):
        if 'as' == s:
            move(parse_as)
            self.receive_token(s)
        elif _name_rx.search(s) is None:
            move(parse_wildcard_globs_or_as)
            self.receive_token(s)
        else:
            channel_model.append(_Literal(s))

    def parse_wildcard_globs_or_as(s):
        if '?+' == s:
            channel_model.append(_WildcardGlob(1, None))
            move(parse_as)
        elif 'as' == s:
            move(parse_as)
            self.receive_token(s)
        else:
            cover_me("parse error - expecting 'as' or wildcard")

    def parse_as(s):
        if 'as' == s:
            expecting_more('as')
            move(receive_name)
        else:
            cover_me("parse error - expecting 'as'")

    def receive_name(s):
        expecting_more(None)
        name_reference.receive_value(s)

    name_reference = MutexingReference()

    class ExpectingMore:
        def __call__(self, s):
            if s is None:
                self.is_expecting_more = False
                self.expecting_more_after = None
            else:
                self.is_expecting_more = True
                self.expecting_more_after = s

    expecting_more = ExpectingMore()

    def move(new_f):
        self.receive_token = new_f

    self.receive_token = receive_token_initially

    for s in s_a:
        self.receive_token(s)

    if expecting_more.is_expecting_more:
        _ = expecting_more.expecting_more_after
        _ = f"unexpected end of tokens after '{_}'"
        cover_me(_)

    return channel_model, name_reference.value


class _ParseState:  # #[#510.3]
    def __init__(self):
        self.receive_token = None


class _WildcardGlob:

    def __init__(self, begin, end):

        if 0 == begin:
            cover_me('fun and easy')
        elif 1 == begin:
            self.is_satisfied = False
        else:
            cover_me()

        self.begin = begin
        self.end = end

    def finish(self):
        if not self.is_satisfied:
            cover_me('needed at least {} of these had none'.format(self.begin))

    def assert_against(self, s):
        if 1 == self.begin:
            self.is_satisfied = True  # might be multiple times

    does_get_consumed = False


class _Literal:

    def __init__(self, s):
        self.string = s

    def finish(self):
        _ = 'complain about how you never saw this: {}'.format(self.string)
        cover_me(_)

    def assert_against(self, s):
        if self.string != s:
            cover_me('mismatch: expecting {}, had {}'.format(
                self.string, s))

    does_get_consumed = True


def _num_params(f):
    import inspect
    return len(inspect.signature(f).parameters)


_name_rx = re.compile('^[a-z_]+$')


import sys  # noqa: E402
sys.modules[__name__] = _EmissionsModel

# #born.
