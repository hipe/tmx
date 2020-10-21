def _listener(*args):  # used as default argument
    from modality_agnostic import throwing_listener as func
    func(*args)


def collectioner_via_storage_adapters_module(mod_name, mod_dir, *more):
    class collectioner:  # #class-as-namespace
        def collection_via_path(collection_path, listener=_listener, **kw):
            return _collection_via_path(collection_path, listener, saidx, kw)

        def SPLAY_STORAGE_ADAPTERS():
            return saidx._splay_storage_adapters()

        def storage_adapter_via_key(k):  # ..
            return saidx.storage_adapter_via_key(k, _listener)

    pairs = ((more[i], more[i+1]) for i in range(0, len(more), 2))
    saidx = _storage_adapter_index(((mod_name, mod_dir), *pairs))
    return collectioner


def _collection_via_path(x, listener, saidx, kw):
    cci = _classify_collection_identifier(x)
    format_name = kw.pop('format_name', None)  # #here1
    opn = kw.get('opn', None)
    two = _parse_schema_and_resolve_SA(cci, format_name, saidx, listener, opn)
    if two is None:
        return
    ada_opts, sa = two
    if ada_opts:
        # We're currently munging our own namespace and a business namespace.
        # Either we shouldn't do this, or we should allow it. we don't know yet
        if len(inter := set(kw.keys()).intersection(set(ada_opts.keys()))):
            xx(''.join(("clober ok? (", ', '.join(inter), ')')))
        kw.update(ada_opts)
    return _collection_via(sa, cci, listener, kw)


def collection_via_storage_adapter_module_and_path_(sa_mod, x, listener, kw):
    cci = _classify_collection_identifier(x)
    key = _key_via_storage_adapter_module(sa_mod)
    sa = _StorageAdapter(sa_mod, key)
    return _collection_via(sa, cci, listener, kw)


def _collection_via(sa, cci, listener, kw):
    # exactly [#857.D] (subgraph B)

    def main():
        return when_directory_based() if is_dir_based() else when_file_based()

    def when_file_based():
        if hasattr(sa.module, 'CUSTOM_FUNCTIONSER'):  # (not in flowchart grap)
            return build_collection('custom')

        def when_collection_identifier_is():
            yield 'string', when_file_based_and_string
            yield 'file_resource', when_file_is_resource
        return case(cci.narrative_shape_type, when_collection_identifier_is)

    def when_directory_based():
        def when_collection_identifier_is():
            yield 'string', do_directory_based
        return case(cci.narrative_shape_type, when_collection_identifier_is)

    def when_file_is_resource():
        def when_file_resource_is():
            yield 'writable', when_file_is_writable
            yield 'readable', when_file_is_readable_not_writable
        return case(cci.narrative_writable_or_readable, when_file_resource_is)

    # == Consequences

    def do_directory_based():
        return build_collection('when_directory')

    def when_file_is_writable():
        return build_collection('for_pass_through_writing')

    def when_file_is_readable_not_writable():
        return build_collection('for_traversal_via_lines')

    def when_file_based_and_string():
        return build_collection('when_file_path')

    def build_collection(which):
        return _build_collection(which, cci, sa, kw, crazy_listener)

    # == Conditionals

    def is_dir_based():
        return _is_directory_based(sa.module)

    # ==

    def crazy_listener(sev, *rest):
        if 'error' != sev:
            return listener(sev, *rest)
        stack = _stack_function()()
        _re_emit_case_error_CRAZILY(listener, stack, (sev, *rest))

    case = _build_case_function(crazy_listener)
    throwing_listener, stop = _throwing_listener_and_stop(listener)
    try:
        return main()
    except stop:
        pass


