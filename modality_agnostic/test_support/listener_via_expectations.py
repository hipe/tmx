"""
Mocking (expectation) library for [#017] emissions.
(Compare lighter-weight counterpart: [#508].)
:[#509]
"""


# --

def for_DEBUGGING(*a):

    *chan, payloader = a
    shape = chan[1]

    from sys import stderr as io

    io.write(f'channel: {repr(chan)}\n')
    io.flush()
    if 'structure' == shape:
        io.write(f'meta-doh-dah: {repr(payloader())}')
    elif 'expression' == shape:
        # (at #history-A.1 got rid of old way)
        _lines = tuple(payloader())
        io.write(f'messages: {repr(_lines)}')
    else:
        raise Exception(f'strange shape: {repr(shape)}')

    io.write('\n')
    io.flush()


def listener_via_emission_receiver(receive_emission):  # :[#509.2]
    def listener(*args):
        receive_emission(ActualEmission_(args))
    return listener


class expecter_via_expected_emissions:

    def __init__(self, itr):
        from collections import deque
        _a = [_EmissionModel(s_a) for s_a in itr]
        self._emission_models = deque(_a)
        self._actual_emissions = []
        self._offset_via_name = {}

    def listener(self, *args):
        """NOTE - you won't typically call this directly"""

        ae = ActualEmission_(args)
        if self._some_emission_models_remain():
            self.__when_expecting_emission(ae)
            return
        cover_me(f'unexpected emission - {repr(args[:-1])}')

    def __when_expecting_emission(self, actual_emission):

        emission_model = self._emission_models.popleft()
        emission_model.assert_against(actual_emission)

        d = self._offset_via_name
        a = self._actual_emissions

        name = emission_model.emission_name
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


class _ActualEmissionIndex:

    def __init__(self, d, tup):
        self._offset_via_name = d
        self.actual_emissions = tup

    def actual_emission_via_name(self, name):
        _offset = self._offset_via_name[name]
        return self.actual_emissions[_offset]


class ActualEmission_:

    def __init__(self, args):
        self.channel = args[:-1]
        self._args = args

    def to_first_string(self):
        return next(self.to_raw_lines())

    def to_string(self):
        return ' '.join(self.to_raw_lines())

    def flush_payloader(self):
        return self._flush_to_vendor_emission().flush_payloader()

    def to_raw_lines(self):
        return self._flush_to_vendor_emission().flush_to_raw_lines()

    def _flush_to_vendor_emission(self):
        # (started using other lib at #history-A.2)
        # (removed complicated way at #history-A.1)
        args = self._args
        del self._args  # or not
        from modality_agnostic import listening
        return listening.emission_via_args(args)


class _EmissionModel:

    def __init__(self, s_a):
        channel_model, emission_name = _crazy_parse(s_a)
        self.channel_model = channel_model
        self.emission_name = emission_name

    def assert_against(self, actual_emission):
        from collections import deque
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

    import re

    channel_model = []

    self = _ParseState()

    def receive_token_initially(s):
        if 'as' == s:
            move(parse_as)
            self.receive_token(s)
        elif re.search('^[a-z_]+$', s):
            channel_model.append(_Literal(s))
        else:
            move(parse_wildcard_globs_or_as)
            self.receive_token(s)

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

    from modality_agnostic_test.common_initial_state import MutexingReference
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


def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')

# #history-A.2
# #history-A.1
# #born.
