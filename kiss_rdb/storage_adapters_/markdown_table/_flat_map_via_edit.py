def cud_(all_sexpser, coll_path, opn, typ, cud_args, listener, grow_downwards):
    flat_map, state = _these_two_for[typ](*cud_args, grow_downwards, listener)
    from ._file_diff_via_flat_map import sync_agent_ as func
    sa = func(all_sexpser, coll_path)
    diff_lines = sa.DIFF_LINES_VIA(flat_map, listener)
    if diff_lines is None:
        return
    rv = state.result_value
    if opn.RECEIVE_DIFF_LINES(diff_lines):
        (f := flat_map.emit_edited) and f(rv)
        return rv


def _build_decorator():
    def flat_map_for_who(cud):
        def decorator(orig_f):
            def use_f(*cud_args):
                class state:  # #class-as-namespace
                    result_value = None
                rows = tuple(orig_f(*cud_args, state))
                flat = tuple(x for row in rows for x in row)  # yeah idk
                prs = _chunk(2, flat)
                grow_down = cud_args[-2]  # YUCK
                assert isinstance(grow_down, bool)
                flat_map = _build_flat_map(state, grow_down, **{k: v for k, v in prs})  # noqa: E501
                return flat_map, state
            assert cud not in dct
            dct[cud] = use_f
            return use_f
        return decorator

    def norm_and_val(recv_item, recv_end, emit_edited):
        return recv_item, recv_end, emit_edited

    return flat_map_for_who, (dct := {})


_implement, _these_two_for = _build_decorator()


@_implement('update')
def _(needle_iden, edit, grow_downwards, listener, state):

    def receive_identifier(iden):
        if above(iden, needle_iden):
            return _pass_through
        if above(needle_iden, iden):
            eid_s = _string_via_iden(iden)
            xtra = f"Or it's out of order. (stopped at {eid_s!r})"
            direc = _no_ent(needle_iden, state.item_count, 'update', xtra)
            return (direc,)
        assert needle_iden == iden
        state.recv_iden = _pass_thru_remaining_items  # done
        return (('give_me_the_AST_please', recv_before_AST),
                ('update_item', edit, recv_edited))

    def at_end():  # exactly as delete #here4
        if state.result_value is not None:
            return _no_directives
        return (_no_ent(needle_iden, state.item_count, 'update'),)

    def recv_before_AST(ast):
        state.result_value = [ast, None]

    def recv_edited(ast):  # #here2
        state.result_value[1] = ast
        state.result_value = tuple(state.result_value)

    above = _less_than if grow_downwards else _greater_than

    yield 'recv_iden', receive_identifier, 'recv_end', at_end


@_implement('create')
def _(dct, _iden_er_er, grow_downwards, listener, state):

    def recv_sch(sch):
        ks = sch.field_name_keys
        iden_key = ks[0]  # [#871.1] leftmost is the one
        if iden_key not in dct:
            xx("whine about how you need an identifier in the arg dict")
            return (('error', '..'),)  # #here3
        new_eid = dct[iden_key]
        new_iden = sch.identifier_class_(new_eid)
        state.new_eid = new_eid
        # (check the dct against the allowlist not here but there for DRY)

        def receive_identifier(iden):
            if above(iden, new_iden):
                return _pass_through
            if new_iden == iden:  # #here1
                xx("collision")
            assert above(new_iden, iden)  # we found the 1st item > than new
            state.recv_iden = _pass_thru_remaining_items  # done
            return (('insert_item', dct, recv_created), ('pass_through',))
        state.recv_iden = receive_identifier

    def emit_edited(ast):
        assert state.new_eid == ast.nonblank_identifier_primitive
        eek = tuple(None for _ in range(0, ast.cell_count))
        _emit_edited(listener, ((), eek, ()), state.new_eid, 'created')

    def recv_created(ast):  # #here2
        state.result_value = ast

    def at_end():
        if state.result_value is not None:
            return _no_directives
        return (('insert_item', dct, recv_created),)

    above = _less_than if grow_downwards else _greater_than

    yield 'recv_sch', recv_sch, 'recv_end', at_end, 'emit_edited', emit_edited