def _build_collection(which, cci, sa, kw, crazy_listener):

    # Determine the function categories we need, and binding strategy
    is_file_based, is_directory_based, is_custom = True, False, False
    is_directory_based, is_custom = False, False
    if 'when_file_path' == which:
        read, write = 'want', 'want'
    elif 'when_directory' == which:
        is_file_based, is_directory_based = False, True
        read, write = 'want', 'want'
    elif 'for_traversal_via_lines' == which:
        read, write = 'need', None
    elif 'for_pass_through_writing' == which:
        read, write = None, 'need'
    else:
        assert 'custom' == which
        is_file_based, is_custom = False, True
        read, write = 'want', 'want'

    # Determine what the capabilities are and prepare binding strategies
    # (ALL of this binding logic is VERY experimental)

    mod = sa.module
    x = cci.mixed_collection_identifier
    opn = kw.get('opn')
    bind_editors, bind_readers = None, None

    if is_file_based:
        fxr = mod.FUNCTIONSER_FOR_SINGLE_FILES()
        edit_funcser = fxr.PRODUCE_EDIT_FUNCTIONS_FOR_SINGLE_FILE
        read_funcser = fxr.PRODUCE_READ_ONLY_FUNCTIONS_FOR_SINGLE_FILE
        bind_editors = _bind_editors_for_single_file
        bind_readers = _bind_readers_for_single_file
    elif is_directory_based:
        fxr = mod.FUNCTIONSER_VIA_DIRECTORY_AND_ADAPTER_OPTIONS(
            x, crazy_listener, **kw)
        edit_funcser = fxr.PRODUCE_EDIT_FUNCTIONS_FOR_DIRECTORY
        read_funcser = fxr.PRODUCE_READ_ONLY_FUNCTIONS_FOR_DIRECTORY
    else:
        # Get custom bindings from the SA lazily, only as-needed per category
        assert is_custom
        if (fxr := mod.CUSTOM_FUNCTIONSER(x, opn, crazy_listener)) is None:
            return
        edit_funcser = fxr.PRODUCE_EDIT_FUNCTIONS_CUSTOMLY
        read_funcser = fxr.PRODUCE_READ_FUNCTIONS_CUSTOMLY

    # See if any required capabilities are missing, and apply the bindings
    do_edit, do_read, missing = False, False, []
    if write:
        if edit_funcser:
            do_edit = True
            edit_funcs = edit_funcser()  # or maybe lazy
            if bind_editors:
                edit_funcs = bind_editors(which, x, edit_funcs, opn)
        elif 'need' == write:
            missing.append('write')
    if read:
        if read_funcser:
            do_read = True
            read_funcs = read_funcser()  # or maybe lazy
            if bind_readers:
                read_funcs = bind_readers(which, x, read_funcs, opn)
        elif 'need' == read:
            missing.append('read')

    if missing:
        xx(f"fun! {sa.key} does not define {', '.join(missing)}")

    assert read or write  # per the rule table above

    # Money

    def parse_identifier(orig_f):  # #decorator
        def use_f(eid, *rest):
            if (iden := parse_EID(eid, rest[-1])) is None:
                return
            return orig_f(iden, *rest)
        return use_f

    class collection_NEW_WAY:  # #class-as-namespace
        if do_edit:
            @parse_identifier
            def update_entity(iden, x, listener):
                return edit_funcs.update_entity_as_storage_adapter_collection(
                    iden, x, listener)

            def create_entity(x, listener):
                return edit_funcs.create_entity_as_storage_adapter_collection(
                    parse_EID, x, listener)

            @parse_identifier
            def delete_entity(iden, listener):
                return edit_funcs.delete_entity_as_storage_adapter_collection(
                    iden, listener)

        if do_edit and not is_directory_based:  # oh man. maybe one day
            def open_collection_to_write_given_traversal(listener):
                return edit_funcs._open_coll_for_passthru_write(listener)

        if do_read:
            @parse_identifier
            def retrieve_entity(iden, listener):
                return read_funcs.retrieve_entity_as_storage_adapter_collection(iden, listener)  # noqa: E501

            def TO_IDENTIFIER_STREAM(listener):
                raise RuntimeError("CHANGE IT PlEASE")

            def open_identifier_traversal(listener):
                return read_funcs.open_identifier_traversal_as_storage_adapter_collection(listener)  # noqa: E501

            def open_entity_traversal(listener):
                raise RuntimeError("let's party - probably just derive from below")  # noqa: E501
                # return _open_entity_traversal_NEW_NEW_WAY(listener)

            def open_schema_and_entity_traversal(listener):
                return read_funcs.open_schema_and_entity_traversal_as_storage_adapter_collection(listener)  # noqa: E501

        def to_noun_phrase():
            # (more complicated before #history-B.5, lost thing about variant)
            # (moved to this file at #history-B.4)
            sa_slug = sa.key.replace('_', '-')
            return ''.join(("the '", sa_slug, "' format adapter"))

        COLLECTION_IMPLEMENTATION = fxr.COLL_IMPL_YUCK_
        storage_adapter = sa

    parse_EID = (f := fxr.PRODUCE_IDENTIFIER_FUNCTION) and f()
    return collection_NEW_WAY


