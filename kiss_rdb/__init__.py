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

# #history-A.4 lose error monitor
# #history-A.3 lose throwing listener
# #history-A.2 modality adaptation injections moved to here
# #history-A.1 become home to "listener science"
# #birth.
