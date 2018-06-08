"""ahem..

:[#509]
"""

from modality_agnostic import (
        cover_me,
        )
import re
from collections import deque as deque


# --

def for_DEBUGGING(*a):
    import sys
    io = sys.stderr
    chan_a = list(a)
    thing = chan_a.pop()

    def f(msg):
        msg_a.append(msg)
    msg_a = []
    thing(f, '«no expression agent yet»')
    io.write("channel: {}\n".format(repr(chan_a)))
    io.write("messages: {}\n".format(repr(msg_a)))
    io.flush()


def listener_via_emission_receiver(receive_emission):  # :[#509.B]
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
        expresser = chan.pop()
        ae = _ActualEmission(expresser, tuple(chan))
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

    def __init__(self, expresser, chan):
        self.expresser = expresser
        self.channel = chan

    def to_string(self):
        """NOTE - xxx

        for one thing, this has been done elsewhere
        for another thing, this totally ignores expression agents
        for a third thing, this work isn't memoized here.
        """

        def WILL_DEPRECATE_message_receiver(msg):
            # #open [#508]
            msgs.append(msg)

        msgs = []
        self.expresser(WILL_DEPRECATE_message_receiver, 'no expag')
        return '\n'.join(msgs)


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
    name = None

    def f(s):
        if 'as' == s:
            move(parse_as)
            f(s)
        elif _name_rx.search(s) is None:
            move(parse_wildcard_globs_or_as)
            f(s)
        else:
            channel_model.append(_Literal(s))

    def parse_wildcard_globs_or_as(s):
        if '?+' == s:
            channel_model.append(_WildcardGlob(1, None))
            move(parse_as)
        elif 'as' == s:
            move(parse_as)
            f(s)
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
        nonlocal name
        name = s

    def expecting_more(s):
        nonlocal is_expecting_more, expecting_more_after
        if s is None:
            is_expecting_more = False
            expecting_more_after = None
        else:
            is_expecting_more = True
            expecting_more_after = s

    is_expecting_more = False
    expecting_more_after = None

    def move(new_f):
        nonlocal f
        f = new_f

    for s in s_a:
        f(s)

    if is_expecting_more:
        _ = "unexpected end of tokens after '{}'".format(
                expecting_more_after,
                )
        cover_me(_)

    return channel_model, name


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

    @property
    def does_get_consumed(self):
        return False


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

    @property
    def does_get_consumed(self):
        return True


_name_rx = re.compile('^[a-z_]+$')


import sys  # noqa: E402
sys.modules[__name__] = _EmissionsModel

# #born.
