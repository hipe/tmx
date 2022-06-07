"""We imagine this core file as having a lifecycle of three phases:

Phase 1: hand-written parser of a subset of the recfiles grammar
         just for parsing `schema.rec` files.
Phase 2: sub-process out to recutils executables, parse their results
Phase 3: use c-bindings

At writing (#history-B.7) we are making Phase 2. We don't want to break
the Phase 1 work: parsing the subset grammar by hand just to get schema.rec
to parse.

Ultimately we are interested in pursuing Phase 3, but that is out of scope
for now.

In transition from Phase 1 to Phase 2, we won't know exactly what to expect
from the recutils executables in terms of its output structure; so we will
hold off at first from eliminating all redundancies between 1 & 2 until
we have the new work of Phase 2 stable & covered.

One example of this being a challenge: at #here2 we complain when our
schema.rec files have a name collision of field names within one record.
But this is perfectly allowable in native recfiles.

This is the external thing: [GNU Recutils][1] (and this [example][2]).

Reminder: `recsel`

- At #history-B.7 we sub-process out to real recsel
- At #history-B.5 we added create collection
- At #history-B.4 we spike not-yet-covered prototype of collectionism (?)

[1]: https://www.gnu.org/software/recutils/
[2]: https://www.gnu.org/software/recutils/manual/A-Little-Example.html
"""

STORAGE_ADAPTER_CAN_LOAD_DIRECTORIES = False
STORAGE_ADAPTER_CAN_LOAD_SCHEMALESS_SINGLE_FILES = True
STORAGE_ADAPTER_ASSOCIATED_FILENAME_EXTENSIONS = ('.rec',)
STORAGE_ADAPTER_IS_AVAILABLE = True


def FUNCTIONSER_FOR_SINGLE_FILES():
    class fxr:  # #class-as-namespace
        PRODUCE_EDIT_FUNCTIONS_FOR_SINGLE_FILE = None

        def PRODUCE_READ_ONLY_FUNCTIONS_FOR_SINGLE_FILE():
            return _read_funcs

        PRODUCE_IDENTIFIER_FUNCTIONER = None
    return fxr


# == BEGIN #cover-me all of #history-B.4

class _read_funcs:  # #class-as-namespace

    def schema_and_entities_via_lines(lines, listener):
        return _schema_and_entities_via_lines(lines, listener)


def _schema_and_entities_via_lines(lines, listener):
    scn = ErsatzScanner(lines)
    itr = _chunks_of_fields(scn, listener)

    def entities():
        for chunk in itr:

            dct = {}
            for fld in chunk:
                k = fld.field_name
                if k in dct:  # #here2
                    raise RuntimeError(f"wat do: collision: {k!r}")
                dct[k] = fld.field_value_string

            yield _MinimalIdentitylessEntity(dct)

    return None, entities()


def LAZY_COLLECTIONS(main_recfile, main_fent_name, dataclasserer, renames=None):

    def retrieve_collection(_, k):
        if k not in cache:
            cache[k] = build_collection(k)
        return cache[k]

    cache = {}

    def build_collection(fent_name):
        cls = dataclasser()(fent_name)
        assert cls  # for now (but one day not)
        recfile = determine_recfile(fent_name)

        @lazy
        def name_converterer():
            maybe_two = (renames and renames(fent_name))
            return _build_name_converter(fent_name, maybe_two)

        return _build_collection(recfile, cls, name_converterer, colz)

    @lazy
    def dataclasser():
        return dataclasserer(colz)

    def determine_recfile(fent_name):
        if main_fent_name == fent_name:
            return main_recfile
        return ''.join(derive_recfile_pieces(fent_name))

    def derive_recfile_pieces(fent_name):
        from os.path import splitext
        head, ext = splitext(main_recfile)
        yield head
        atoms = list(_nccs().atoms_via_camel(fent_name))
        atoms[-1] = f"{atoms[-1]}s"  # LOOK PLURALIZE
        for atom in atoms:
            yield '-'
            yield atom
        yield ext

    class Collections:
        __getitem__ = retrieve_collection
    colz = Collections()
    import re
    return colz


