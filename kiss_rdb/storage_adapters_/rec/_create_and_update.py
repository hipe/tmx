def CREATE_ENTITY_(params, coll, colz, listener, is_dry):
    """ALL EXPERIMENTAL

    Since we're writing this *in order to* be able to accumulate our reading
    notes on recutils, we're allowing it to be messy with this hybrid approach:

    For deriving abstract schema, we have explored two avenues more-or-less in
    parallel: one avenue is via `recinf`, and one is from dataclasses. You see,
    originally we thought we might answer all our prayers from a pure recfiles
    approach:

    Everything we would need (so we thought) would be able to be derived from
    the kind of information available from `recinf`. But as we progressed with
    our ORM-ish; we found it convenient to have dataclasses, and soon we
    discovered the PRO's of dataclasses over `recinf`:

    - performance: one less process to open for each operation
    - power: we can extend our conventions arbitrarily because we own the design
    - familiarity: we (personally) know python well so it's easier to read

    We don't yet want to abandon the recinf-based approach, but we are about
    to leverage dataclass-based schemas in yet another way that only they can
    do: VALUE_FACTORIES

    As such, we "touch" recinf-derived schema here (with the assumption that
    we don't CREATE as much as we READ so the overhead of the extra process
    hit is more negligible) so that we don't feel we are giving up on this
    "pure" (but limited) derivational source; while still serving the end of
    merely gathering notes.
    """

    """
    A very short way to distill the overall algorithm:
    Derive any UNEXPECTEDS by (PARAM_ATTRS - ALLOW_LIST)
    Derive any MISSING_REQUIREDS by (REQUIREDS - PARAM_ATTRS)
    In the first, ALLOW_LIST is {something} minus attrs of VALUE_FACTORIES
    (so that the user cannot provide values for which VALUE_FACTORIES exist.)
    The second check should take in to account those values provided by
    VALUE_FACTORIES.
    """

    def main():
        derive_ALLOW_LIST_from_three_sources()
        determine_any_UNEXPECTEDS_by_beginning_USE_PARAMS()
        do_the_pipeline_for_each_formal_attribute()
        return send_it_back_with_recins()

    def send_it_back_with_recins():
        final_params = {k: v for k, v in formalize_parameter_order()}
        return _send_it_back_with_recins(
            final_params, coll, tlistener, is_dry)

    def formalize_parameter_order():
        # This makes the lines in the recfile be in the formal order
        for (_, use_col) in state.BOTH:
            use_k = use_col.column_name
            x = use_params.pop(use_k)
            yield use_k, x
        assert not use_params

    def do_the_pipeline_for_each_formal_attribute():
        # We want more specific failures before more general ones
        # There's "value-based" constraints and "existential" constraints

        ok = True
        for store_col, use_col in state.BOTH:
            use_k = use_col.column_name

            # Apply defaulting iff there's defaulting and value is not set
            defaulter = resolve_any_one_defaulter(store_col, use_col)
            wv = (use_params[use_k],) if use_k in params else None
            is_set = value_is_considered_to_be_set(wv[0]) if wv else False

            if defaulter and not is_set:  # #here3
                wv = defaulter()  # #here1
                assert value_is_considered_to_be_set(wv[0])
                use_params[use_k] = wv[0]

            # Apply any normalization & validation if value is set
            normalizer = resolve_any_normalizer(store_col, use_col)
            if wv and normalizer and value_is_considered_to_be_set(wv[0]):
                wv = normalizer(wv[0], use_k, listener)
                # If it failed validation, assume emitted and skip to next
                if not wv:
                    ok = False
                    continue
                use_params[use_k], = wv

            # Determine requiredness and if so, assert it
            is_reqd = determine_if_its_required(store_col, use_col)
            if is_reqd and not (wv and value_is_considered_to_be_set(wv[0])):
                express_missing_required(store_col.column_name, use_k)
                ok = False
                continue

        if ok:
            return
        raise stop()  # Throw the stop only after going thru the whole "form"

    def resolve_any_normalizer(store_col, use_col):
        store_tm = store_col.type_macro
        use_tm = use_col.type_macro
        if store_tm != use_tm:
            def lines():
                yield (f"Using store type macro {store_tm.string!r} "
                       f"over dataclass type macro {use_tm.string!r}")
            listener('info', 'expression', 'type_macro_stuff', lines)
            use_tm = store_tm
        return _normalizer_via_type_macro(use_tm)

    def express_missing_required(snake_store_key, use_k):
        def lines():
            yield f"{snake_store_key.replace('_', ' ')} is required."  # #here4
        listener('error', 'expression', 'error_about_field', use_k, 'required_and_missing', lines)

    def determine_if_its_required(store_col, use_col):
        store_reqd = not store_col.null_is_OK
        use_reqd = not use_col.null_is_OK

        if bool(store_reqd) != bool(use_reqd):
            _explain_inconsistent_requiredness(listener, store_col, use_col, coll)

        return (store_reqd or use_reqd)

    def resolve_any_one_defaulter(store_col, use_col):
        these = tuple(resolve_defaulters(store_col, use_col))
        leng = len(these)
        if 0 == leng:
            return
        if 1 == leng:
            return these[0][1]
        both = 'both' if 2 == leng else 'all of'
        this_and_this = ' AND '.join(two[1] for two in these)
        msg = f"For {use_col.column_name!r}, can't have {both} {this_and_this}"
        xx(f"Data modeling error: {msg}")

    def resolve_defaulters(store_col, use_col):
        """VALUE_FACTORIES are orthogonal to defaulting. The latter is for
        when the user doesn't provide a value. The former is an assertion that
        the value is not provided and function that's always used to populate
        it. At #here3 we asserted that. As such they are mutually exclusive.
        """
        use_k = use_col.column_name

        # The any VALUE_FACTORY
        if (vfs := state.VALUE_FACTORIES) and (vf := vfs.get(use_k)):
            def defaulter():
                x = vf(colz, tlistener)
                if not value_is_considered_to_be_set(x):
                    xx(f"No policy for {use_k!r} VALUE_FACTORY result: {x!r}")
                return (x,)  # #here1
            yield 'value factory defaulter', defaulter
        dcf = dataclass_fields[use_k]  # dcf = dataclass field

        # The any `default_factory`
        if dcf.default_factory != dataclass_none:
            def defaulter():
                x = dcf.default_factory()
                if x is None:
                    xx(f"No policy for {use_k!r} `default_factory` result of None")
                return (x,)  # #here1
            yield 'dataclass field default factory', defaulter

        # The any `default`
        if dcf.default != dataclass_none:
            if dcf.default is None:
                """A dataclass that models a field with a default value of None
                is not actually a "defaulting": it is how we model non-
                required attributes. :#here2 stipulates that we don't actually
                set values to None in the param dict (rather, don't set it).
                """
                assert not dcf.default_factory
            else:
                def defaulter():
                    return (dcf.default,)  # #here1
                yield 'dataclass field default value', defaulter

    def determine_any_UNEXPECTEDS_by_beginning_USE_PARAMS():
        def add_unexpected(category, attr_name):
            if category not in unexpecteds:
                unexpecteds[category] = []
            unexpecteds[category].append(attr_name)
        unexpecteds = {}
        ALLOW = state.ALLOW_LIST
        for k, unsanitized_s in params.items():
            if k not in ALLOW:
                add_unexpected('unrecognized', k)
                continue
            reason = ALLOW[k]
            if reason:
                add_unexpected(reason, k)  # #here3
                continue

            # We're going to go out on a limb and assume we *never*
            # want empty strings to be legitimate business values :#here2
            # (this has a documentation node somehwere)

            stripped = unsanitized_s.strip()
            if not len(stripped):
                continue

            assert k not in use_params
            use_params[k] = stripped
        if unexpecteds:
            _explain_unexpecteds(tlistener, unexpecteds, coll)  # throws stop

    def value_is_considered_to_be_set(x):
        return x or (False == x)

    def derive_ALLOW_LIST_from_three_sources():
        abs_ent_1 = abstract_entity_via_recinf()
        abs_ent_2 = abstract_entity_via_dataclass()
        both = _merge_fents(abs_ent_1, abs_ent_2, coll)
        vf = getattr(coll.dataclass, 'VALUE_FACTORIES', None)
        ALLOW = {two[1].column_name: None for two in both}
        for k in (vf.keys() if vf else ()):
            assert k in ALLOW
            ALLOW[k] = 'has_value_factory'  # #here3
        state.ALLOW_LIST = ALLOW
        state.VALUE_FACTORIES = vf
        state.BOTH = both

    def abstract_entity_via_dataclass():
        from kiss_rdb.magnetics_.abstract_schema_via_definition import \
                abstract_entity_via_dataclass as func
        return func(coll.dataclass)

    def abstract_entity_via_recinf():
        _ = coll.name_converter.store_record_type
        lines = _recinf_lines_via_recfile(coll.recfile, _, tlistener)
        from kiss_rdb.storage_adapters_.rec.abstract_schema_via_recinf import \
                abstract_schema_via_recinf_lines as func
        abs_sch = func(lines, tlistener)
        # might save the above one day
        return abs_sch[coll.fent_name]

    def tlistener(*emi):
        listener(*emi)
        if 'error' == emi[0]:
            raise stop()

    from dataclasses import fields as dataclass_fields_of, \
            MISSING as dataclass_none

    dataclass_fields = {dcf.name: dcf for dcf in dataclass_fields_of(coll.dataclass)}
    use_params = {}

    state = main  # #watch-the-world-burn
    stop = _Stop

    try:
        return main()
    except stop:
        pass


