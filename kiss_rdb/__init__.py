# at #birth, covered by a client. experimental public API


# == used as defaults to functions below

def THROWING_LISTENER(channel_head, *rest):
    """Experimental. Raise an exception derived from the emission IFF it's

    an `error`, otherwise ignore. Use this only as a sort of `assert`.
    """

    if 'info' == channel_head:
        return
    raise _Exception(reason_via_error_emission_(*rest))


# ==

def COLLECTION_VIA_DIRECTORY(directory, listener=THROWING_LISTENER):

    schema = SCHEMA_VIA_COLLECTION_PATH(directory, listener)
    if schema is None:
        return

    from kiss_rdb.storage_adapters_.toml import collection_via_directory

    return collection_via_directory.collection_via_directory_and_schema(
            collection_directory_path=directory,
            collection_schema=schema,
            )


def SCHEMA_VIA_COLLECTION_PATH(collection_path, listener=THROWING_LISTENER):
    from kiss_rdb.storage_adapters_.toml import (
        schema_via_file_lines)
    return schema_via_file_lines.SCHEMA_VIA_COLLECTION_PATH(
        collection_path, listener)


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


def reason_via_error_emission_(shape, error_category, payloader):
    return _ErrorEmission(shape, error_category, payloader)._flush_to_reason_()


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
        return payloader()


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


# #history-A.1 become home to "listener science"
# #birth.