def lazy(func):
    def use():
        if use.value is None:
            use.value = func()
        return use.value
    use.value = None
    return use


def _build_collection(recfile, dataclass, name_converterer, colz):

    def update_entity(eid, param_direcs, listener=None, is_dry=False):
        from kiss_rdb.storage_adapters_.rec._create_and_update import \
                UPDATE_ENTITY_ as func
        return func(eid, param_direcs, coll, colz, listener, is_dry)

    def create_entity(params, listener=None, is_dry=False):
        from kiss_rdb.storage_adapters_.rec._create_and_update import \
                CREATE_ENTITY_ as func
        return func(params, coll, colz, listener, is_dry)

    def retrieve_entity(eid, listener=None):
        if not _identifier_via_string(eid, listener):
            return
        return select({'EID': eid}, formal_arity=1, listener=listener)

    def select(kvs=None, formal_arity=None, order_by=None, listener=None):
        itr = do_select(kvs, order_by, listener)
        if formal_arity is None:
            return itr  # LOOK return multiple here
        assert 1 == formal_arity  # would be fun otherwise
        ent = next(itr, None)
        if not ent:
            _ = repr(kvs)
            reason = f"expecting one had none from {dataclass.__name__} {_}"
            return _integrity_error(listener, reason)
        ent_2 = next(itr, None)
        if ent_2:
            xx(f"expecting one had multiple from {dataclass.__name__} {_}")
        return ent  # LOOK return one here

    def do_select(kvs, order_by, listener):
        denativizer = denativizerer()
        _ = recfile_args_via(kvs, order_by)
        recfile_args = tuple(s for row in _ for s in row)
        for raw in _native_records_via_recsel(recfile, recfile_args, listener):
            dct = denativizer(raw)  # ..
            yield dataclass(**dct)

    def recfile_args_via(kvs, order_by):
        yield (f'-t{name_converterer().store_record_type}',)
        if kvs:
            yield '-e', expression_token_via(kvs)
        if order_by:
            store_k = name_converterer().store_key_via_use_key(order_by)
            yield (f"-S{store_k}",)  # we yield tuples. One token because cute

    def expression_token_via(kvs):
        return ','.join(expression_token_components(kvs))

    def expression_token_components(kvs):
        for k, v in kvs.items():
            store_k = name_converterer().store_key_via_use_key(k)
            if not re.match(r'^[A-Za-z_]+$', store_k):
                xx(repr(store_k))
            if not re.match(r'[A-Za-z0-9_ ]+$', v):
                xx(f"ugh you need an escape function {v!r}")
            yield f'{store_k}="{v}"'

    @lazy
    def denativizerer():
        abs_ent = abstract_entity_via_dataclass()  # ..
        return _denativizer_via_abstract_entity(abs_ent, name_converterer)

    def build_store_fent(listener):
        store_fent_name = name_converterer().store_record_type
        from kiss_rdb.storage_adapters_.rec.abstract_schema_via_recinf import \
                abstract_entity_via_recfile_ as func
        return func(recfile, store_fent_name, listener=listener)

    build_store_fent.value = None

    @lazy
    def abstract_entity_via_dataclass():
        from kiss_rdb.magnetics_.abstract_schema_via_definition import \
                abstract_entity_via_dataclass as func
        return func(dataclass)

    import re

    class Collection:
        def where(_, *args, **kwargs):
            return select(*args, **kwargs)

        def EXPERIMENTAL_HYBRIDIZED_FORMAL_ENTITY_(self, listener):
            if not self._cached_hybrid_fent:
                # (we cache it, would otherwise be built 2x in UPDATE who fails)
                self._cached_hybrid_fent = _build_hybrid_fent(listener)
            return self._cached_hybrid_fent

        @property
        def abstract_entity_derived_from_dataclass(_):
            return abstract_entity_via_dataclass()

        def abstract_entity_derived_from_store(_, listener=None):
            memo = build_store_fent
            if memo.value is None:
                memo.value = build_store_fent(listener)
            return memo.value

        @property
        def name_converter(_):
            return name_converterer()

        @property
        def fent_name(self):
            return dataclass.__name__

        _cached_hybrid_fent = None


    def _build_hybrid_fent(listener):
        from kiss_rdb.storage_adapters_.rec._hybrid_abstract_schema \
                import EXPERIMENTAL_HYBRIDIZED_FORMAL_ENTITY_VIA_ as func
        return func(coll, listener)

    coll = Collection()
    coll.update_entity = update_entity
    coll.create_entity = create_entity
    coll.retrieve_entity = retrieve_entity
    coll.recfile = recfile
    coll.dataclass = dataclass
    coll.name_converterer = name_converterer
    return coll