def _merge_fents(abs_ent_1, abs_ent_2, coll):
    stats = {
        'store_only': (store_only := []),
        'use_only': (use_only := []),
        'both': (both := [])}
    for k, x in _do_make_statistics(abs_ent_1, abs_ent_2, coll):
        stats[k].append(x)
    if store_only:
        xx(_line_via_lines(_explain_bottom_heavy(store_only, coll)))
    if use_only:
        xx(_line_via_lines(_explain_top_heavy(use_only, coll)))
    return tuple(both)


def _explain_inconsistent_requiredness(listener, store_col, use_col, coll):
    def lines():
        if store_col.null_is_OK:
            assert not use_col.null_is_OK
            return lines_when_use()
        else:
            assert use_col.null_is_OK
            return lines_when_store()

    def lines_when_use():
        yield (f"{head}{use_col.column_name!r} is required in dataclass but "
               f"not in store{tail()}")

    def lines_when_store():
        yield (f"{head}{store_col.column_name!r} is required in recfile but "
               f"not in dataclass{tail()}")

    def tail():
        return f" (recfile: {coll.recfile})"

    head = "Data modeling notice: "

    listener('notice', 'expression', 'inconsistent_requiredness', lines)


def _explain_unexpecteds(listener, unexpecteds, coll):
    def lines():
        for cat, ks in unexpecteds.items():
            yield f"parameter(s) {cat.replace('_', ' ')}: {tuple(ks)!r}"
    listener('error', 'expression', 'unrecognized_parameters', lines)


