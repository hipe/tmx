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

    yes = hasattr(sa_mod, 'ADAPTER_OPTIONS_VIA_SCHEMA_FILE_SCANNER')
    if yes:
        yes = kw.pop('do_load_schema_from_filesystem', True)
        assert yes is not None  # unless you're really sure

    if yes:
        ok = _parse_and_munge_or_dont(kw, cci, sa, listener)
        if not ok:
            return

    return _collection_via(sa, cci, listener, kw)


def _parse_and_munge_or_dont(kw, cci, sa, listener):
    dct = _parse_schema_file_when_you_know_SA_already(cci, sa, listener)
    if dct is None:
        return
    # Munge our namespace and adpater namespace, or don't (2nd time)
    for k, v in dct.items():
        if k in kw:
            xx(f"decide on munging policy: {k!r}")
            continue
        kw[k] = v
    return True


def _collection_via(sa, cci, listener, kw):
    # exactly [#857.D] (subgraph B)

    def main():
        return when_directory_based() if is_dir_based() else when_file_based()

    def when_file_based():
        if hasattr(sa.module, 'CUSTOM_FUNCTIONSER'):  # (not in flowchart grap)
            return build_collection('custom_IO')

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
            yield 'readable_only', when_file_is_readable_not_writable
            yield 'writable_only', when_file_is_writable_not_readable
            yield 'readable_writable', when_file_is_readable_and_writable
        return case(cci.narrative_writable_or_readable, when_file_resource_is)

    # == Consequences

    def do_directory_based():
        return build_collection('directory_based_IO')

    def when_file_is_readable_and_writable():
        return build_collection('readable_writable_based_IO')

    def when_file_is_writable_not_readable():
        return build_collection('write_only_based_IO')

    def when_file_is_readable_not_writable():
        return build_collection('read_only_based_IO')

    def when_file_based_and_string():
        return build_collection('path_based_IO')

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

    # "Idiom" determines function categories ([R][W]) and binding strategy
    idi = _IO_idiom_via_type(which)

    # Determine what the capabilities are and prepare binding strategies
    # (ALL of this binding logic is VERY experimental)

    not_sure = kw.pop('value_functions', None)
    if_here = kw.pop('value_function_variables', None)

    opn = kw.get('opn')

    # Let SA's specify defaults in function definitions (Case2609):
    nnkw = {k: v for k, v in kw.items() if v is not None}

    x = cci.mixed_collection_identifier
    mod = sa.module
    bind_editors, bind_readers = None, None

    if idi.is_file_based:
        fxr = mod.FUNCTIONSER_FOR_SINGLE_FILES(**nnkw)
        edit_funcser = fxr.PRODUCE_EDIT_FUNCTIONS_FOR_SINGLE_FILE
        read_funcser = fxr.PRODUCE_READ_ONLY_FUNCTIONS_FOR_SINGLE_FILE
        bind_editors = _bind_editors_for_single_file
        bind_readers = _bind_readers_for_single_file
        ssm = None
        if idi.is_open_resource:
            ssm = _seek_state_machine(x, crazy_listener)

    elif idi.is_directory_based:
        fxr = mod.FUNCTIONSER_VIA_DIRECTORY_AND_ADAPTER_OPTIONS(
            x, crazy_listener, **kw)
        edit_funcser = fxr.PRODUCE_EDIT_FUNCTIONS_FOR_DIRECTORY
        read_funcser = fxr.PRODUCE_READ_ONLY_FUNCTIONS_FOR_DIRECTORY
    else:
        # Get custom bindings from the SA lazily, only as-needed per category
        assert idi.is_custom
        fxr = mod.CUSTOM_FUNCTIONSER(cci, crazy_listener, **nnkw)
        if fxr is None:
            return
        edit_funcser = fxr.PRODUCE_EDIT_FUNCTIONS_CUSTOMLY
        read_funcser = fxr.PRODUCE_READ_FUNCTIONS_CUSTOMLY

    # See if any required capabilities are missing, and apply the bindings

    do_edit, do_read, missing = False, False, []
    if idi.write:
        if edit_funcser:
            do_edit = True
            edit_funcs = edit_funcser()  # or maybe lazy
            if bind_editors:
                edit_funcs = bind_editors(idi, ssm, x, edit_funcs, opn)
        elif 'need' == idi.write:
            missing.append('write')
    if idi.read:
        if read_funcser:
            do_read = True
            read_funcs = read_funcser()  # or maybe lazy
            if bind_readers:
                read_funcs = bind_readers(idi, ssm, x, read_funcs, opn)
        elif 'need' == idi.read:
            missing.append('read')

    if missing:
        xx(f"fun! {sa.key} does not define {', '.join(missing)}")

    assert idi.read or idi.write  # per the rule table above

    # Similar to above, crazy experimental custom API

    has_custom_functions = False
    if (cfuncs := getattr(fxr, 'CUSTOM_FUNCTIONS_VERY_EXPERIMENTAL', None)):
        def tuple_via_attr(attr):
            orig_f = getattr(cfuncs, attr)
            assert orig_f.is_reader

            def use_f(*args):
                @_contextmanager()
                def cm():
                    if (opened := opener(args[-1])) is None:
                        yield None  # 😩
                        return
                    with opened as fh:
                        yield orig_f(fh, *args)

                return cm()
            return attr, use_f

        opener = _build_opener(idi, ssm, x, opn)  # redundant with #here5

        import inspect as ins
        attrs = (tup[0] for tup in ins.getmembers(cfuncs, ins.isfunction))
        customs = tuple(tuple_via_attr(attr) for attr in attrs)
        has_custom_functions = len(customs)

    # Money

    def parse_identifier(orig_f):  # #decorator
        def use_f(eid, *rest):
            iden_er = iden_er_er(rest[-1])
            if (iden := iden_er(eid)) is None:
                return
            return orig_f(iden, *rest)
        return use_f

    iden_er_er = None
    # The identifier function can be defined by the functionser..
    if (f := fxr.PRODUCE_IDENTIFIER_FUNCTIONER):
        iden_er_er = f()

    # .. but then it can be overridden with an injection
    if (f := kw.get('iden_er_er')):
        assert iden_er_er  # not necessary at all. just hello from (Case2744)
        iden_er_er = f

    class collection_facade:  # #class-as-namespace
        if do_edit:
            def dig_for_edit_agent(agent_path, listener=_listener):
                if isinstance(agent_path, str):
                    agent_path = ((agent_path, agent_path),)
                return edit_funcs.dig_for_edit_agent(
                    agent_path, collection_facade, listener)

            @parse_identifier
            def update_entity(iden, x, listener):
                return edit_funcs.update_entity_via_identifier(
                    iden, x, listener)

            def create_entity(x, listener, eid=None, is_dry=False):
                return edit_funcs.create_entity_via_identifier(
                    eid, iden_er_er, x, listener, is_dry=is_dry)

            @parse_identifier
            def delete_entity(iden, listener):
                return edit_funcs.delete_entity_via_identifier(
                    iden, listener)

        if do_edit and not idi.is_directory_based:  # oh man. maybe one day
            def open_collection_to_write_given_traversal(listener):
                return edit_funcs._open_coll_for_passthru_write(listener)

        if do_read:
            def retrieve_entity(eid, listener=None):
                if (iden := iden_er_er(listener)(eid)) is None:
                    return
                return read_funcs.retrieve_entity_via_identifier(iden, listener)  # noqa: E501

            def retrieve_entity_via_identifier(iden, listener):
                return read_funcs.retrieve_entity_via_identifier(iden, listener)  # noqa: E501

            def open_identifier_traversal(listener):
                return read_funcs.open_identifier_traversal(listener)

            def open_EID_traversal_EXPERIMENTAL(listener):
                return read_funcs.open_EID_traversal_EXPERIMENTAL(listener)

            def open_entity_traversal(listener):  # #todo: use conversion
                @_contextmanager()
                def cm():
                    cm = collection_facade.open_schema_and_entity_traversal(listener)  # noqa: E501
                    two = cm.__enter__()
                    try:
                        # It's suppsed to be guaranteed that the above gives
                        # you a two-tuple. BUT neither component is guaranteed
                        # (IFF the second one is None it failed)
                        schema, ents = two
                        yield ents
                    finally:
                        cm.__exit__(None, None, None)
                return cm()

            def open_entities_via_EIDs(eids, listener):
                iden_via = iden_er_er(listener)
                itr = (iden_via(eid) for eid in eids)
                return read_funcs.open_entities_via_identifiers(itr, listener)

            def open_schema_and_entity_traversal(listener):
                return read_funcs.open_schema_and_entity_traversal(listener)

        def _to_noun_phrase():
            # (more complicated before #history-B.5, lost thing about variant)
            # (moved to this file at #history-B.4)
            sa_slug = sa.key.replace('_', '-')
            return ''.join(("the '", sa_slug, "' format adapter"))

        if (o := getattr(fxr, 'CUSTOM_FUNCTIONS_OLD_WAY', None)):
            custom_functions = o

        VALUE_FUNCTION_RIGHT_HAND_SIDES = not_sure
        VALUE_FUNCTION_VARIABLE_RIGHT_HAND_SIDES = if_here

        MIXED_COLLECTION_IDENTIFIER = x  # used by [pho] #cover-me
        storage_adapter = sa

    if has_custom_functions:
        for attr, use_f in customs:
            setattr(collection_facade, attr, use_f)
    return collection_facade


