"""This is an abstraction of [#872.E] the way we hit both recinf and the
dataclass to build schema info. See that tag for a longer comment.

At #abstraction (birth), the target use-case was a pure refactor of
an existing generated form (both "show form" and "process form"); the original
interface leaned too heavily on inventions of the client. After the birth
commit we intend to use this generated abstract schema for a pure refactor
of an entity view. The finally we hope to use it for our first UPDATE form.

Example PURPOSEs:
- render an index of the collection
- "view entity"
- "show form" for CREATE
- "process form" for CREATE
- "show form" for UPDATE
- "process form" for UPDATE

There's "value-based" constraints and "existential" constraints.

We require a listener through the whole process to write NOTICEs to
because of how experimental and in-development all this still is.
"""

def EXPERIMENTAL_HYBRIDIZED_FORMAL_ENTITY_VIA_(coll, listener):
    fattrs = _fattrs_via(coll, listener)
    fattrs = tuple(fattrs)
    if not fattrs:
        return
    return _this_module().abstract_table_via_name_and_abstract_columns(
        coll.fent_name, fattrs, listener)


def _fattrs_via(coll, listener):

    def main():
        def identifier_for_purpose(purpose):
            return identifier_function_via_core_purpose[purpose[0]](fa)
        combined_TM = resolve_one_type_macro()
        combined_NIO = resolve_one_NULL_IS_OK_for_the_existential_constraint()

        fa = formal_attribute_factory(
            column_name=store_FA.column_name,
            type_macro=combined_TM,
            IDENTIFIER_FUNCTION=identifier_for_purpose,
            is_primary_key=store_FA.is_primary_key,
            null_is_OK=combined_NIO,
            is_unique=False,  # #open [#872.F]
            is_foreign_key_reference=store_FA.is_foreign_key_reference,
            referenced_table_name=store_FA.referenced_table_name,
            referenced_column_name=store_FA.referenced_column_name)
        return fa

    def resolve_one_type_macro():
        store_TM = store_FA.type_macro
        use_TM = use_FA.type_macro
        store_tup = store_TM.type_macro_ancestors_
        use_tup = use_TM.type_macro_ancestors_

        # It is unlikely that the two type macros are the same (for reasons)
        if store_tup == use_tup:
            return store_TM

        # (store is better than dataclass for "singluar" types (maybe),
        # but for "plural" types, this is an area of experimentation)
        # also 'instance_of_class' probably has more info than store side
        lmt = use_tup[0]
        if lmt in ('tuple', 'instance_of_class'):
            _explain_use_over_store_TM(listener, store_TM, use_TM)
            return use_TM

        # Let dataclass take precedence over store if it's longer lol
        if len(store_tup) < len(use_tup):
            _explain_use_over_store_TM(listener, store_TM, use_TM)
            return use_TM

        # We'll use store over dataclass for singular types, for now
        _explain_store_over_use_TM(listener, store_TM, use_TM)
        return store_TM

    def resolve_one_NULL_IS_OK_for_the_existential_constraint():
        store_yes = store_FA.null_is_OK
        use_yes = use_FA.null_is_OK
        if bool(store_yes) != bool(use_yes):
            _explain_inconsistent_requiredness(listener, store_FA, use_FA, coll)
        # null is OK IFF both sides says it is
        return store_yes and use_yes

    def produce_pool_from_store_keyed_to_dataclass_keys():
        store_ae = coll.abstract_entity_derived_from_store(listener)
        if not store_ae:
            return
        for fa in store_ae.to_formal_attributes():
            yield nc.use_key_via_store_key(fa.column_name), fa

    # == Adapters for name conventions (close to [#872.7])

    def for_purpose(first):
        def decorator(func):
            identifier_function_via_core_purpose[first] = func
        return decorator
    identifier_function_via_core_purpose = {}

    @for_purpose('label')
    def _(fa):
        tm = fa.type_macro
        if tuple == tm.generic_alias_origin_ and isinstance(tm.generic_alias_arg_, str):
            return _disgusting_hotfix_for_tuple(fa)
        store_k = fa.column_name
        humps = nc.name_convention_converters_.humps_via_camel(store_k)
        return ' '.join(humps)

    @for_purpose('key')
    def _(fa):
        store_k = fa.column_name
        return nc.snake_store_key_via_store_key(store_k)

    @for_purpose('DATACLASS_FIELD_NAME_PURPOSE_')
    def _(fa):
        store_k = fa.column_name
        return nc.use_key_via_store_key(store_k)

    nc = coll.name_converter
    formal_attribute_factory = _this_module().FormalAttribute_

    # ==

    """main: Make a pool of store FA's keyed to the "use" keys.
    Traverse the "use" FA's, at each step popping the one from the store.
    (We let the dataclass determine the formal order but this is arbitrary.)
    If there's either a left-diff or a (for now) right-diff, complain, complain.
    """

    pool = {k: fa for k, fa in produce_pool_from_store_keyed_to_dataclass_keys()}
    if 0 == len(pool):
        return  # assume errors if no store model
    use_FE = coll.abstract_entity_derived_from_dataclass
    keys_only_in_store = keys_only_in_use = None

    for use_FA in use_FE.to_columns():
        use_k = use_FA.column_name
        store_FA = pool.pop(use_k, None)
        if not store_FA:
            if keys_only_in_use is None:
                keys_only_in_use = []
            keys_only_in_use.append(use_k)
            continue
        yield main()
    if pool:
        f = nc.store_key_via_use_key
        keys_only_in_store = tuple(f(k) for k in pool.keys())

    if keys_only_in_store:
        xx(' '.join(_explain_bottom_heavy(keys_only_in_store, coll)))
    if keys_only_in_use:
        xx(' '.join(_explain_top_heavy(keys_only_in_use, coll)))


