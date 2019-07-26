class listening:  # (as namespace only)

    def emitter_via_listener(listener):
        # at #history-B.1 removed all but one client
        def emit(*chan_args_tmpl):
            def emit_lines():
                if args is None:
                    msg = tmpl
                else:
                    _use_args = args if isinstance(args, tuple) else (args,)
                    msg = tmpl.format(*_use_args)
                yield msg
            (*chan), tmpl, args = chan_args_tmpl
            listener(*chan, emit_lines)
        return emit

    # at #history-B.3 got rid of 2 methods that make emitters

    def throwing_listener(channel_head, *rest):
        """Experimental. Raise an exception derived from the emission IFF it's

        an `error`, otherwise ignore. Use this only as a sort of `assert`.
        """

        if 'info' == channel_head:
            return
        raise Exception(listening.reason_via_error_emission(*rest))

    def emission_via_args(args):
        error_or_info, *rest = args
        _i = ('error', 'info').index(error_or_info)
        return (_InfoEmission if _i else _ErrorEmission)(*rest)

    def reason_via_error_emission(shape, error_category, union, *rest):
        _ee = _ErrorEmission(shape, error_category, union, *rest)
        return _ee._flush_to_reason_()

    def message_via_info_emission(shape, info_category, payloader):
        _ = _InfoEmission(shape, info_category, payloader)
        return _._flush_some_message_()


class _ErrorMonitor:
    """Construct the error monitor with one listener. It has two attributes:

    `listener` and `ok`. Pass *this* listener to a client, and if it fails
    (by emitting an `error`), the `ok` attribute (which started out as True)
    will be set to False. The emission is passed thru to the argument listener
    unchanged.

    (moved files (a second time) at #history-B.5)
    """

    def __init__(self, listener):
        self.ok = True
        self._debug = None
        self._experimental_mutex = None  # go this away if it's annoying

        def my_listener(*a):
            if self._debug is not None:
                self._debug(a)
            if 'error' == a[0]:
                del self._experimental_mutex
                self.ok = False
            listener(*a)

        self.listener = my_listener

    def DEBUGGING_TURN_ON(self):  # this will bork IFF destructive payloads
        assert(not self._debug)
        from sys import stderr

        def f(a):
            stderr.write(listening.emission_via_args(a).flush_to_trace_line())
        self._debug = f


setattr(listening, 'ErrorMonitor', _ErrorMonitor)


class _Emission:
    # experiment: a short-lived & highly stateful auxiliary for assisting in
    # emission reflection. do not pass around as an emission. (call that Event)
    # moved here at #history-B.4

    def __init__(self, *a):
        shape, *chan_tail, payloader = a
        assert(shape in ('structure', 'expression'))
        self.shape = shape
        self.channel_tail = chan_tail
        self._payloader_HOT = payloader

    def _has_channel_tail_(self):
        return len(self.channel_tail)

    def _prefix_via_channel_tail_(self):
        _what_kind = self.channel_tail[0].replace('_', ' ')  # "input error"
        return f'{_what_kind}:'

    def flush_to_trace_line(self):
        _tup = tuple(self.__flush_to_trace_line_pieces())
        return f'{_tup}\n'

    def _flush_some_message_(self):
        _i = ('structure', 'expression').index(self.shape)
        _m = ('_message_when_structure', '_message_when_expression')[_i]
        return getattr(self, _m)()

    def _message_when_structure(self):
        sct = self._flush_payloader_()
        key = self._message_key_
        if key in sct:
            return sct[key]
        _these = ', '.join(sct.keys())
        return f"(unknown {key}, keys: ({_these}))"  # key as natural key

    def __flush_to_trace_line_pieces(self):
        yield (self._severity_, self.shape, * self.channel_tail)  # _to_cha.._
        _i = ('structure', 'expression').index(self.shape)
        _m = ('_trace_when_structure', '_trace_when_expression')[_i]
        for tup in getattr(self, _m)():
            yield tup

    def _trace_when_expression(self):
        yield ('paragraph_string', self._message_when_expression())

    def _message_when_expression(self):
        pcs = []
        for line in self._flush_payloader_():
            pcs.append(line)
            pcs.append('\n')
        return ''.join(pcs)

    def _trace_when_structure(self):
        sct = self._flush_payloader_()
        key = self._message_key_
        if key in sct:
            yield (key, sct[key])
        else:
            yield ('keys', tuple(sct.keys()))

    def _flush_payloader_(self):
        payloader = self._payloader_HOT
        del self._payloader_HOT
        return payloader()  # [#511.3]


class _ErrorEmission(_Emission):

    def _flush_to_reason_(self):
        return ' '.join(self.__to_pieces())

    def __to_pieces(self):
        if self._has_channel_tail_:
            yield self._prefix_via_channel_tail_()
        yield self._flush_some_message_()

    _message_key_ = 'reason'
    _severity_ = 'error'


class _InfoEmission(_Emission):

    _message_key_ = 'message'
    _severity_ = 'info'


class _write_only_IO_proxy:
    """A sort-of proxy (façade?) of a filehandle open for writing defined..

    ..with a set of callbacks defining what to do at each IO operation.

    Born (#history-B.2) entirely as an abstration from four separate projects
    that all did something similar, it eliminated an amount of redundant code
    we are so proud of that we mention it here.

    real life use-cases:
      - implement a dry-run IO handle in 3 lines #used-by:pho
      - a tee that writes also to a debugging stream #used-by:script-lib (2x)
      - become also a context manager with arbitrary callback on exit
        .#used-by: upload-bot
    """

    def __init__(self, write, on_OK_exit=None, flush=None):

        # become also a context manager that follows the common pattern IFF:
        if on_OK_exit is not None:
            def f(typ, value, traceback):
                if typ is not None:
                    cover_me("proxy doesn't support handling exceptions (yet)")
                on_OK_exit()  # return values meh
            self._exit = f
            self._enter = lambda: self

        def use_write(s):
            write(s)
            return len(s)

        self.write = use_write

        if flush is not None:
            self.flush = flush  # #used-by: kiss-rdb-test

    def __enter__(self):
        return self._enter()

    def __exit__(self, typ, err, stack):
        return self._exit(typ, err, stack)


class io:  # #as-namespace-only
    write_only_IO_proxy = _write_only_IO_proxy


class streamlib:  # (as namespace only)

    def next_or_noner(itr):
        def f():
            return streamlib.next_or_none(itr)
        return f

    def next_or_none(itr):
        try:
            return next(itr)
        except StopIteration:
            pass


def pop_property(self, var):
    x = getattr(self, var)
    delattr(self, var)
    return x


def cover_me(s):
    raise _PlatformException('cover me: {}'.format(s))


_PlatformException = Exception


class Exception(Exception):
    pass


# #history-B.5: as referenced
# #history-B.4: as referenced
# #history-B.3: get rid of emitting assistants
# #history-B.2: unify IO proxies
# #history-B.1: as referenced, can be temporary
# #history-A.1: listener-related methods are spliced in from elsewhere
# #born.