def _bind_editors_for_single_file(idi, ssm, x, funcs, opn):

    # mode 'r+': must exist. open for read & write. pointer at beginning
    mode = 'r+'
    opener = _build_opener(idi, ssm, x, opn, mode)
    open_writable = _build_binder(opener)

    def use_dig_for_agent(dig_path, coll, listener):
        if (agenter := _dig(funcs, coll, dig_path, listener)) is None:
            return
        return agenter(lambda: opener(listener))

    @open_writable
    def use_update(fh, iden, edit_x, listen):
        return funcs.UPDATE_VIA_FILEHANDLE(fh, iden, edit_x, listen)

    @open_writable
    def use_create(fh, eid, iden_er_er, dct, listen, is_dry=False):
        if is_dry:
            xx("have fun: drun run for single file")
        return funcs.CREATE_VIA_FILEHANDLE(fh, eid, iden_er_er, dct, listen)

    @open_writable
    def use_delete(fh, iden, listen):
        return funcs.DELETE_VIA_FILEHANDLE(fh, iden, listen)

    def pass_thru_write(listener):
        lv = funcs.lines_via_schema_and_entities

        @_contextmanager()
        def cm():
            # mode 'x': cannot first exist. create a new file and open it for w
            opened = opener(listener, 'x')
            if opened is None:
                yield None
                return
            with opened as fh:
                class traversal_receiver:  # #class-as-namespace, crazy flex
                    def receive_schema_and_entities(schema, ents, listen):
                        return _do_passthru_write(fh, schema, ents, lv, listen)
                yield traversal_receiver
            # (before #history-B.5 we ..used to fp.seek(0), fp.truncate(0), os_unlink(x))  # noqa: E501
        return cm()

    # ==

    class use_edit_funcs:  # #class-as-namespace
        dig_for_edit_agent = use_dig_for_agent
        update_entity_via_identifier = use_update
        create_entity_via_identifier = use_create
        delete_entity_via_identifier = use_delete
        _open_coll_for_passthru_write = pass_thru_write
    return use_edit_funcs


