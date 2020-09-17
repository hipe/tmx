def cud_(all_sexpser, coll_path, opn, typ, cud_args, listener):
    flat_map, state = _these_two_for[typ](*cud_args, listener)
    from ._file_diff_via_flat_map import sync_agent_ as sync_agent_via
    sa = sync_agent_via(all_sexpser, coll_path)
    diff_lines = sa.DIFF_LINES_VIA(flat_map, None, listener)  # mebbe none
    if diff_lines is None:
        return
    rv = state.result_value
    if opn.HOLY_SMOKES_WIP_(diff_lines):
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
                flat_map = _build_flat_map(state, **{k: v for k, v in prs})
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
def _(iden, edit, listener, state):
    def receive(eid):
        if eid < needle_eid:  # #here1
            return _pass_through
        if needle_eid > eid:  # #here1
            xx("didn't find it for update")
        assert needle_eid == eid
        state.client_receive_item = _pass_thru_remaining_items  # done
        return (('give_me_the_AST_please', recv_before_AST),
                ('update_item', edit, recv_edited))

    def at_end():  # exactly as delete #here4
        if state.result_value is not None:
            return _no_directives
        from . import emission_components_for_entity_not_found_ as func
        return(func(needle_eid, state.item_count, 'update'),)

    def recv_before_AST(ast):
        state.result_value = [ast, None]

    def recv_edited(ast):  # #here2
        state.result_value[1] = ast
        state.result_value = tuple(state.result_value)

    yield 'recv_item', receive, 'recv_end', at_end  # emit_edited #here5
    needle_eid = iden.to_primitive()


@_implement('create')
def _(dct, listener, state):

    def recv_ks(ks, cstack):
        iden_key = ks[0]  # [#871.1] leftmost is the one
        if iden_key not in dct:
            xx("whine about how you need an identifier in the arg dict")
            return (('error', '..'),)  # #here3
        state.new_eid = (new_eid := dct[iden_key])
        # (check the dct against the allowlist not here but there for DRY)

        def receive(eid):
            if eid < new_eid:  # #here1
                return _pass_through
            if new_eid == eid:  # #here1
                xx("collision")
            assert new_eid < eid  # #here1 we found the 1st item > than new
            state.client_receive_item = _pass_thru_remaining_items  # done
            return (('insert_item', dct, recv_created), ('pass_through',))
        state.client_receive_item = receive

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

    yield 'recv_ks', recv_ks, 'recv_end', at_end, 'emit_edited', emit_edited


@_implement('delete')
def _(needle_iden, listener, state):

    def receive(this_eid):
        if needle_eid != this_eid:  # #here1
            return _pass_through
        state.client_receive_item = _pass_thru_remaining_items  # Don't keep lo
        return (('give_me_the_AST_please', receive_deleted_AST),)

    def receive_deleted_AST(ast):  # Tell the traversal you want the whole AST
        state.result_value = ast

    def at_end():  # exactly as update #here4
        if state.result_value is not None:
            return _no_directives
        from . import emission_components_for_entity_not_found_ as func
        return (func(needle_eid, state.item_count, 'delete'),)

    def edited(ast):
        assert needle_eid == ast.nonblank_identifier_primitive
        eek = tuple(None for _ in range(0, ast.cell_count))
        _emit_edited(listener, ((), (), eek), needle_eid, 'deleted')

    yield 'recv_item', receive, 'recv_end', at_end, 'emit_edited', edited
    needle_eid = needle_iden.to_primitive()


def _pass_thru_remaining_items(_):  # Don't keep looking after you find it
    return _pass_through


_pass_through = (('pass_through',),)
_no_directives = ()


def _build_flat_map(
        state, recv_end, recv_ks=None, recv_item=None, emit_edited=None):
    state.client_receive_item = recv_item
    state.client_receive_end = recv_end

    class flat_map:  # #class-as-namespace
        def receive_item(eid):
            return state.receive_item(eid)

        def receive_end():
            return state.receive_end()

        receive_field_name_keys = (recv_ks or _anyadic_noop)

    flat_map.emit_edited = emit_edited

    # == FROM
    def catch_annotated_stops(orig_f):
        def use_f(*a):
            try:
                return orig_f(*a)
            except annotated_stop as e:
                state.receive_item, state.receive_end = None, None
                return (e.emission_arguments,)
        return use_f

    class annotated_stop(RuntimeError):
        def __init__(self, *a):
            self.emission_arguments = a
    # == TO

    @catch_annotated_stops
    def receive_item(eid):
        state.item_count += 1
        state.check_collection_order(eid)
        return state.client_receive_item(eid)

    def check_collection_order_the_first_time(eid):
        state.previous_string = eid
        state.check_collection_order = check_collection_order

    def check_collection_order(eid):
        if state.previous_string < eid:  # #here1
            state.previous_string = eid
            return
        xx()
        prev = state.previous_string
        a, b = (lambda s: lambda: f"'{s}'" for s in (prev, eid))

        def experiment():
            yield lambda: prev == eid  # #here1
            yield 'disorder'
            yield lambda: f"collection is not in order ({a()} then {b()})"
            yield lambda: prev > eid  # #here1
            yield 'duplicate_identifier'
            yield lambda: f"duplicate identifier in collection: {a()}"

        triplets = _chunk_forever(3, experiment())
        cat, msg = next((b, c()) for a, b, c in triplets if a())
        raise annotated_stop('error', 'expression', cat, lambda: (msg,))

    def receive_end():
        return state.client_receive_end()

    state.check_collection_order = check_collection_order_the_first_time
    state.receive_item = receive_item
    state.receive_end = receive_end
    state.item_count = 0

    return flat_map


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


def _anyadic_noop(*_):
    pass


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
