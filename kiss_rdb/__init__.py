# at #birth, covered by a client. experimental public API


# == Decorator

def _build_these():  # #[#510.6] custom memoizy decorators
    def lazily_defined_monadic_function(orig_f):
        def use_f(x):
            if key not in memo:
                memo[key] = orig_f()
            return memo[key](x)
        key = orig_f.__name__
        return use_f

    def lazy(orig_f):
        def use_f():
            if key not in memo:
                memo[key] = orig_f()
            return memo[key]
        key = orig_f.__name__
        return use_f
    memo = {}
    return lazy, lazily_defined_monadic_function


_lazy, _lazily_defined_monadic_function = _build_these()


# == Top-Level Accesspoint: Storage Adapter Agents

@_lazy
def collectionerer():
    mod_name, mod_dir = hub_mod_name_and_mod_dir()
    from kiss_rdb.magnetics_.collection_via_path import \
        collectioner_via_storage_adapters_module as collectioner_via
    return collectioner_via(mod_name, mod_dir)


def hub_mod_name_and_mod_dir():
    pcs = 'kiss_rdb', 'storage_adapters_'
    from os.path import join as path_join, dirname as dn
    return '.'.join(pcs), path_join(dn(dn(__file__)), *pcs)


# == Higher-Level Module Support: Specific Presentation Stuff

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


# == Mid-Level: Collections and support

@_lazily_defined_monadic_function
def normal_field_name_via_string():
    # full rewrite from callable class to closure-style func at #history-B.1
    # moved here from elsewhere #history-A.5

    return _field_name_functions().normal_field_name_via_string


@_lazy
def _field_name_functions():  # #testpoint

    def _normal_field_name_via_string(any_string):
        sanitized = lowlevel_deny_list_rx.sub('', any_string)
        pcs = split_on_everything(sanitized)
        return '_'.join(upper_or_lower(piece) for piece in pcs)

    def upper_or_lower(piece):
        if is_nothing_but_all_uppercase_and_digits_rx.match(piece):
            return piece
        return piece.lower()

    def split_on_everything(long_string):
        for medium_string in split_on_camel_case(long_string):
            for piece in separator_rx.split(medium_string):
                yield piece

    def split_on_camel_case(s):
        offset = 0
        for md in camelcase_rx.finditer(s):  # ruby has to be better at somethi
            offset_ = md.start()
            yield s[offset:offset_]
            offset = offset_
        yield s[offset:]

    normal_field_name_via_string.split_on_camel_case = split_on_camel_case

    import re
    o = re.compile
    is_nothing_but_all_uppercase_and_digits_rx = o('^[A-Z0-9]+$')
    separator_rx = o(r'[-_ \t]+')
    camelcase_rx = o('(?<=[a-z])(?=[A-Z])')
    lowlevel_deny_list_rx = o('[^-a-zA-Z0-9_ \t]+')

    class name_functions:  # #class-as-namespace
        normal_field_name_via_string = _normal_field_name_via_string
        _split_on_camel_case = split_on_camel_case  # #testpoint

    return name_functions


SCHEMA_FILE_ENTRY_ = 'schema.rec'


# == Lower-Level: System and Filesytem


@_lazy
def real_filesystem_read_only__():  # at writing only used by one test file
    import kiss_rdb.magnetics_.filesystem as fs
    return fs.Filesystem_EXPERIMENTAL(commit_file_rewrite=None)


# #history-B.1 sunset injections class, restructure file
# #history-A.5
# #history-A.4 lose error monitor
# #history-A.3 lose throwing listener
# #history-A.2 modality adaptation injections moved to here
# #history-A.1 become home to "listener science"
# #birth.