def _do_passthru_write(fp, schema, ents, lines_via_two, listener):
    total = 0
    for line in lines_via_two(schema, ents, listener):
        total += fp.write(line)
    return total


def _bind_readers_for_single_file(idi, ssm, x, funcs, opn):
    # (A lot of this could be tightened but: for now, redundancy for clarity)

    opener = _build_opener(idi, ssm, x, opn)
    open_readable = _build_binder(opener)  # #here5

    # Does the single-file SA want to implement its own random access?

    if (rtrv := getattr(funcs, 'RETRIEVE_VIA_FILEHANDLE', None)):
        @open_readable
        def use_retrieve(fh, iden, listener):
            return rtrv(fh, iden, listener)
    else:
        @open_readable
        def use_retrieve(fh, iden, listener):
            return retrieve_in_linear_time(fh, iden, listener)

    def retrieve_in_linear_time(fp, iden, listener):
        _schema, ents = sch_ents_via_fp_er()(fp, listener)
        # .. probably return if ents is None ..

        for ent in ents:
            curr_iden = ent.identifier
            if iden == curr_iden:
                return ent
            xx()

    def iden_trav(listener):  # for now you get it "for free" and no cust
        @_contextmanager()
        def cm():
            opened = sch_en(listener)
            sch, ents = opened.__enter__()
            try:
                yield ents and (e.identifier for e in ents)
            finally:
                opened.__exit__(None, None, None)
        return cm()

    def sch_en(listener):
        sch_ents_via_two = sch_ents_via_fp_er()

        @_contextmanager()
        def cm():
            opened = opener(listener)
            if opened is None:
                return
            with opened as fh:
                yield sch_ents_via_two(fh, listener)
        return cm()

    def sch_ents_via_fp_er():
        return funcs.schema_and_entities_via_lines

    # ==

    class use_read_funcs:  # #class-as-namespace
        retrieve_entity_via_identifier = use_retrieve
        open_identifier_traversal = iden_trav
        open_schema_and_entity_traversal = sch_en
    return use_read_funcs