def _explain_top_heavy(use_only, coll):
    these = tuple(col.column_name for col in use_only)
    yield f"{coll.fent_name!r} dataclass has this/these field(s) but recfile"
    yield "doesn't (not sure yet if we will allow this):"
    yield repr(these)
    yield f"(recfile: {coll.recfile})"


def _explain_bottom_heavy(store_only, coll):
    these = tuple(col.column_name for col in store_only)
    yield f"{coll.fent_name!r} has these fields in recfile but not dataclass"
    yield "(not sure yet if we will allow this):"
    yield repr(these)
    yield f"(in {coll.recfile})"


def _do_make_statistics(abs_ent_1, abs_ent_2, coll):

    # Place the "store" side in a pool, under "use" keys (not "store" keys)

    nc = coll.name_converter
    ncc = nc.name_convention_converters_
    f = ncc.snake_via_camel
    uvs = {f(s_k): u_k for u_k, s_k in nc.custom_renames_use_and_store_()}

    def store_pool():
        for col in abs_ent_1.to_columns():
            snake_store_k = col.column_name
            yield uvs.get(snake_store_k, snake_store_k), col

    store_pool = {k: v for k, v in store_pool()}

    # Traverse the "use" side, linking it up with any "store" counterparts
    for col in abs_ent_2.to_columns():
        use_k = col.column_name
        store_col = store_pool.pop(use_k, None)
        if store_col:
            yield 'both', (store_col, col)
        else:
            yield 'use_only', col

    # Any parts left from store that aren't in use
    for col in store_pool.values():
        yield 'store_only', col