"""Introducing "denativizers"
    "native" records (in functions below) come from storage with:
    - Each value is an array of the line right-hand-sides
    - Each component of the array is newline terminated
    - There's no assurance that your optionality is followed (required fields)
    The "denativized" record:
    - "atomic" values are not arrays but single string values (maybe one day etc)
    - values that should be newline-terminated strings stay that way, else not
    - assert optionaity (make sure required fields are there)
    - maybe something about calling the factories that dataclasses have
    """

def _denativizer_via_abstract_entity(absent, name_converterer):

    def denativize(dct):
        return {k: v for k, v in do_nativize(dct)}

    def do_nativize(dct):
        not_seen = {k: None for k in required_use_keys}
        for native_k, native_v in dct.items():
            use_k = use_attr_via_native_attr.get(native_k)
            if not use_k:
                raise IntegrityError(explain_strange_key(native_k))
            use_v = attribute_denativizers[use_k](native_v)
            if use_v is None:
                continue
            not_seen.pop(use_k, None)
            yield use_k, use_v
        if not not_seen:
            return
        xx(f"missing required key(s): {tuple(not_seen.keys())!r}")

    def attribute_denativizers():
        for fattr in absent.to_formal_attributes():
            yield fattr.column_name, denativizer_for(fattr)

    def denativizer_for(fattr):
        def denativize(line_tail_list):
            if early_factory:
                return early_factory(line_tail_list)
            if do_chop:
                strings = tuple(chop(line) for line in line_tail_list)
            else:
                strings = tuple(line_tail_list)
            if is_plural:
                return strings
            one_string, = strings  # assertion
            if late_factory:
                return late_factory(one_string)
            return one_string

        early_factory = None  # placeholder for the idea for now

        tm = fattr.type_macro
        use_k = fattr.column_name

        # Derive requiredness from "can be null"
        if not fattr.null_is_OK:
            required_use_keys.append(use_k)  # LOOK

        # Derive pluralness (and some normalizers) from type macro
        these = _IS_PLURAL_and_DO_CHOP_via_type_macro(tm)
        is_plural = these.is_plural
        do_chop = these.do_chop
        late_factory = these.late_factory

        # Derive store attr key from custom setting or this formula
        store_k = name_converterer().store_key_via_use_key(use_k)
        use_attr_via_native_attr[store_k] = use_k  # LOOK
        return denativize

    def explain_strange_key(native_k):
        who = name_converterer().store_record_type
        ks = tuple(use_attr_via_native_attr.keys())
        return f"Unrecognized store key {native_k!r} for {who}. Expecting {ks!r}"

    def chop(line):
        assert '\n' == line[-1]
        return line[:-1]

    use_attr_via_native_attr = {}  # LOOK
    required_use_keys = []  # LOOK
    attribute_denativizers = {k: v for k, v in attribute_denativizers()}
    required_use_keys = tuple(required_use_keys)
    return denativize


class _IS_PLURAL_and_DO_CHOP_via_type_macro:

    def __init__(self, tm):
        self.is_plural = False
        self.do_chop = True
        self.late_factory = None
        for attr, v in _do_IS_PLURAL_and_DO_CHOP(tm):
            setattr(self, attr, v)


