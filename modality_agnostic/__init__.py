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


# #history-B.3: get rid of emitting assistants
# #history-B.2: unify IO proxies
# #history-B.1: as referenced, can be temporary
# #history-A.1: listener-related methods are spliced in from elsewhere
# #born.