def _bind_editors_for_single_file(which, x, funcs, opn):

    def use_create(iden_via, dct, listen):
        # mode 'r+': must exist. open for read & write. pointer at beginning
        with do_open_writable_filehandle('r+') as fp:
            return funcs.CREATE_NEW_WAY(fp, iden_via, dct, listen)

    def pass_thru_write(listener):
        lv = funcs.lines_via_schema_and_entities

        @_contextmanager()
        def cm():
            # mode 'x': cannot first exist. create a new file and open it for w
            opened = do_open_writable_filehandle('x')
            ok = False
            try:
                fp = opened.__enter__()

                class traversal_receiver:  # #class-as-namespace, crazy flex
                    def receive_schema_and_entities(schema, ents, listen):
                        return _do_passthru_write(fp, schema, ents, lv, listen)
                yield traversal_receiver
                ok = True
            finally:
                if not ok:
                    xx("read me - maybe clean up")  # (before #history-B.5 we
                    # ..used to fp.seek(0), fp.truncate(0), os_unlink(x))
                opened.__exit__()
        return cm()

    # ==

    if 'when_file_path' == which:
        def do_open_writable_filehandle(mode):
            return (opn or open)(x, mode)  # ..
    else:
        def do_open_writable_filehandle(_):
            return _null_context(x)
        assert 'for_pass_through_writing' == which

    class use_edit_funcs:  # #class-as-namespace
        create_entity_as_storage_adapter_collection = use_create
        _open_coll_for_passthru_write = pass_thru_write
    return use_edit_funcs


def _do_passthru_write(fp, schema, ents, lines_via_two, listener):
    total = 0
    for line in lines_via_two(schema, ents, listener):
        total += fp.write(line)
    return total


def _bind_readers_for_single_file(which, x, funcs, opn):
    # (A lot of this could be tightened but: for now, redundancy for clarity)

    # Does the single-file SA want to implement its own random access?
    if hasattr(funcs, 'RETRIEVE_NEW_WAY'):
        def use_retrieve(iden, listener):
            with do_open_readable_filehandle() as fp:
                return funcs.RETRIEVE_NEW_WAY(fp, iden, listener)
    else:
        def use_retrieve(iden, listener):
            with do_open_readable_filehandle() as fp:
                return retrieve_in_linear_time(fp, iden, listener)

    def retrieve_in_linear_time(fp, iden, listener):
        _schema, ents = sch_ents_via_fp_er()(fp, listener)
        # .. probably return if ents is None ..

        for ent in ents:
            curr_iden = ent.identifier
            if iden == curr_iden:
                return ent
            xx()

    def sch_en(listener):
        sch_ents_via_two = sch_ents_via_fp_er()

        @_contextmanager()
        def cm():
            opened = do_open_readable_filehandle()
            fp = opened.__enter__()
            try:
                yield sch_ents_via_two(fp, listener)
            finally:
                opened.__exit__()
        return cm()

    def sch_ents_via_fp_er():
        return funcs.schema_and_entities_via_lines

    # ==

    if 'when_file_path' == which:
        def do_open_readable_filehandle():
            return (opn or open)(x)  # ..
    else:
        assert 'for_traversal_via_lines' == which  # (Case1062DP)

        def do_open_readable_filehandle():
            # STDIN or an open filehandle (-looking-thing) was passed in.
            # The contract is: because we didn't open it, we don't close it.

            return _null_context(x)

    class use_read_funcs:  # #class-as-namespace
        retrieve_entity_as_storage_adapter_collection = use_retrieve
        open_schema_and_entity_traversal_as_storage_adapter_collection = sch_en
    return use_read_funcs


