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


def sanity(s=None):
    _msg = 'sanity' if s is None else 'sanity: %s' % s
    raise _PlatformException(_msg)


_PlatformException = Exception


class Exception(Exception):
    pass


# #history-B.2: unify IO proxies
# #history-B.1: as referenced, can be temporary
# #history-A.1: listener-related methods are spliced in from elsewhere
# #born.