def _do_IS_PLURAL_and_DO_CHOP(tm):
    if tm.kind_of('text'):
        return ()  # accept the defaults: is singular, do chop

    if tm.kind_of('tuple'):
        return _do_IS_PLURAL_and_DO_CHOP_when_tuple(tm)

    if tm.kind_of('int'):
        return _do_IS_PLURAL_and_DO_CHOP_when_int(tm)

    xx(f"have fun, we anticipate date[time]: {tm.string!r}. Also see here.")
    # If it's a different type of generic that's not tuple, then why?


def _do_IS_PLURAL_and_DO_CHOP_when_tuple(tm):
    # For now, we allow plural in the store IFF the dataclass uses tuple
    yield 'is_plural', True

    orig = tm.generic_alias_origin_
    if not orig:
        # (might be tests only) when this did't come from a dataclass, defaults)
        return

    assert tuple == orig  # (until it isn't..)

    arg, = tm.generic_alias_args_  # ..

    if isinstance(arg, str):
        # When the generic alias arg is a literal string, [#872.H] it's an EID
        # do chop which is the default.
        return

    if str == arg:
        # this is a tuple of strings which is how we represent paragraph
        yield 'do_chop', False
        return

    xx("interesting, new shape of generic alias ({tm.string!r)}")
    return


def _do_IS_PLURAL_and_DO_CHOP_when_int(tm):
    def late_factory(s):
        if re.match(r'^\d+$', s):  # ..
            return int(s)
        xx(f"have fun, should be integer: {s!r}")
    import re
    yield 'late_factory', late_factory


def _identifier_via_string(any_string, listener):
    def use_listener(*emi):
        if ('error', 'structure') == emi[:2]:
            reason = emi[-1]()['reason']
            emi = 'error', 'expression', *emi[2:-1], lambda: (reason,)
        listener(*emi)
    from kiss_rdb.magnetics_.identifier_via_string import \
            identifier_via_string_ as func
    return func(any_string, use_listener)


def _build_name_converter(fent_name, maybe_two):

    typ = dct = None
    if maybe_two:
        typ, dct = maybe_two

    def snake_via_camel(store_k):
        return _nccs().snake_via_camel(store_k)

    def camel_via_snake(use_k):
        return _nccs().camel_via_snake(use_k)

    def identity(same_k):
        return same_k

    # ==

    use_key_via_snake_store_key_normally = identity

    use_key_via_store_key_normally = snake_via_camel

    snake_store_key_via_use_key_normally = identity

    snake_store_key_via_store_key = snake_via_camel

    store_key_via_use_key_normally = camel_via_snake

    if dct:

        def use_key_via_snake_store_key(snake_store_k):
            rev_dct = memoized_use_key_via_snake_store_key()
            if (k := rev_dct.get(snake_store_k)):
                return k
            return use_key_via_snake_store_key_normally(snake_store_k)

        def use_key_via_store_key(store_k):
            rev_dct = memoized_use_key_via_store_key()
            if (k := rev_dct.get(store_k)):
                return k
            return use_key_via_store_key_normally(store_k)

        def memoized_use_key_via_snake_store_key():
            memo = memoized_use_key_via_snake_store_key
            if memo.value is None:
                memo.value = {k:v for k, v in build_use_key_via_snake_store_key()}
                assert len(memo.value) == len(dct)
            return memo.value

        def memoized_use_key_via_store_key():
            memo = memoized_use_key_via_store_key
            if memo.value is None:
                memo.value = {k: v for k, v in build_use_key_via_store_key()}
                assert len(memo.value) == len(dct)
            return memo.value

        memoized_use_key_via_snake_store_key.value = None
        memoized_use_key_via_store_key.value = None

        def build_use_key_via_snake_store_key():
            f = _nccs().snake_via_camel
            for use_k, store_k in dct.items():
                yield f(store_k), use_k

        def build_use_key_via_store_key():
            return ((v, k) for k, v in dct.items())

        def snake_store_key_via_use_key(use_k):
            if (k := dct.get(use_k)):
                return _nccs().snake_via_camel(k)
            return use_k

        def store_key_via_use_key(use_k):
            if (k := dct.get(use_k)):
                return k
            return store_key_via_use_key_normally(use_k)
    else:
        use_key_via_snake_store_key = use_key_via_snake_store_key_normally
        use_key_via_store_key = use_key_via_store_key_normally
        snake_store_key_via_use_key = snake_store_key_via_use_key_normally
        store_key_via_use_key = store_key_via_use_key_normally

    class name_converter:
        @property
        def name_convention_converters_(_):
            return _nccs()

    """
           UK
                v ^
         v ^      SSK
                v ^
           SK
    """

    nc = name_converter()
    nc.use_key_via_snake_store_key = use_key_via_snake_store_key
    nc.use_key_via_store_key = use_key_via_store_key
    nc.snake_store_key_via_use_key = snake_store_key_via_use_key
    nc.snake_store_key_via_store_key = snake_store_key_via_store_key
    nc.store_key_via_use_key = store_key_via_use_key
    nc.store_key_via_snake_store_key = store_key_via_use_key_normally
    nc.store_record_type = fent_name if typ is None else typ
    return nc