def _parse_schema_and_resolve_SA(cci, fmt, saidx, listener, opn=None):
    # to sort this out, we made flowchart [#857.D]. direct translation here:

    def main():
        when_format_name_is_given() if fmt else when_no_format_name_given()

    def when_no_format_name_given():
        def when_collection_identifier_is():
            yield 'string', when_string_shaped_identifier
        case(cci.narrative_shape_type, when_collection_identifier_is)

    def when_format_name_is_given():
        def when_collection_is():
            yield directory_based, load_and_parse_schema_file
            yield file_based, _no_op  # done: SA no schema
        self.SA = saidx.storage_adapter_via_format_name(fmt, crazy_listener)
        case(when_collection_is)

    def when_string_shaped_identifier():
        when_has_extension() if has_extension() else when_has_no_extension()

    def when_has_no_extension():
        load_and_parse_schema_file()

    def when_has_extension():
        self.SA = saidx.storage_adapter_via_extname(
            self.extension, throwing_listener, cstacker)

    # == Conditionals

    def directory_based():
        self.dir_based = _is_directory_based(self.SA.module)
        return self.dir_based

    def file_based():
        assert not self.dir_based
        return True

    def has_extension():
        from os.path import splitext
        self.extension = splitext(cci.mixed_collection_identifier)[1]
        return len(self.extension)

    # == Workhorse

    def load_and_parse_schema_file():
        x = cci.mixed_collection_identifier
        two = _SA_opts_via_parse_schema(x, saidx, opn, throwing_listener)
        assert two  # otherwise a stop should have been raised above
        sa, self.adapter_opts = two
        if self.SA:
            xx('lol think about this a little')
        else:
            self.SA = sa

    # == Mechanics

    def crazy_listener(sev, *rest):
        if 'error' != sev:
            return listener(sev, *rest)
        stack = _stack_function()()
        _re_emit_case_error_CRAZILY(listener, stack, (sev, *rest))

    def cstacker():
        xx()

    # ==

    case = _build_case_function(crazy_listener)
    throwing_listener, stop = _throwing_listener_and_stop(listener)

    class self:  # #class-as-namespace
        SA, adapter_opts = None, None

    try:
        main()
        return self.adapter_opts, self.SA
    except stop:
        pass


def _SA_opts_via_parse_schema(x, saidx, opn, listener):
    # again we try to hew as close as possible to flowchart [#857.D]

    from kiss_rdb import SCHEMA_FILE_ENTRY_ as tail
    from os.path import join as os_path_join
    schema_path = os_path_join(x, tail)
    try:
        opened = (opn or open)(schema_path)
    except FileNotFoundError as e:
        return _emit_about_no_schema_file(listener, e)
    except NotADirectoryError:
        return _emit_about_no_extname(listener, x)

    def storage_adapter_by(o):
        o.resolve_first_field_line()
        o.check_that_first_field_line_has_a_particular_name()
        return o.resolve_storage_adapter_given_name()

    with opened as opened:
        reso = _crazy_schema_thing(opened, storage_adapter_by, saidx, listener)
        if reso is None:
            return
        sfs, sa = reso.schema_file_scanner, reso.storage_adapter
        dct = sa.module.ADAPTER_OPTIONS_VIA_SCHEMA_FILE_SCANNER(sfs, listener)
        if dct is None:
            return
        return sa, dct


# == Storage Adapter Index

def _storage_adapter_via(original_method):  # #decorator
    def use_method(self, needle, listener, cstacker=None, validate=None):
        key = original_method(self, needle, listener)
        if key is None:
            return
        return self._finish_lookup(key, listener, cstacker, validate)
    return use_method