# == Binding
#    "binding" is what allows the methods of single-file-based SA's to have
#    that "fh" as the first argument, but we as the outer shell "collection"
#    façade bury that resource management away as an abstraction

def _build_binder(opener):
    def decorator(orig_f):
        def use_f(*args, **kw):
            opened = opener(args[-1])
            if opened is None:
                return
            with opened as fh:
                return orig_f(fh, *args, **kw)
        return use_f
    return decorator


def _build_opener(idi, ssm, x, opn, *mode):
    if idi.is_open_resource:
        return _build_opener_for_open_resource(ssm.prepared_file_handle)

    assert idi.is_file_based and not idi.is_open_resource

    def opener(listener, *other_mode):
        use_mode = other_mode if len(other_mode) else mode
        try:
            return (opn or open)(x, *use_mode)  # ..
        except FileNotFoundError as e:  # #here4
            exe = e
        emit_about_no_ent(listener, exe)
    return opener


def _build_opener_for_open_resource(file_handle_er):
    def opener(_listener, *mode):
        return _null_context(file_handle_er())  # (Case1062DP)
    return opener


# == "Seek State Machine": rewind open filehandles as necessary

def _seek_state_machine(fp, listener):
    """
    Consider what happens when we apply these operations to a markdown file:
    - traverse (ents/ids): traverse whole file to ensure no multi-table
    - retrieve: (same as above) and to ensure no dups (imagine)
    - delete: (same as above)
    - update: (same as above)
    - create: traverse whole file once to index idens, then 2nd time to rewrite

    Note each operation does a full traversal (or might want to), and at
    least one operation requires more than one traversal. (In reality it
    seems like it depends on the implementation.. These may all be one-shot)

    If we were passed an open resource, the contract is: we don't close it.

    However, if the façade is used for more than one operation or the operation
    requires more than one traversal, the file pointer will be at the end of
    the file and the file (and so collection) will appear empty.

    So for sessions requiring multiple traversals, it will be necessary to
    rewind the file pointer to the beginning of input in between traversals.

    However, non-interactive terminals (STDIN/STDOUT/STDERR) can't be
    meaningfully rewound..  (#[#873.26] whether and how we seek(0))
    """

    class sm:
        def __init__(self):
            self._is_first_call = True

        def prepared_file_handle(self):
            if self._is_first_call:
                self._is_first_call = False
                return fp
            if fp.isatty():
                xx("can't rewind a TTY.. ")
            fp.seek(0)  # this IS :[#873.26]
            return fp
    return sm()