@lazy
def name_convention_converters_():  # nccs = name convention converters
    import re

    def export(func):
        setattr(export, func.__name__, func)  # #watch-the-world-burn
        return func

    @export
    def camel_via_snake(snake):
        atoms = atoms_via_snake(snake)
        return camel_via_atoms(atoms)

    @export
    def snake_via_camel(camel):
        atoms = atoms_via_camel(camel)
        return snake_via_atoms(atoms)

    def camel_via_atoms(atoms):
        return ''.join(do_camel_via_atoms(atoms))

    def do_camel_via_atoms(atoms):
        for atom in atoms:
            if rx_ALL_CAPS.match(atom):  # covered (e.g 'native_URL'). gonna bite
                yield atom
            else:
                yield atom[0].upper()
                yield atom[1:]

    rx_ALL_CAPS = re.compile('^[A-Z]+$')

    @export
    def atoms_via_camel(camel):
        humps = humps_via_camel(camel)
        for s in humps:
            if re.match('^[A-Z]+$', s):
                # Acronyms (like URL) stay
                yield s
            else:
                yield s.lower()

    @export
    def humps_via_camel(camel):  # ..
        assert re.match(f'^(?:[A-Z][a-z]*)+$', camel)
        return re.split('(?<=[a-z])(?=[A-Z])', camel)

    def snake_via_atoms(atoms):
        return '_'.join(atoms)

    def atoms_via_snake(snake):
        return snake.split('_')
    return export


_nccs = name_convention_converters_  # shorter name for local use


def _native_records_via_recsel(recfile, recsel_args, listener):
    with _open_recsel_process(recfile, recsel_args, listener) as lines:
        for rec_dct in _native_records_via_lines(lines, listener):
            yield rec_dct


