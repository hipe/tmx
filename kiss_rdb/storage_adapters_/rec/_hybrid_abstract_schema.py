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
    return _this_module().abstract_table_via_name_and_abstract_columns(
        coll.fent_name, fattrs, listener)


def _fattrs_via(coll, listener):

    def main():
        def identifier_for_purpose(purpose):
            return identifier_function_via_core_purpose[purpose[0]](store_k)

        store_k = store_FA.column_name
        combined_TM = resolve_one_type_macro()
        combined_NIO = resolve_one_NULL_IS_OK_for_the_existential_constraint()

        return formal_attribute_factory(
            column_name=store_FA.column_name,
            type_macro=combined_TM,
            IDENTIFIER_FUNCTION=identifier_for_purpose,
            is_primary_key=store_FA.is_primary_key,
            null_is_OK=combined_NIO,
            is_unique=False,  # improve at [#872.F]
            is_foreign_key_reference=store_FA.is_foreign_key_reference,
            referenced_table_name=store_FA.referenced_table_name,
            referenced_column_name=store_FA.referenced_column_name)

    def resolve_one_type_macro():
        store_TM = store_FA.type_macro
        use_TM = use_FA.type_macro
        if store_TM != use_TM:
            _explain_which_type_macro(listener, store_TM, use_TM)
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
        for fa in store_ae.to_formal_attributes():
            yield nc.use_key_via_store_key(fa.column_name), fa

    # == Adapters for name conventions (close to [#872.7])

    def for_purpose(first):
        def decorator(func):
            identifier_function_via_core_purpose[first] = func
        return decorator
    identifier_function_via_core_purpose = {}

    @for_purpose('label')
    def _(store_k):
        humps = nc.name_convention_converters_.humps_via_camel(store_k)
        return ' '.join(humps)

    @for_purpose('key')
    def _(store_k):
        return nc.snake_store_key_via_store_key(store_k)

    @for_purpose('DATACLASS_FIELD_NAME_PURPOSE_')
    def _(store_k):
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


# == Explanations

def _explain_which_type_macro(listener, store_TM, use_TM):
    def lines():
        yield (f"Using store type macro {store_TM.string!r} "
               f"over dataclass type macro {use_TM.string!r}")
    listener('info', 'expression', 'type_macro_stuff', lines)


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

    listener('notice', 'expression', 'inconsistent_requiredness', lines)


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