@_implement('delete')
def _(needle_iden, _grow_downwards, listener, state):
    if not _grow_downwards:
        xx('cover this for grow upwards')

    def receive_identifier(iden):
        if needle_iden != iden:  # #here1
            return _pass_through
        state.recv_iden = _pass_thru_remaining_items  # Don't keep lo
        return (('give_me_the_AST_please', receive_deleted_AST),)

    def receive_deleted_AST(ast):  # Tell the traversal you want the whole AST
        state.result_value = ast

    def at_end():  # exactly as update #here4
        if state.result_value is not None:
            return _no_directives
        direc = _no_ent(needle_iden, state.item_count, 'delete')
        return (direc,)

    def edited(ast):
        assert needle_iden == ast.identifier
        eek = tuple(None for _ in range(0, ast.cell_count))
        lol = ((), (), eek)
        _emit_edited(listener, lol, _string_via_iden(needle_iden), 'deleted')

    yield 'recv_iden', receive_identifier
    yield 'recv_end', at_end, 'emit_edited', edited


def _no_ent(iden, count, verb_stem_phrz, xtra=None):
    eid_s = _string_via_iden(iden)
    from . import emission_components_for_entity_not_found_ as func
    tup = func(eid_s, count, verb_stem_phrz)
    if xtra is None:
        return tup
    rsn_head = (dct := tup[-1]())['reason']
    dct['reason'] = '. '.join((rsn_head, xtra))
    return (*tup[:-1], lambda: dct)


def _pass_thru_remaining_items(_):  # Don't keep looking after you find it
    return _pass_through


def _build_flat_map(state, grow_down, recv_end,
                    recv_sch=None, recv_iden=None, emit_edited=None):

    # == FROM
    def catch_annotated_stops(orig_f):
        def use_f(*a):
            try:
                return orig_f(*a)
            except annotated_stop as e:
                state.recv_iden, state.recv_end = None, None
                return (e.emission_arguments,)
        return use_f

    class annotated_stop(RuntimeError):
        def __init__(self, *a):
            self.emission_arguments = a
    # == TO

    def flat_map_receive_schema(sch):
        recv_sch and recv_sch(sch)

    @catch_annotated_stops
    def flat_map_receive_item(ent):
        state.item_count += 1  # count ones with no IDs? sure. or don't
        iden = ent.identifier
        if iden is None:
            return _pass_through
        state.check_collection_order(iden)
        return state.recv_iden(iden)

    state.recv_iden = recv_iden  # None at first for some
    state.item_count = 0

    def check_collection_order_the_first_time(iden):
        state.previous_sync_key = iden
        state.check_collection_order = check_collection_order

    state.check_collection_order = check_collection_order_the_first_time

    def check_collection_order(iden):
        if above(state.previous_sync_key, iden):
            state.previous_sync_key = iden
            return

        # with custom iden cls: (Case2746)

        prev = state.previous_sync_key
        str_via = _string_via_iden
        a, b = ((lambda o: lambda: str_via(o))(oo) for oo in (prev, iden))

        def experiment():
            yield lambda: above(iden, prev)
            yield 'disorder'
            yield lambda: f"Collection is not in order. Had: {a()} then {b()})"
            yield lambda: prev == iden  # #here1
            yield 'duplicate_identifier'
            yield lambda: f"duplicate identifier in collection: {a()}"

        triplets = _chunk_forever(3, experiment())
        cat, msg = next((b, c()) for a, b, c in triplets if a())
        raise annotated_stop('error', 'expression', cat, lambda: (msg,))

    def flat_map_receive_end():
        return state.recv_end()

    state.recv_end = recv_end

    above = _less_than if grow_down else _greater_than

    class flat_map:  # #class-as-namepace
        receive_schema = flat_map_receive_schema
        receive_item = flat_map_receive_item
        receive_end = flat_map_receive_end

    flat_map.emit_edited = emit_edited  # let client see if it's there for no r

    return flat_map