def _native_records_via_lines(lines, listener):  # #testpoint
    # NOTE this intentionally has known holes in it, holding off until etc

    # from text_lib.magnetics.scanner_via import scanner_via_iterator as func
    # scn = func(lines)

    def from_before_record():
        yield if_field_line, process_field_line, from_inside_record

    def from_inside_record():
        yield if_field_line, process_field_line
        yield if_additional_line, process_additional_line
        yield if_blank_line, yield_record, from_before_record

    # == matchers

    def if_field_line():
        return 'field_line' == line_category

    def if_blank_line():
        return 'blank_line' == line_category

    def if_additional_line():
        return 'string_literal_additional_line' == line_category

    def categorize_line():
        state.colon_offset = None  # meh
        if '\n' == line:
            return 'blank_line'
        if '+' == line[0]:
            return 'string_literal_additional_line'
        state.colon_offset = line.index(':')  # also an assertion
        if True:
            return 'field_line'

    # == actions

    def process_additional_line():
        arr = state.experimental_mutable_record_dict[
                state.last_native_field_name]
        assert '+ ' == line[:2]
        arr.append(line[2:])

    def process_field_line():
        pos = state.colon_offset
        native_field_name = line[0:pos]
        state.last_native_field_name = native_field_name
        assert ' ' == line[pos+1]  # ..
        value_but = line[pos+2:]  # LEAVE NEWLINE IN for now #here3
        dct = state.experimental_mutable_record_dict
        if native_field_name in dct:
            arr = dct[native_field_name]
        else:
            dct[native_field_name] = (arr := [])
        arr.append(value_but)

    def yield_record():
        dct = state.experimental_mutable_record_dict
        state.experimental_mutable_record_dict = {}
        return 'yield_this', _finalize_native_record(dct)

    state = yield_record  # #watch-the-world-burn
    state.state_function = from_before_record
    state.experimental_mutable_record_dict = {}

    lineno = 0
    for line in lines:
        # Categorize line
        lineno += 1
        line_category = categorize_line()

        # Find matching transition
        found = False
        for two_or_three in state.state_function():
            found = two_or_three[0]()
            if found:
                break
        if not found:
            from_where = state.state_function.__name__.replace('_', ' ')
            xx(f"{from_where} had unexpected line: {line!r}")
        action, *rest = two_or_three[1:]
        if rest:
            next_state_function, = rest
        else:
            next_state_function = None

        # Do the action
        opcode = action()
        if opcode:
            directive, data = opcode
            assert 'yield_this' == directive
            yield data

        # Change the state (if any)
        if rest:  # (next state might be None):
            state.state_function = next_state_function

    # Not great, but meh:
    if len(state.experimental_mutable_record_dict):
        yield _finalize_native_record(state.experimental_mutable_record_dict)


def _finalize_native_record(dct):
    return dct  # this is a placeholder. we came up with "denativize" here


class _MinimalIdentitylessEntity:
    def __init__(self, core_attrs):
        self.core_attributes = core_attrs


def _chunks_of_fields(scn, listener):  # #[#508.2] chunker

    cache = []

    def flush():
        ret = tuple(cache)
        cache.clear()
        return ret

    while True:
        blk = scn.next_block(listener)
        if blk.is_field_line:
            cache.append(blk)
            continue
        if blk.is_separator_block:
            if cache:
                yield flush()
            continue
        if blk.is_end_of_file:
            break

    if cache:
        yield flush()


# == END

class ErsatzScanner:

    def __init__(self, open_filehandle):
        self._use_field_via_line = _field_via_line_function()
        self._lines = _LineTokenizer(open_filehandle)
        self.path = open_filehandle.name  # #here1

    def next_block(self, listener):
        if self._lines.empty:
            del self._lines
            return _END
        typ = self._lines.line_type
        if 'content_line' == typ:
            return self._finish_field(listener)

        assert 'separator_line' == typ
        return self._finish_separator_block()

    def _finish_field(self, listener):
        """
        SHAMELESSLY HACKING MULTI-LINE FIELDS
        (but we really need proper vendor parsing!)

        Interestingly, the vendor parser has to parse "field" lines
        right-to-left, because whether or not the line ends with a '\'
        determines whether to etc or to etc
        """

        tox = self._lines
        scn = tox._LINE_SCANNER_
        line = scn.peek

        # Take a snapshot of the "parser state" (line and linenumber) now,
        # for any errors that occur in creating the field. (Parsing multiline
        # field requires one line of lookahead so the line scanner is not a
        # reliable steward of these two.) If this is ugly, just pass the
        # line and line number as arguments to the requisite functions

        self.line = line
        self.lineno = tox.lineno
        tox.advance()

        if '\\' != line[-2]:  # (assume line has content)
            return self._field_via_line(line, listener)

        # MULTI-LINE

        raise("Hello this needs covering/work. Look at what we were up to")

        hax = self._field_via_line(line, listener)
        if hax is None:
            return

        pieces = [hax.field_value_string[:-1]]  # chop trailing backslash

        while True:
            line = scn.peek
            scn.advance()

            if scn.empty:
                xx("above line was continuator, now is EOF. not covering this")
            if '\n' == line:
                xx("we don't want to support a blank line after contination "
                   "for now because we haven't needed it yet")
            if '+' == line[0]:
                xx("no support for plus sign yet (but would be trivial) "
                   "because we never needed it yet")
            if '\\' == line[-2]:
                # This line is the continuation of the above line,
                # and also it is a continuator itself
                pieces.append(line[:-2])
                continue

            # This line is the continuation of the above line but not
            # itself a continuator
            pieces.append(line[:-1])
            break

        tox._UPDATE_()  # determine line type of current line
        hax.field_value_string = ''.join(pieces)  # EEK
        return hax

    def _finish_separator_block(self):
        lines = [self._lines.line]
        while True:
            self._lines.advance()
            if self._lines.empty:
                break
            if 'separator_line' != self._lines.line_type:
                break
            lines.append(self._lines.line)
        return _SeparatorBlock(tuple(lines))

    def _field_via_line(self, line, listener):
        return self._use_field_via_line(line, self._path_and_lineno, listener)

    def _path_and_lineno(self):
        return self.path, self.lineno


