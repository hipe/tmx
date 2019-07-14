# at #birth, covered by a client. experimental public API


# == used as defaults to functions below

def THROWING_LISTENER(channel_head, *rest):
    """Experimental. Raise an exception derived from the emission IFF it's

    an `error`, otherwise ignore. Use this only as a sort of `assert`.
    """

    if 'info' == channel_head:
        return
    raise _Exception(reason_via_error_emission_(*rest))


# == decorators

def lazy_experiment(attr_name, build):  # [#510.6]
    def decorator(f):
        return _do_lazy_experiment(f, attr_name, build)
    return decorator


def _do_lazy_experiment(f, attr_name, build):
    def use_f(self):
        if hasattr(self, attr_name):
            return getattr(self, attr_name)
        x = build()
        setattr(self, attr_name, x)
        return x
    return use_f

# ==


def COLLECTION_VIA_COLLECTION_PATH(coll_path, listener=THROWING_LISTENER):
    """experimental "early access" for other libraries (like pho)

    use the real filesystem. ignoring RNG for now.. Used internally too.
    """

    _fs = memoized_.real_filesystem_read_only
    return collection_via_path_(
            collection_path=coll_path, filesystem=_fs, listener=listener)


def collection_via_path_(collection_path, listener, **injections):
    return memoized_.collectioner.COLLECTION_VIA_PATH_AND_INJECTIONS(
            collection_path=collection_path, listener=listener, **injections)


def _build_collectioner():
    # (this is not hard coded just so we can test it)
    from kiss_rdb.magnetics_.collection_via_path import (
            collectioner_via_storage_adapters_module)
    these = ('kiss_rdb', 'storage_adapters_')
    from os import path as os_path
    dn = os_path.dirname
    _mod_name = '.'.join(these)
    _mod_dir = os_path.join(dn(dn(__file__)), *these)
    return collectioner_via_storage_adapters_module(_mod_name, _mod_dir)


def _build_real_filesystem():
    import kiss_rdb.magnetics_.filesystem as fs
    return fs.Filesystem_EXPERIMENTAL(commit_file_rewrite=None)


class _Memoized:

    @property
    @lazy_experiment('_thing', _build_collectioner)
    def collectioner(self):
        pass

    @property
    @lazy_experiment('_real_filesystem', _build_real_filesystem)
    def real_filesystem_read_only(self):
        pass


memoized_ = _Memoized()


# == internal, related to modality adaptation

class ModalityAdaptationInjections_:  # see [#867.U] "why we inject"

    def __init__(self, random_number_generator, filesystemer):
        once = {}
        once['filesystem'] = lambda: filesystemer()
        once['random_number_generator'] = lambda: random_number_generator
        self._once = once

    def RELEASE_THESE(self, names):
        once = self._once
        del self._once
        return {k: once[k]() for k in names}


# == listener science

class ErrorMonitor_:
    """Construct the error monitor with one listener. It has two attributes:

    `listener` and `ok`. Pass *this* listener to a client, and if it fails
    (by emitting an `error`), the `ok` attribute (which started out as True)
    will be set to False. The emission is passed thru to the argument listener
    unchanged.

    (moved files at #history-A.1)
    """

    def __init__(self, listener):
        self.ok = True
        self._debug = None
        self.experimental_mutex = None  # go this away if it's annoying

        def my_listener(*a):
            if self._debug is not None:
                self._debug(a)
            if 'error' == a[0]:
                del self.experimental_mutex
                self.ok = False
            listener(*a)

        self.listener = my_listener

    def DEBUGGING_TURN_ON(self):  # this will bork IFF destructive payloads
        assert(not self._debug)
        from sys import stderr

        def f(a):
            stderr.write(_emission(*a)._flush_to_trace_line_())
        self._debug = f


def reason_via_error_emission_(shape, error_category, union, *rest):
    _ee = _ErrorEmission(shape, error_category, union, *rest)
    return _ee._flush_to_reason_()


def message_via_info_emission_(shape, info_category, payloader):
    _ = _InfoEmission(shape, info_category, payloader)
    return _._flush_some_message_()


def _emission(*a):
    error_or_info, *rest = a
    _i = ('error', 'info').index(error_or_info)
    return (_InfoEmission if _i else _ErrorEmission)(*rest)


class _Emission:
    # experiment: a short-lived & highly stateful auxiliary for assisting in
    # emission reflecton. do not pass around as an emission. (call that Event)

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

    def _flush_to_trace_line_(self):
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


# ==

class _Exception(Exception):
    pass


# #history-A.2 modality adaptation injections moved to here
# #history-A.1 become home to "listener science"
# #birth.