# == IO Idioms

def _define_IO_idioms():
    # there are (say) 3 functionser types and then these N idioms. it's interna

    def directory_based_IO():
        yield 'is_directory_based', True, 'read', 'want', 'write', 'want'

    def path_based_IO():
        yield 'is_file_based', True, 'read', 'want', 'write', 'want'

    def readable_writable_based_IO():
        yield 'is_open_resource', True
        need_or_want = 'need'  # not sure
        yield 'read', need_or_want, 'write', need_or_want

    def write_only_based_IO():
        yield 'is_open_resource', True, 'write', 'need'

    def read_only_based_IO():
        yield 'is_open_resource', True, 'read', 'need'

    def custom_IO():
        yield 'is_custom', True, 'read', 'want', 'write', 'want'

    return locals()


def _IO_idiom_via_type(typ):
    memo = _IO_idiom_via_type
    if memo.func is None:
        memo.func = _build_IO_idiom_via_type()
    return memo.func(typ)


_IO_idiom_via_type.func = None


def _build_IO_idiom_via_type():
    def dereference(k):
        if k not in memo:
            memo[k] = build_idiom(k)
        return memo[k]

    def build_idiom(k):
        def_func = def_func_via_k[k]
        cel_iters = (iter(row) for row in def_func())
        dct = {k: next(cel_iter) for cel_iter in cel_iters for k in cel_iter}
        return _Idiom(**dct)

    def_func_via_k = {k: f for k, f in _define_IO_idioms().items()}
    memo = {}
    return dereference


class _Idiom:
    def __init__(
            self, read=None, write=None,
            is_directory_based=None, is_file_based=None, is_open_resource=None,
            is_custom=None):
        (locs := {k: v for k, v in locals().items()}).pop('self')
        assert read or write
        if is_open_resource:
            locs['is_file_based'] = True
        for attr, v in locs.items():
            setattr(self, attr, v)


# == Dig

def _dig(funcs, coll, key_desc_pairs, listener):
    key_desc_pairs = tuple(key_desc_pairs)
    assert len(key_desc_pairs)
    assert all('_' != k[0] for k, _ in key_desc_pairs)  # make sure no names..
    say_collection = coll._to_noun_phrase
    from kiss_rdb.magnetics.via_collection import DIGGY_DIG as func
    return func(funcs, key_desc_pairs, say_collection, listener)


# == Resolving schema & storage adapter (from collection path)

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
        if self.SA:
            xx('lol think about this a little')
        x = cci.mixed_collection_identifier
        two = _SA_opts_via_parse_schema(x, saidx, opn, throwing_listener)
        assert two  # otherwise a stop should have been raised above
        self.SA, self.adapter_opts = two

    # == Mechanics

    def crazy_listener(sev, *rest):
        if 'error' != sev:
            return listener(sev, *rest)
        stack = _stack_function()()
        _re_emit_case_error_CRAZILY(throwing_listener, stack, (sev, *rest))

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


# sfs = schema file scanner


def _SA_opts_via_parse_schema(x, saidx, opn, listener):
    # again we try to hew as close as possible to flowchart [#857.D]

    # What you do while the schema file is open:
    def main(out, fx):
        sfs = out.schema_file_scanner

        fx.resolve_first_field_line()
        field = out.field

        fx.check_that_first_field_line_has_a_particular_name()

        def validate(sa):
            if sa.module.STORAGE_ADAPTER_CAN_LOAD_DIRECTORIES:
                return True
            return _emit_about_not_directory_based(listener, sa, cstacker)

        def cstacker():
            return (sfs.contextualize_about_field_value({}, field),)

        sa = saidx.storage_adapter_via_key(
            field.field_value_string, listener, cstacker, validate)
        return sa and (sfs, sa)

    opened = _open_schema_file(x, listener, opn)
    if opened is None:
        return

    with opened as opened:
        sfs_sa = _schema_parse_narrator(opened, main, listener)
        if sfs_sa is None:
            return
        sfs, sa = sfs_sa
        dct = sa.module.ADAPTER_OPTIONS_VIA_SCHEMA_FILE_SCANNER(sfs, listener)
        if dct is None:
            return
        return sa, dct