class _storage_adapter_index:

    def __init__(self, name_and_directory_s):
        # module_name = mod.__name__
        # module_directory = mod.__path__._path[0]
        # --
        from os import listdir
        from fnmatch import fnmatch
        from os.path import splitext
        # from glob import glob
        # _glob_path = os_path.join(_dir, '[!_]*')
        # order = tuple(sorted(glob(_glob_path)))  # gives you full paths

        adapters, hubs = {}, []

        for mod_name, mod_dir in name_and_directory_s:
            hub_offset = len(hubs)
            hubs.append(mod_name)  # #here3
            for entry in listdir(mod_dir):
                if not fnmatch(entry, '[!_]*'):
                    continue
                key, _ = splitext(entry)
                if key in adapters:
                    raise RuntimeError(f"collision: '{key}'")
                adapters[key] = 'reference', hub_offset  # #here2

        self._order = tuple(sorted(adapters.keys()))
        self._reference_via_key = adapters
        self._hubs = tuple(hubs)
        self._key_via_extname = None
        self._key_via_format_name = None

    @_storage_adapter_via
    def storage_adapter_via_extname(self, extname, listener):

        if self._key_via_extname is None:
            self.__init_extname_index()

        if extname not in self._key_via_extname:
            _emit_about_extname(listener, extname, self._key_via_extname)
            return

        return self._key_via_extname[extname]

    @_storage_adapter_via
    def storage_adapter_via_format_name(self, format_name, listener):

        if self._key_via_format_name is None:
            self._key_via_format_name = {k.replace('_', '-'): k for k in self._order}  # noqa: E501

        if format_name not in self._key_via_format_name:
            _emit_about_format_name(
                    listener, format_name, self._key_via_format_name)
            return

        return self._key_via_format_name[format_name]

    def storage_adapter_via_key(
            self, key, listener, cstacker=None, validate=None):

        if key not in self._reference_via_key:
            _emit_about_SA_key(listener, key, self._order, cstacker)
            return

        return self._finish_lookup(key, listener, cstacker, validate)

    def _finish_lookup(self, key, listener, cstacker, validate):

        sa = self._dereference(key)

        # (ad-hoc validation before more general validation = better UI msgs)
        if validate is not None:
            if not validate(sa):
                return

        if not sa.module.STORAGE_ADAPTER_IS_AVAILABLE:
            return _emit_about_nonworking_stub(listener, sa, cstacker)

        return sa

    def __init_extname_index(self):
        self._key_via_extname = False  # lock it for safety
        dct = {}
        for key in self._order:
            sa = self._dereference(key)
            if not sa.module.STORAGE_ADAPTER_CAN_LOAD_SCHEMALESS_SINGLE_FILES:
                continue
            for en in sa.module.STORAGE_ADAPTER_ASSOCIATED_FILENAME_EXTENSIONS:
                if en in dct:
                    # #not-covered
                    raise Exception(_say_extname_collision(en, dct[en], key))
                dct[en] = key
        self._key_via_extname = dct

    def _splay_storage_adapters(self):
        def build_dereferencer(key):  # (Case3498DP)
            def f():
                return self._dereference(key)
            return f

        for key in self._reference_via_key:
            yield (key, build_dereferencer(key))

    def _dereference(self, key):
        sx = self._reference_via_key[key]
        if 'loaded' == sx[0]:  # #here2
            return sx[1]
        self._reference_via_key[key] = False  # lock it for safety
        typ, hub_offset = sx
        assert 'reference' == typ
        hub_mod_name = self._hubs[hub_offset]  # #here3
        mod_name = '.'.join((hub_mod_name, key))
        from importlib import import_module as func
        module = func(mod_name)
        sa = _StorageAdapter(module, key)
        self._reference_via_key[key] = 'loaded', sa  # #here2
        return sa


