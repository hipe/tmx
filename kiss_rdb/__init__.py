# at #birth, covered by a client. experimental public API


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


def _throwing_listenerer():
    from modality_agnostic import listening
    return listening.throwing_listener


def COLLECTION_VIA_COLLECTION_PATH(coll_path, listener=_throwing_listenerer()):
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

        from modality_agnostic.listening import emission_via_args

        def f(a):
            stderr.write(emission_via_args(a).flush_to_trace_line())
        self._debug = f


# ==

def dictionary_dumper_as_JSON_via_output_stream(fp):  # (Case6080)
    """JSON is chosen as a convenience for us not you. Don't get too attached

    because we might switch this default dumping format to something else.
    NOTE ths does *not* output a trailing newline.

    Everywhere this is used is near our "oneline" #wish [#873.C].
    """

    def dump(dct):
        json.dump(dct, fp=fp, indent=2)
    import json
    return dump


# ==

# #history-A.3 lose throwing listener
# #history-A.2 modality adaptation injections moved to here
# #history-A.1 become home to "listener science"
# #birth.
