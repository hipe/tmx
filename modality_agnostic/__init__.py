class listening:  # (as namespace only)

    def emitter_via_listener(listener):
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

    def leveler_via_listener(level_s, listener):
        def o(tmpl, *args, **kwargs):
            log(level_s, tmpl, *args, **kwargs)
        log = listening.logger_via_listener(listener)
        return o

    def logger_via_listener(listener):
        if listener is None:  # #[#507.2] we want strong typing
            raise Exception('sanity - you want a listener')

        # #open [#508] below where we pass `o` we should instead etc

        def log(category, tmpl, *args, **kwargs):
            def write_this(o, styler=None):
                _msg = tmpl.format(*args, **kwargs)
                o(_msg)
            listener(category, 'expression', write_this)
        return log


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


def sanity(s=None):
    _msg = 'sanity' if s is None else 'sanity: %s' % s
    raise _PlatformException(_msg)


_PlatformException = Exception


class Exception(Exception):
    pass


# #history-A.1: listener-related methods are spliced in from elsewhere
# #born.