def _crazy_schema_thing(opened, main, saidx, listener):

    def resolve_storage_adapter_given_name():
        def cstacker():
            return (scanner.contextualize_about_field_value({}, reso.field),)

        def validate(sa):
            if sa.module.STORAGE_ADAPTER_CAN_LOAD_DIRECTORIES:
                return True
            return _emit_about_not_directory_based(listener, sa, cstacker)

        sa = saidx.storage_adapter_via_key(
            reso.field.field_value_string, listener, cstacker, validate)
        if sa is None:
            raise stop()
        reso.storage_adapter = sa
        return reso

    def check_that_first_field_line_has_a_particular_name():
        if 'storage_adapter' == reso.field.field_name:
            return

        def cstacker():
            return (scanner.contextualize_about_field_name({}, reso.field),)
        _emit_about_first_field_name(listener, cstacker)
        raise stop()

    def resolve_first_field_line():
        if there_is_another_block():
            if its_a_separator_block():
                if there_is_another_block():
                    if its_a_field_line():
                        found_it()  # (Case1418)
                    else:
                        assert_and_whine_about_effectively_empty_file()
            elif its_a_field_line():
                found_it()
            else:
                assert_and_whine_about_literally_empty_file()

    def found_it():
        reso.field = reso.block
        del reso.block

    def its_a_field_line():
        return reso.block.is_field_line

    def its_a_separator_block():
        return reso.block.is_separator_block

    def there_is_another_block():
        block = scn.next_block(listener)
        if block is None:
            raise stop()  # (Case1414)
        reso.block = block
        return True

    def assert_and_whine_about_effectively_empty_file():
        assert reso.block.is_end_of_file
        whine_empty('effectively_empty_file')  # (Case1417)

    def assert_and_whine_about_literally_empty_file():
        assert reso.block.is_end_of_file
        whine_empty('literally_empty_file')  # (Case1415)

    def whine_empty(which):
        _emit_about_empty_schema_file(listener, which, scn)
        raise stop()

    class reso:
        pass

    from kiss_rdb.storage_adapters_.rec import ErsatzScanner
    scn = ErsatzScanner(opened)
    from kiss_rdb.magnetics_.schema_file_scanner_via_recfile_scanner import (
            schema_file_scanner_via_recfile_scanner)
    scanner = schema_file_scanner_via_recfile_scanner(scn)
    reso.schema_file_scanner = scanner

    class controls:
        pass
    controls.resolve_first_field_line = resolve_first_field_line
    controls.check_that_first_field_line_has_a_particular_name = check_that_first_field_line_has_a_particular_name  # noqa: E501
    controls.resolve_storage_adapter_given_name = resolve_storage_adapter_given_name  # noqa: E501

    class stop(RuntimeError):
        pass
    try:
        return main(controls)
    except stop:
        pass


def _classify_collection_identifier(x):
    # exists only to DRY up any logic to be shared between the two new ways

    def these():
        def narrative_writable_or_readable():  # assume
            if arg_looks_like_writable_file_handle():
                return 'writable'
            if arg_looks_like_readable_file_handle():
                return 'readable'
            return 'neither_writable_nor_readable'  # idk

        def narrative_shape_type():
            if arg_looks_like_string():
                return 'string'
            if arg_looks_like_file_handle():
                return 'file_resource'
            return type(x).__name__  # ick/meh. not covered

        def arg_looks_like_writable_file_handle():  # assume ..
            return x.writable()

        def arg_looks_like_readable_file_handle():  # assume below
            return x.readable()

        def arg_looks_like_file_handle():
            return hasattr(x, 'fileno')

        def arg_looks_like_string():
            return hasattr(x, 'isalnum')

        return locals()

    class lazy_classifier:
        mixed_collection_identifier = x

    def build_method(f):
        return property(lambda _: f())

    for attr, f in these().items():
        setattr(lazy_classifier, attr, build_method(f))
    return lazy_classifier()


# == models

class _StorageAdapter:  # move this to its own file if it gets big

    def __init__(self, module, key):
        self.module = module
        self.key = key

    def CREATE_COLLECTION(self, collection_path, listener, is_dry):
        xx()
        coll = self.module.CREATE_COLLECTION(collection_path, listener, is_dry)
        if coll is None:
            return
        return _wrap_collection(coll)