def _greater_than(iden_A, iden_B):
    return iden_A > iden_B  # #here1


def _less_than(iden_A, iden_B):
    return iden_A < iden_B  # #here1


_pass_through = (('pass_through',),)
_no_directives = ()


"""
(THIS DOESNT BELONG HERE ANY MORE BUT IT'S A GOOD READ)
Introduction to yes no-value/yes-value, and
Why a tail-anchored pipe is hard to interpret correctly

            An undocumented provision is that you can't store blank strings,
            empty strings or the "null value"; for at least two reasons: One,
            it's an intentional trade-off to allow for more aesthetic/readable
            surface forms. Two, we don't *want* to support the distinction,
            because in practice this infects business code with the smell of
            not knowing whether you need to check for null/empty/blank for a
            given value, a smell that can spread deep into the code. :[#873.5]

            Rather, we conflate all such cases into one we call "no-value",
            and we leave it up to the client to decide how or whether to
            represent a value whose key isn't present in the entity-as-dict.

            Also for reasons, we do not require that the entity row express
            those of its contiguous cel values that are no-value and also
            anchored to the tail of the line.

            This is to say:
                |foo|bar||||||||
            is the same as:
                |foo|bar|

            `man git-log` brings up the distinction bewteen
            > "terminator" semantics and "separator" semantics.
            This distinction between these two categories becomes relevant
            here with our interpretation of the pipe ("|").

            Also we allow for an optional, decorative trailing pipe on any
            row (that's not the first or maybe second row, that is the
            "the table head"). This is to say that all these are the same:

                |foo|bar||||||||
                |foo|bar|
                |foo|bar

            Combining the two broad principles above; namely that no-value
            expressions are not required when tail-anchored, and that any
            trailing pipe might be decorative; we cannot know how many field
            values the row intends to express just by looking at it.
"""


"""

Create and insert the entity in an appropriate place in the table.

    If the table is empty (has no body lines (entities)), chose integer 1
    ('223') as the identifier and output the new entity as the only body line.
    Return.

    Assume at least one existing body-line (entity) in the table.

    Assert that the table's items are in ascending order (but not necessarily
    contiguous).

    Entity creation will never re-arrange the existing items in the table.
    The new entity will never be placed as the new first item in the table.

    For each (zero or more) next line in table, compare it to the line above
    it in terms of its identifier.

    If the integer "jump" (difference) between the two entity identifiers is
    exactly one, pass-through the current line and continue on to the next one.

    If the integer jump is less than one, the input table is out of order.
    Throw a not_covered error.

    Otherwise (and the integer jump is more than one), this is the insertion
    point. (Etc do the insertion.)

    Pass-thru the line you were holding on to.

    Pass thru the zero or more remaining lines WHILE CHECKING THAT each next
    identifier is greater than the one above. If any one of these is not this,
    the input table is out of order and throw a not_covered.

    An edge case is if the one or more existing entities are ordered and
    contiguous (no gaps, every jump is 1). Then append the new entity after
    passing through every existing line.
    """


def _chunk_forever(n, flat):
    rang = range(n)
    while True:
        yield tuple(next(flat) for _ in rang)


def _chunk(n, flat):
    return (flat[i*n:(i+1)*n] for i in range((len(flat)+1)//n))


# == Smalls

def _string_via_iden(iden):  # [#857.E] idens can be strings
    assert iden
    if isinstance(iden, str):
        return iden
    return iden.to_string()


# == Delegations

def _emit_edited(listener, UCDs, eid, preterite):
    from kiss_rdb.magnetics_.CUD_attributes_request_via_tuples \
        import emit_edited_ as emit
    emit(listener, UCDs, eid, preterite)


def xx(msg=None):
    raise RuntimeError('write me' + ('' if msg is None else f": {msg}"))

# #history-B.1 blind rewrite
# #history-A.1 spike feature-completion, rewrite parser to use scanner not rx
# #born.