def _normalizer_via_type_macro(tm):
    if tm.kind_of('text'):
        return _text_normalizer
    if tm.kind_of('int'):
        return _int_normalizer
    xx(f"Neato, make normalizer for {tm.string!r}")


def _int_normalizer(mixed_value, use_k, listener):
    if isinstance(mixed_value, int):
        return (mixed_value,)  # #here1
    xx(f"neato, convert to int from string with regex whatever: {mixed_value!r}")


def _text_normalizer(mixed_value, use_k, listener):
    if not isinstance(mixed_value, str):
        xx(f"cover strange type, expected str had {type(mixed_value)}")
    if not len(mixed_value):
        xx(f"cover let's required nonzero length strings (for {use_k!r})")
    return (mixed_value,)  # #here1


def _send_it_back_with_recins(sanitized_parameters, coll, listener, is_dry):

    assert sanitized_parameters  #  make sure at least one

    def args():
        yield 'recins'
        name_converter = coll.name_converter
        for use_k, mixed_v in sanitized_parameters.items():
            coll
            store_k = name_converter.store_key_via_use_key(use_k)
            yield f'-f{store_k}'
            if isinstance(mixed_v, str):
                use_v = mixed_v
            elif isinstance(mixed_v, int):
                use_v = str(mixed_v)
            else:
                xx(f"have fun no problem with {type(mixed_v)}: {mixed_v!r}")
            yield f"-v{use_v}"

        yield f"-t{name_converter.store_record_type}"

        # "give a detailed report if the integrity check fails"
        yield "--verbose"

        # If you don't provide a recfile arg, it writes new lines to stdout
        if not is_dry:
            yield coll.recfile

    args = tuple(args())
    def lines():
        yield ' '.join(args)  # ..
    listener('info', 'expression', 'recutils_command', 'recins', lines)
    sout_lines = _EXPERIMENTAL(args, listener)

    if is_dry:
        def lines():
            return sout_lines
        listener('info', 'expression', 'would_have_written_these_lines', lines)
    else:
        assert 0 == len(sout_lines)

    return sanitized_parameters


def _recinf_lines_via_recfile(recfile, store_record_type, listener):
    import re
    assert re.match('^[A-Z][a-zA-Z]+$', store_record_type)
    args = (
        'recinf',  # this should be under an abstraction layer
        f'-t{store_record_type}',
        '-d',  # include full record descriptors
        # '--print-sexps'  Would be neat but we didn't write it this way
        recfile)
    return _EXPERIMENTAL(args, listener)


def _EXPERIMENTAL(args, listener):
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


def _line_via_lines(lines):
    return ' '.join(lines)


class _Stop(RuntimeError):
    pass


def xx(msg=None):
    raise RuntimeError('ohai' + ('' if msg is None else f": {msg}"))

# #born