def _disgusting_hotfix_for_tuple(fa):
    """Don't use 'Child' as label, use 'Children'

    Per [#872.7] we generally derive label names from store names;
    but for the current store vendor this doesn't work for those (common) cases
    where you exploit recutil's field plurality.
    """

    attr = fa.identifier_for_purpose(('DATACLASS_FIELD_NAME_PURPOSE_',))
    eek = attr.split('_')
    import re
    if 1 < len(eek) and re.match('^[A-Z]{2}', eek[-1]):
        eek.pop()
    eek[0] = eek[0][0].upper() + eek[0][1:]
    return ' '.join(eek)


# == Explanations

def _explain_use_over_store_TM(listener, store_TM, use_TM):
    def lines():
        yield (f"Using dataclass type macro {use_TM.string!r} "
               f"over store type macro {store_TM.string!r}")
    listener('info', 'expression', 'hybridization', 'type_macro_stuff', lines)


def _explain_store_over_use_TM(listener, store_TM, use_TM):
    def lines():
        yield (f"Using store type macro {store_TM.string!r} "
               f"over dataclass type macro {use_TM.string!r}")
    listener('info', 'expression', 'hybridization', 'type_macro_stuff', lines)


def _explain_inconsistent_requiredness(listener, store_FA, use_FA, coll):
    def lines():
        if store_FA.null_is_OK:
            assert not use_FA.null_is_OK
            return lines_when_use()
        else:
            assert use_FA.null_is_OK
            return lines_when_store()

    def lines_when_use():
        yield (f"{head}{use_FA.column_name!r} is required in dataclass but "
               f"not in store{tail()}")

    def lines_when_store():
        yield (f"{head}{store_FA.column_name!r} is required in recfile but "
               f"not in dataclass{tail()}")

    def tail():
        return f" (recfile: {coll.recfile})"

    head = "Data modeling notice: "

    listener('notice', 'expression', 'hybridization', 'inconsistent_requiredness', lines)


def _explain_top_heavy(keys_only_in_use, coll):
    yield f"{coll.fent_name!r} dataclass has this/these field(s) but recfile"
    yield "doesn't (not sure yet if we will allow this):"
    yield repr(keys_only_in_use)
    yield f"(recfile: {coll.recfile})"


def _explain_bottom_heavy(keys_only_in_store, coll):
    yield f"{coll.fent_name!r} has these fields in recfile but not dataclass"
    yield "(not sure yet if we will allow this):"
    yield repr(keys_only_in_store)
    yield f"(in {coll.recfile})"


def _this_module():
    import kiss_rdb.magnetics_.abstract_schema_via_definition as mod
    return mod


def xx(msg=None):
    raise RuntimeError('cover me/write me' + ('' if msg is None else f": {msg}"))

# #abstraction