def _wrap_collection(impl):
    if impl is None:
        return
    raise RuntimeError('xx')
    # return _Collection(impl)


# == The Case Experiment (will move to [#504] soon as we want it elsewhere)

def _build_case_function(listener=_listener):
    def case(*one_or_two_args):
        num_args = len(one_or_two_args)
        if 1 == num_args:
            def test_this_condition(condition):
                if condition():
                    return True
                conditions_seen.append(condition.__name__)

            def explain():
                return do_explain(conditions_seen, when_X_is, num_args)

            when_X_is, = one_or_two_args
        else:
            def test_this_condition(condition):
                if act_x == condition:
                    return True
                conditions_seen.append(condition)

            def explain():
                return do_explain(conditions_seen, when_X_is, num_args, act_x)

            act_x, when_X_is = one_or_two_args
        conditions_seen = []

        for condition, consequence in when_X_is():
            if test_this_condition(condition):
                return consequence()

        def do_explain(conditions_seen, when_X_is, num_args, instance_x=None):
            func = _case_lib()._explain_case_failure
            return func(conditions_seen, when_X_is, num_args, instance_x)

        listener('error', 'expression', 'no_case_matched', explain)
    return case


# == Whiners

def _emit_about_nonworking_stub(listener, sa, cstacker=None):
    def structurer():  # #not-covered, kind of crazy
        dct = _flatten_context_stack(cstacker()) if cstacker else {}
        mod = sa.module
        moniker = repr(sa.key)
        if hasattr(mod, 'STORAGE_ADAPTER_UNAVAILABLE_REASON'):
            def f(s):
                return f"the {moniker} storage adapter is"
            msg = mod.STORAGE_ADAPTER_UNAVAILABLE_REASON
            use_msg = _re_lib().sub(r"^[Ii]t( is|'s)\b", f, msg)
            dct['reason_tail'] = use_msg
        else:
            dct['reason_tail'] = repr(sa.key)
        return dct
    listener(*_EC_for_cannot_load,
             'storage_adapter_is_not_available', structurer)


def _emit_about_not_directory_based(listener, sa, cstacker):
    def structurer():  # (Case1421)
        dct = _flatten_context_stack(cstacker())
        dct['reason'] = ''.join(__pieces_for_not_dir_based(sa))
        return dct
    listener(*_EC_for_cannot_load,
             'storage_adapter_is_not_directory_based', structurer)


def __pieces_for_not_dir_based(sa):
    mod = sa.module
    can_single = mod.STORAGE_ADAPTER_CAN_LOAD_SCHEMALESS_SINGLE_FILES
    if can_single:
        extensions = mod.STORAGE_ADAPTER_ASSOCIATED_FILENAME_EXTENSIONS
    is_available = mod.STORAGE_ADAPTER_IS_AVAILABLE
    if can_single:
        yield f"the '{sa.key}' storage adapter is single-file only, "
        yield "so the collection cannot have a directory and a schema file"
        if len(extensions):
            _these = ' or '.join(repr(s) for s in extensions)
            yield f". the collection should be in a file ending in {_these}"
        else:
            yield ", however there are no file extensions associated with "
            yield "the storage adapter, so nothing makes any sense"
    elif is_available:
        yield f"the '{sa.key}' storage adapter "
        yield "has no relationship to the filesystem"
    else:
        yield f"the '{sa.key} storage adapter is not available"


def _emit_about_first_field_name(listener, cstacker):
    def structurer():  # (Case1418)
        dct = _flatten_context_stack(cstacker())
        dct['expecting'] = '"storage_adapter" as field name'
        return dct
    listener(*_EC_for_cannot_load,
             'unexpected_first_field_of_schema_file', structurer)


def _emit_about_empty_schema_file(listener, reason_head, parse_state):
    def structurer():
        if 'effectively_empty_file' == reason_head:
            use_head = "schema file is effectively empty"
        elif 'literally_empty_file' == reason_head:
            use_head = "schema file is literally empty"
        else:
            assert(False)
        path = parse_state.path
        _reason = f"{use_head} - {path}"
        return {'reason': _reason, 'path': path}
    listener(*_EC_for_cannot_load,
             'first_field_of_schema_file_not_found', structurer)


