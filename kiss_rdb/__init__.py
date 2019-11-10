# at #birth, covered by a client. experimental public API


# == decorators

def lazy_reader(attr_name, build):  # [#510.6]
    def decorator(f):
        return _do_lazy_reader(f, attr_name, build)
    return decorator


def _do_lazy_reader(f, attr_name, build):
    def use_f(self):
        if hasattr(self, attr_name):
            return getattr(self, attr_name)
        x = build()
        setattr(self, attr_name, x)
        return x
    return use_f

# ==


def normal_field_name_via_string(big_s):
    return _memoized.namer(big_s)


class _NormalFieldNameViaString:
    """produce a "normal field name" from any string (maybe)

    Our working definition of "normal field name" is a string name that
    consists of only lowercase alpha and the underscore (and maybe some
    integers somewhere).
    """
    # moved here from elsewhere #history-A.5

    def __init__(self):
        import re
        self.camelcase_rx = re.compile('(?<=[a-z])(?=[A-Z])')
        self.lowlevel_blacklist_rx = re.compile('[^-a-zA-Z0-9_ \t]+')
        self.whitespace_rx = re.compile(r'[- \t]+')

    def __call__(self, big_s):
        _sanitized_s = self.lowlevel_blacklist_rx.sub('', big_s)
        _ = self.split_on_everything(_sanitized_s)
        return '_'.join(s.lower() for s in _)

    def split_on_everything(self, big_s):
        for mid_s in self.split_on_camel_case(big_s):
            for s in self.split_on_whitespace(mid_s):
                yield s

    def split_on_camel_case(self, s):  # #testpoint
        offset = 0
        for md in self.camelcase_rx.finditer(s):  # ruby has to be better at s
            offset_ = md.start()
            yield s[offset:offset_]
            offset = offset_
        yield s[offset:]

    def split_on_whitespace(self, s):
        return self.whitespace_rx.split(s)


# == access memoized things

def collectionerer():
    return _memoized.collectioner


def real_filesystem_read_only_():
    return _memoized.real_filesystem_read_only


# == define memoized things

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
    @lazy_reader('_collectioner', _build_collectioner)
    def collectioner(self):
        pass

    @property
    @lazy_reader('_namer', _NormalFieldNameViaString)
    def namer(self):
        pass

    @property
    @lazy_reader('_real_filesystem_read_ony', _build_real_filesystem)
    def real_filesystem_read_only(self):
        pass


_memoized = _Memoized()  # #testpoint


# == internal, related to modality adaptation

class ModalityAdaptationInjections_:  # see [#867.U] "why we inject"

    def __init__(self, random_number_generator, filesystemer, stdin):
        once = {}
        once['filesystem'] = lambda: filesystemer()
        once['random_number_generator'] = lambda: random_number_generator
        once['stdin'] = lambda: stdin
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

# #history-A.5
# #history-A.4 lose error monitor
# #history-A.3 lose throwing listener
# #history-A.2 modality adaptation injections moved to here
# #history-A.1 become home to "listener science"
# #birth.