def _field_via_line_function():
    memo = _field_via_line_function
    if not hasattr(memo, 'the_value'):
        memo.the_value = _build_function_called_field_via_line()
    return memo.the_value


def _build_function_called_field_via_line():

    def field_via_line(line, path_and_lineno_er, listener):
        # we black-box reverse-engineer a TINY part of recfiles

        def use_listener(*a):
            # add these two more elements of context on parse error
            *chan, pay = a
            chan = tuple(chan)
            assert chan == ('error', 'structure', 'input_error')
            dct = pay()
            path, lineno = path_and_lineno_er()
            dct['path'] = path
            dct['lineno'] = lineno
            listener(*chan, lambda: dct)

        scn = StringScanner(line, use_listener)

        # Scan a field name
        field_name = scn.scan_required(field_name_pattern)
        if field_name is None:
            return  # (Case1414)

        # Recfiles does not allow space between field name and colon
        _did = scn.skip_required(colon)
        if not _did:
            return  # (Case1403)

        scn.skip(space)
        value_start_pos = scn.pos
        content_s = scn.scan_required(some_content)  # (Case1403) ⏛ [#873.5]
        if content_s is None:
            return

        # allow literal quotes in values since #history-B.6
        return _Field(field_name, content_s, value_start_pos)

    from text_lib.magnetics.string_scanner_via_string import \
            StringScanner, pattern_via_description_and_regex_string as o

    field_name_pattern = o('field name', r'[a-zA-Z][_a-zA-Z0-9]*')
    # (real recsel doesn't allow multbyte in first char, or dashes anywhere)

    colon = o('colon', ':')
    space = o('space', '[ ]+')
    some_content = o('some content', r'[^\n]+')

    return field_via_line


class _Field:
    # property names are derived from names used in /usr/local/include/rec.h
    # however, we have inflected the names further with local conventions

    def __init__(self, nn, vv, posov):
        self.field_name = nn
        self.field_value_string = vv
        self.position_of_start_of_value = posov

    position_of_start_of_field_name = 0  # ..
    is_separator_block = False
    is_field_line = True
    is_end_of_file = False


class _SeparatorBlock:
    def __init__(self, block):
        self.lines = block
    is_separator_block = True
    is_field_line = False
    is_end_of_file = False


class _END:  # #as-namespace-only
    is_separator_block = False
    is_field_line = False
    is_end_of_file = True


class _LineTokenizer:

    def __init__(self, fh):
        lib = _scnlib()
        self._scn = lib.scanner_via_iterator(fh)
        self._current_line_offset_via = lib.MUTATE_add_counter(self._scn)
        # (we use "peek" to mean "current line" yikes)
        self.line_type = None
        self._update()

    def advance(self):
        self._scn.advance()
        self._update()

    def _update(self):
        if self._scn.empty:
            del self.line_type
            return
        self.line_type = _line_type(self.line)

    _UPDATE_ = _update

    @property
    def line(self):
        return self._scn.peek

    @property
    def lineno(self):
        return self._current_line_offset_via() + 1

    @property
    def empty(self):
        return self._scn.empty

    @property
    def more(self):
        return self._scn.more

    @property
    def _LINE_SCANNER_(self):  # call UPDATE after advancing omg
        return self._scn