def _parse_schema_file_when_you_know_SA_already(cci, sa, listener):
    sa_mod = sa.module
    assert cci.arg_looks_like_string
    coll_path = cci.mixed_collection_identifier
    opened = _open_schema_file(coll_path, listener)
    if opened is None:
        return

    def main(out, fx):
        sfs = out.schema_file_scanner

        fx.resolve_first_field_line()
        field = out.field

        fx.check_that_first_field_line_has_a_particular_name()

        have = field.field_value_string
        expect = sa.key

        if expect != have:
            xx("did you try to use the wrong adapter on a collection? "
               f"expected {expect!r} had {have!r}")

        return sa_mod.ADAPTER_OPTIONS_VIA_SCHEMA_FILE_SCANNER(sfs, listener)

    with opened as opened:
        return _schema_parse_narrator(opened, main, listener)


def _open_schema_file(coll_path, listener, opn=None):

    from kiss_rdb import SCHEMA_FILE_ENTRY_ as tail
    from os.path import join as os_path_join
    schema_path = os_path_join(coll_path, tail)
    try:
        return (opn or open)(schema_path)
    except FileNotFoundError as e:  # #here4
        args = (e,)
        func = _emit_about_no_schema_file
    except NotADirectoryError:
        args = (coll_path,)
        func = _emit_about_no_extname
    func(listener, *args)


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


def _schema_parse_narrator(opened, main, listener):

    export, controllerer = _export_and_controllerer()

    @export
    def check_that_first_field_line_has_a_particular_name():
        if 'storage_adapter' == reso.field.field_name:
            return

        def cstacker():
            return (scanner.contextualize_about_field_name({}, reso.field),)
        _emit_about_first_field_name(listener, cstacker)
        raise stop()

    @export
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
    from kiss_rdb.magnetics_.schema_file_scanner_via_recfile_scanner \
        import func
    scanner = func(scn)
    reso.schema_file_scanner = scanner

    class stop(RuntimeError):
        pass

    controller = controllerer()
    controller.stop = stop

    try:
        return main(reso, controller)
    except stop:
        pass


def _classify_collection_identifier(x):  # #testpoint
    # exists only to DRY up any logic to be shared between the two new ways

    def these():
        def narrative_writable_or_readable():  # assume
            if arg_looks_like_readable_file_handle():
                if arg_looks_like_writable_file_handle():
                    return 'readable_writable'
                return 'readable_only'
            if arg_looks_like_writable_file_handle():
                return 'writable_only'
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
    func = _emission_details_via_file_not_found_error
    listener(*_EC_for_cannot_load, 'no_schema_file', structurer)


def emit_about_no_ent(listener, e):  # [pho]
    func = _emission_details_via_file_not_found_error
    listener('error', 'structure', 'cannot_load_collection',
             'no_such_file_or_directory', lambda: func(e))


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


def _emission_details_via_file_not_found_error(exc):
    from modality_agnostic import \
        emission_details_via_file_not_found_error as func
    return func(exc)


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


def _export_and_controllerer():  # #[#this-is-a-thing]
    def export(orig_f):
        setattr(export, orig_f.__name__, orig_f)  # #watch-the-world-burn
        return orig_f
    return export, lambda: export


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

# #history-B.6: oops parse sch*ma file when loading coll directly too
# #history-B.5
# #history-B.4
# #history-A.2: massive refactor for clarity
# #history-A.1
# #born.
