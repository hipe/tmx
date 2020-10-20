def emission_details_via_file_not_found_error(file_not_found):
    return {'reason': file_not_found.strerror,  # compare str()
            'filename': file_not_found.filename,
            'errno': file_not_found.errno}


class ModalityAgnosticErrorMonitor:  # :[#507.9]
    """Construct the error monitor with one listener. It has two attributes:

    `listener` and `OK`. Pass *this* listener to a client, and if it fails
    (by emitting an `error`), the `OK` attribute (which started out as True)
    will be set to False. The emission is passed thru to the argument listener
    unchanged.

    (moved files (a second time) at #history-B.5)
    """

    def __init__(self, listener):
        self.OK = True
        self._debug = None
        self._experimental_mutex = None  # go this away if it's annoying

        def my_listener(*a):
            if self._debug is not None:
                self._debug(a)
            if 'error' == a[0]:
                del self._experimental_mutex
                self.OK = False
            listener(*a)

        self.listener = my_listener


# == Listening

    # at #history-B.3 got rid of 2 methods that make emitters
    # #history-B.8 buried the rest of them, and some trace renderers


def throwing_listener(sev, *rest):
    if sev not in ('fatal', 'error'):
        return
    emi = emission_via_args(sev, *rest)
    tup = emi.to_debugging_tuple_()
    raise RuntimeError(f"unexpected {repr(tup)}")


def emission_via_args(*args):
    return emission_via_tuple(args)


class emission_via_tuple:  # moved here at #history-B.4

    def __init__(self, args):
        *channel, self.payloader = args
        self.channel = tuple(channel)

    def to_debugging_tuple_(self):
        lines = self.to_messages()
        return (*self.channel, *lines)

    def to_messages(self):
        if 'expression' == self.shape:
            return tuple(self.payloader())
        assert 'structure' == self.shape
        sct = self.payloader()
        if 'reason' in sct:
            return (sct['reason'],)
        return (sct['message'],)

    def to_channel_tail(self):
        return self.channel[2:]

    @property
    def shape(self):
        return self.channel[1]

    @property
    def severity(self):
        return self.channel[0]


# ==

class write_only_IO_proxy:
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

    def __init__(self, write, on_OK_exit=None, flush=None, isatty=None):
        self._on_OK_exit = on_OK_exit

        def use_write(s):
            write(s)
            return len(s)

        self.write = use_write

        if flush is not None:
            self.flush = flush  # #used-by: kiss-rdb-test

        if isatty is not None:
            self._isatty = isatty

    def __enter__(self):
        return self

    def __exit__(self, typ, value, traceback):
        if not self._on_OK_exit:
            return
        if typ is not None:
            return
        f = self._on_OK_exit
        self._on_OK_exit = None
        f()

    def isatty(self):
        self._isatty

    def writable(_):
        return True  # (Case1068DP)

    def fileno(_):  # #provision [#608.15]: implement this correctly
        return 1

    name = '<pretend-stdout>'
    mode = 'w'  # KR


class streamlib:  # #class-as-namespace

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


# == Memoizers and related

class OneShotMutex:
    def __init__(self):
        self._is_first_call = True

    def shoot(self):
        assert(self._is_first_call)
        self._is_first_call = False


# out-factored lazy_property at #history-B.7


def lazy(orig_f):  # #decorator, #[#510.8]
    def use_f():
        if len(meh):
            return meh[0]
        meh.append(orig_f())
        return meh[0]
    meh = []
    return use_f

# #history-B.8
# #history-B.7
# #history-B.6: archived few lines (elsewhere) that load resource from string
# #history-B.5: as referenced
# #history-B.4: as referenced
# #history-B.3: get rid of emitting assistants
# #history-B.2: unify IO proxies
# #history-B.1: as referenced, can be temporary
# #history-A.1: listener-related methods are spliced in from elsewhere
# #born.