def _line_type(line):
    if '\n' == line:
        return 'separator_line'
    if '#' == line[0]:
        return 'separator_line'
    return 'content_line'

# ==

def _open_recsel_process(recfile, recsel_args, listener):

    if not isinstance(recfile, str):
        from contextlib import nullcontext
        return nullcontext(recfile)

    if listener:
        def express():
            yield f"recsel {' '.join(recsel_args)} {recfile}"
        listener('info', 'expression', 'recutils_command', 'recsel', express)

    import subprocess as sp
    proc = sp.Popen(
        args=('recsel', *recsel_args, recfile),
        shell=False,  # if true, the command is executed through the shell
        cwd='.',
        stdin=sp.DEVNULL,
        stdout=sp.PIPE,
        stderr=sp.PIPE,
        text=True,  # give me lines, not binary
    )

    def close_both():
        proc.stdout.close()
        proc.stderr.close()

    class ContextManager:
        def __init__(self):
            self.did_terminate = False  # here not __enter__ b.c iterator

        def __enter__(self):
            for line in proc.stdout:
                yield line

            lines = []
            maxi = 3
            did_reach_maxi = False
            for line in proc.stderr:
                if maxi == len(lines):
                    did_reach_maxi = True
                    break
                lines.append(line)

            rc = proc.wait()

            # (warnings if we don't do this)
            close_both()
            self.did_terminate = True

            rc_is_ok = 0 == rc
            if rc_is_ok and 0 == len(lines):
                return
            def lineser():
                if 0 == len(lines):
                    yield f"recsel had existatus: {rc}"
                    yield "(no messages to stderr?)"
                    return
                for line in lines:
                    yield line
                if rc_is_ok:
                    return
                yield f"(exitstatus: {rc})"
            (listener or _eek)('error', 'expression', 'recsel_failure', lineser)

        def __exit__(self, *_):
            if self.did_terminate:
                return
            proc.wait()
            close_both()

    return ContextManager()

# ==

def CREATE_COLLECTION(collection_path, listener, is_dry, opn=None):
    from ._create_collection import create_collection as func
    return func(collection_path, listener, is_dry, opn=opn)


# ==

def call_subprocess_(args, listener):
    import subprocess as sp
    proc = sp.Popen(
        args=args,
        shell=False,  # if true, the command is executed through the shell
        cwd='.',
        stdin=sp.DEVNULL,
        stdout=sp.PIPE,
        stderr=sp.PIPE,
        text=True,  # give me lines, not binary
    )

    def sout_lines():
        with proc.stdout as fh:
            for line in fh:
                yield line

    def serr_lines():
        with proc.stderr as fh:
            for line in fh:
                yield line

    sout_lines = tuple(sout_lines())
    serr_lines = tuple(serr_lines())

    if serr_lines:
        xx(f'write this to listener, e.g. {serr_lines[0]!r}')

    rc = proc.wait()
    if 0 != rc:
        xx(f"nonzero exitstatus without stderr lines? --> {rc} <--")

    return sout_lines


def _integrity_error(listener, reason):
    if not listener:
        raise IntegrityError(reason)
    listener('error', 'expression', 'integrity_error', lambda: (reason,))


def _eek(*emi):
    assert 'expression' == emi[1]
    raise IntegrityError(next(emi[-1]()))


class IntegrityError(RuntimeError):
    pass


def _scnlib():
    from text_lib.magnetics import scanner_via as module
    return module


def xx(msg=None):
    raise RuntimeError('ohai' + ('' if msg is None else f": {msg}"))


# #history-B.7
# #history-B.6
# #history-B.5
# #history-B.4
# #born.