def _emit_about_no_schema_file(listener, file_not_found):
    def structurer():  # (Case1413)
        return func(file_not_found)
    from modality_agnostic import \
        emission_details_via_file_not_found_error as func
    listener(*_EC_for_cannot_load, 'no_schema_file', structurer)


def _emit_about_no_extname(listener, path):
    def structurer():  # (Case1411)
        _reason = (
            f"cannot infer storage adapter from file with no extension - "
            f"{path}")
        return {'reason': _reason}
    listener(*_EC_for_cannot_load, 'file_has_no_extname', structurer)


def _emit_about_extname(listener, extname, key_via_extname):
    def structurer():  # (Case1410)
        return _same_splay_reason('extension', extname, key_via_extname)
    listener(*_EC_for_cannot_load, 'unrecognized_extname', structurer)


def _emit_about_format_name(listener, format_name, key_via_format_name):
    def structurer():
        return _same_splay_reason('format name', format_name, key_via_format_name)  # noqa: E501
    listener(*_EC_for_cannot_load, 'unrecognized_format_name', structurer)


def _same_splay_reason(noun_singular, wrong, key_via_what):
    _head = f"unrecognized {noun_singular} '{wrong}'"
    _these = ', '.join(f"'{s}'" for s in sorted(key_via_what.keys()))
    _tail = f"known {noun_singular}(s): ({_these})"
    _reason = f'{_head}. {_tail}'
    return {'reason': _reason}


def _emit_about_SA_key(listener, key, order, cstacker):
    def structurer():  # (Case1419)
        dct = _flatten_context_stack(cstacker())
        _these = ', '.join(repr(s) for s in order)
        dct['reason'] = (f"unknown storage adapter {repr(key)}. "
                         f"known storage adapters: ({_these})")
        return dct
    listener(*_EC_for_cannot_load, 'unknown_storage_adapter', structurer)


def _say_extname_collision(en, first_key, second_key):
    if True:
        _reason = (f"Extname collison: '{en}' associated with both"
                   f"'{first_key}' and '{first_key}'. There can only be one.")
        return _reason


def _key_via_storage_adapter_module(sa_mod):
    name = sa_mod.__name__
    return name[name.rindex('.')+1:]


# == Smalls

def _is_directory_based(mod):
    db = mod.STORAGE_ADAPTER_CAN_LOAD_DIRECTORIES
    sfb = mod.STORAGE_ADAPTER_CAN_LOAD_SCHEMALESS_SINGLE_FILES
    if db:
        assert not sfb
        return True
    assert sfb


def _throwing_listener_and_stop(listener):

    def throwing_listener(sev, *rest):
        listener(sev, *rest)
        if 'error' == sev:
            raise stop()

    class stop(RuntimeError):
        pass

    return throwing_listener, stop


def _flatten_context_stack(context_stack):  # #[#510.14]
    return {k: v for row in context_stack for k, v in row.items()}


def _no_op():
    pass


# == Libs

def _re_emit_case_error_CRAZILY(listener, stack, emi_tup):
    _case_lib().re_emit_case_error_CRAZILY(listener, stack, emi_tup)


def _case_lib():
    import kiss_rdb.magnetics_.state_machine_via_definition as module  # will r
    return module


def _stack_function():
    from inspect import stack as func
    return func


def _null_context(x):
    from contextlib import nullcontext as func
    return func(x)


def _contextmanager():
    from contextlib import contextmanager as decorator
    return decorator


def _re_lib():
    import re
    return re


def xx(msg=None):
    raise RuntimeError(''.join(('write me', *((': ', msg) if msg else ()))))


_this_shape = ('error', 'structure')
_EC_for_cannot_load = (*_this_shape, 'cannot_load_collection')
_EC_for_not_found = (*_this_shape, 'cannot_load_collection')

# #history-B.5
# #history-B.4
# #history-A.2: massive refactor for clarity
# #history-A.1
# #born.
