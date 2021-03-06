"""ALL EXPERIMENTAL (the below comment is now :[#872.E] here for posterity.)

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

    - performance: one less process to open for those operations that don't
      need the information `recinf` can give us
    - power: we can extend our conventions arbitrarily because we own the design
    - viz: VALUE_FACTORIES (a plain old dict)
    - familiarity: we (personally) know python well so it's easier to read

    But also consider these perceived PRO's of recinf over dataclasses:

    - "pure" storage-layer derivation, one less home for schema
    - foreign keys and primary keys modeled more naturally
    - (superficially) as it works out, we like the shorter, more human attr names

    As such, there is a constant pushing back-and-forth between the
    recinf-derived and dataclass-derived schema here as we suss out whether
    and to what extent we will go with this hybrid approach (and maybe one day
    make a merged abstract entity).

    (At #history-C.1 the hybridized stuff moved to its own file)
    """


def UPDATE_ENTITY_(EID, param_direcs, coll, colz, listener, is_dry):
    """UPDATE differs from CREATE in these key ways:

    - Requires an EID (maybe one day an identifying expression or "compound PK")
    - No defaulting, no VALUE_FACTORIES
    - The parameters structure isn't simply key-value pairs, it's directives,
      which can fail in interesting ways
    - Dry run isn't as pretty because vendor does not simply output lines

    As we write it, we discover it's made subtly, sublimely more complicated
    by some of these vendor behaviors:

    - You must correctly distinguish between changing existing value vs
      creating a value for an attribute that wasn't already there
    - If you don't, it fails silently
    - With a set of arbitrary form values coming down from the client, after it
      passes the ALLOW_LIST, the question does not intuitively answer itself
      of what to do with the set difference: Does a form value not passed imply
      "DELETE_EXISTING_ATTRIBUTE" or leave existing value alone? It seems like
      we *want* meaningful empty values here to come from the form explicitly,
      else fail. I.E. the whole ALLOW_LIST becomes REQUIREDS in its way.

    Row 1: "Will it work if the attribute is NOT already set?"
    Row 2: "Will it work if the attribute IS already set?"

    | Our Directive Name            | 1 | 2 | Vendor Oper. & Other Impl. Strat
    |-------------------------------|---|---|---------------------------------
    | SET_ATTRIBUTE                 | Y | Y | --add or --set depending
    | UPDATE_ATTRIBUTE              | N | Y | --set (must already be set)
    | CREATE_ATTRIBUTE              | Y | N | --add (be careful)
    | DELETE_ANY_EXISTING_ATTRIBUTE | Y | Y | --delete IFF already set else noop
    | DELETE_EXISTING_ATTRIBUTE     | N | Y | --delete (must already be set)
    (:#here8)
    """

    def main():
        derive_ALLOW_LIST_from_three_sources()
        determine_any_UNEXPECTEDS_and_strange_directives()
        validate_and_prepare_directives()
        put_the_prepared_directives_in_formal_order()
        send_it_back_to_recset()

        # Should have raised a stop on no-op or failure.
        # Ergo if we got this far, we should be OK
        return ('result_of_CREATE_or_UPDATE', 'result_of_UPDATE',
                'UPDATE_succeeded', state.ordered_prepared_directives)
        # (this is a bit of encapsulation violation to result in an internal
        # structure but we wanted to give some kind of structured detail of
        # the work that was actually performed)

    def send_it_back_to_recset():
        _send_it_back_to_recset(
                state.primary_key_field_name, EID,
                state.ordered_prepared_directives, coll, tlistener, is_dry)

    def put_the_prepared_directives_in_formal_order():
        dct = {k: direc for k, direc in do_formalize_parameter_order()}
        state.ordered_prepared_directives = dct

    def do_formalize_parameter_order():
        unordered_but_prepared = state.unordered_but_prepared
        delattr(state, 'unordered_but_prepared')
        for use_k, use_col in state.FORMAL_PARAMETERS_DICTIONARY.items():
            if use_k in unordered_but_prepared:
                yield use_k, unordered_but_prepared.pop(use_k)
        assert not unordered_but_prepared

    def validate_and_prepare_directives():
        # _sanity_check_identifier(EID)  # or etc
        existing_entity = coll.retrieve_entity(EID, tlistener)
        # (the above validates the identifier string :#here7)
        assert existing_entity  # else it would have thrown b.c. tlistener
        itr = _prepare_directives(existing_entity, param_direcs, tlistener)
        unexpecteds = next(itr)  # #here9 "promise"
        use_direcs = {k: direc for k, direc in itr}  # populates unexpecteds

        # First, if there were strange attribute keys, complain and stop
        if unexpecteds:
            _explain_unexpecteds(tlistener, unexpecteds, coll)  # throws stop

        # Then, if eliminating redundants made a no-op; explain and stop
        if 0 == len(use_direcs):
            raise stop('result_of_CREATE_or_UPDATE', 'result_of_UPDATE',
                       'UPDATE_was_no_op', 'nothing_to_do')

        # Finally, run any attribute-specific normalization & validation
        use_direcs = {k: v for k, v in normalize_attribute_values(use_direcs)}
        state.unordered_but_prepared = use_direcs

    def normalize_attribute_values(direcs):
        """UPDATE normalization differs from that of CREATE in these ways:
        - UPDATE has deletion. Prevent the deletion of required attributes.
        - UPDATE does no defaulting nor VALUE_FACTORIES
        But UPDATE and CREATE do share this:
        - Attribute-level validation & normalization
        - Accumulate errors "horizontally", don't just stop at the first one

        Here's possible issues:
        - If there's a required attribute and the form submission doesn't
          pass a name-value pair for that attribute, it may look like it's okay
        """

        normalizer_via_formal_attribute = _build_normalizerer(colz)  # #here14

        did_fail_at_least_once = False
        for form_k, direc in direcs.items():
            fa = state.FORMAL_PARAMETERS_DICTIONARY[form_k]
            typ = direc[0]
            if 'DELETE_EXISTING_ATTRIBUTE' == typ:
                if fa.null_is_OK:
                    yield form_k, direc  # passthru
                else:
                    _explain_missing_required(listener, fa)
                    did_fail_at_least_once = True
                continue

            if 'UPDATE_ATTRIBUTE' == typ:
                new_value = direc[-1]
            else:
                assert 'CREATE_ATTRIBUTE' == typ
                new_value = direc[-1]

            # == BEGIN compare and contrast to the CREATE pipeline #here10

            # Assert this unwritten assumption until we know what our spec is
            assert isinstance(new_value, str)  # #here13
            normalize = normalizer_via_formal_attribute(fa)

            # If there is no normalizer derived from this field, it passes
            if normalize is None:
                yield form_k, direc  # #passthru
                continue

            # If the normalization failed, assume expression emitted & continue
            wv = normalize(new_value, listener)
            if wv is None:
                did_fail_at_least_once = True
                continue

            # Create a new directive that uses the normalized value
            if len(wv):
                use_value, = wv
            else:
                use_value = new_value
            use_direc = (*direc[:-1], use_value)
            yield form_k, use_direc

            # == END
        if did_fail_at_least_once:
            raise stop()

    def determine_any_UNEXPECTEDS_and_strange_directives():
        add_unexpected, unexpecteds = _build_unexpecteds()
        ALLOW = state.ALLOW_LIST

        for k, direc in param_direcs.items():
            # Validate each attribute name in the parameter directives
            if k not in ALLOW:
                add_unexpected('unrecognized', k)
                continue

            # Validate each directive name (and its length) :#here5
            typ = direc[0]
            num = directive_length_via_directive_type.get(typ)
            if num is None:
                add_unexpected(f"unrecognized directive {typ!r}", k)
            elif num != len(direc):
                exp_act = f"(need {num} had {len(direc)})"
                add_unexpected(f"Wrong number for {typ!r} {exp_act}", k)
        if unexpecteds:
            _explain_unexpecteds(tlistener, unexpecteds, coll)  # throws stop

    directive_length_via_directive_type = {
        'SET_ATTRIBUTE': 2,
        'UPDATE_ATTRIBUTE': 3,
        'CREATE_ATTRIBUTE': 2,
        'DELETE_ANY_EXISTING_ATTRIBUTE': 1,
        'DELETE_EXISTING_ATTRIBUTE': 1,
    }

    def derive_ALLOW_LIST_from_three_sources():
        # ignoring VALUE_FACTORIES for now
        indexer = _IndexBuilder(coll, tlistener)
        for k in ('ALLOW_LIST',
                  'FORMAL_PARAMETERS_DICTIONARY',
                  'primary_key_field_name',
                  'formal_entity'
                  ):
            setattr(state, k, getattr(indexer, k))

    state = main
    stop = _Stop
    tlistener = _build_throwing_listener(listener, stop)

    try:
        return main()
    except stop as the_stop:
        return the_stop.result_sexp


def _prepare_directives(existing_entity, param_direcs, tlistener):
    # (implementing this directly from the table #here8)

    add_unexpected, unexpecteds = _build_unexpecteds()
    yield unexpecteds  # #promise #here9
    for use_k, direc in param_direcs.items():
        existing_value = None
        x = getattr(existing_entity, use_k)  # wee no default
        if _value_is_considered_to_be_set(x):
            already_set = True
            existing_value = x
        else:
            already_set = False
            del existing_value
        typ = direc[0]
        if 'SET_ATTRIBUTE' == typ:
            new_val, = direc[1:]
            if already_set:
                assert type(existing_value) == type(new_val)
                if existing_value == new_val:
                    _explain_no_change(tlistener, use_k, existing_value)
                    continue
                yield use_k, ('UPDATE_ATTRIBUTE', existing_value, new_val)
            else:
                yield use_k, ('CREATE_ATTRIBUTE', new_val)
        elif 'UPDATE_ATTRIBUTE' == typ:
            if already_set:
                yield use_k, direc  # passthru
            else:
                add_unexpected(use_k, "must already be set but wasn't")
        elif 'CREATE_ATTRIBUTE' == typ:
            if already_set:
                add_unexpected(use_k, "cannot create because already set")
            else:
                yield use_k, direc  # passthru
        elif 'DELETE_ANY_EXISTING_ATTRIBUTE' == typ:
            if already_set:
                yield use_k, ('DELETE_EXISTING_ATTRIBUTE', existing_value)
            else:
                pass  # do nothing, it's already not set
        else:
            assert 'DELETE_EXISTING_ATTRIBUTE' == typ
            leng = len(direc)  # we don't know if we want to require the safety
            assert leng in range(1, 3)
            if already_set:
                if 2 == leng:
                    yield use_k, direc
                else:
                    yield use_k, ('DELETE_EXISTING_ATTRIBUTE', existing_value)
            else:
                add_unexpected(use_k, "cannot delete because not currently set")


def CREATE_ENTITY_(params, coll, colz, listener, is_dry):
    """
    A very short distillation of the overall algorithm:
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
        sx = send_it_back_to_recins()
        if sx is None:
            return
        assert 'recins_success' == sx[0]
        final_params, = sx[1:]
        return ('result_of_CREATE_or_UPDATE', 'result_of_CREATE',
                'CREATE_succeeded', final_params)

    def send_it_back_to_recins():
        final_params = {k: v for k, v in formalize_parameter_order()}
        return _send_it_back_to_recins(
            final_params, coll, tlistener, is_dry)

    def formalize_parameter_order():
        # This makes the lines in the recfile be in the formal order
        for use_k in state.FORMAL_PARAMETERS_DICTIONARY.keys():
            # NOTE todo what about etc
            x = use_params.pop(use_k)
            yield use_k, x
        assert not use_params

    def do_the_pipeline_for_each_formal_attribute():
        # We want more specific failures before more general ones
        # There's "value-based" constraints and "existential" constraints

        normalizer_via_formal_attribute = _build_normalizerer(colz)
        ok = True
        for use_k, use_col in state.FORMAL_PARAMETERS_DICTIONARY.items():
            # == BEGIN #here10

            # Apply defaulting iff there's defaulting and value is not set
            k = coll.name_converter.use_key_via_store_key(use_col.column_name)
            value_factory = resolve_any_one_defaulter(k)
            wv = (use_params[use_k],) if use_k in use_params else None
            is_set = value_is_considered_to_be_set(wv[0]) if wv else False

            if value_factory and not is_set:  # #here3
                wv = value_factory(params)  # #here1 #here15
                x, = wv
                assert value_is_considered_to_be_set(x)
                use_params[use_k] = x

            # Apply any normalization & validation if value is set
            normalize = normalizer_via_formal_attribute(use_col)

            if wv and normalize and value_is_considered_to_be_set(wv[0]):
                unsanitized_value = wv[0]
                wv = normalize(unsanitized_value, listener)  # #here10
                # If it failed validation, assume emitted and skip to next
                if wv is None:
                    ok = False
                    continue
                if 0 == len(wv):
                    use_value = unsanitized_value
                    wv = (use_value,)
                else:
                    use_value, = wv
                use_params[use_k] = use_value

            # Determine requiredness and if so, assert it
            is_reqd = not use_col.null_is_OK
            if is_reqd and not (wv and value_is_considered_to_be_set(wv[0])):
                _explain_missing_required(listener, use_col)
                ok = False
                continue

            # == END

        if ok:
            return
        raise stop()  # Throw the stop only after going thru the whole "form"

    value_is_considered_to_be_set = _value_is_considered_to_be_set

    def resolve_any_one_defaulter(field_attr_name):
        these = tuple(resolve_defaulters(field_attr_name))
        leng = len(these)
        if 0 == leng:
            return
        if 1 == leng:
            return these[0][1]
        both = 'both' if 2 == leng else 'all of'
        this_and_this = ' AND '.join(two[1] for two in these)
        msg = f"For {use_k!r}, can't have {both} {this_and_this}"
        xx(f"Data modeling error: {msg}")

    def resolve_defaulters(field_attr_name):
        """VALUE_FACTORIES are orthogonal to defaulting. The latter is for
        when the user doesn't provide a value. The former is an assertion that
        the value is not provided and function that's always used to populate
        it. At #here3 we asserted that. As such they are mutually exclusive.
        """

        # The any VALUE_FACTORY
        if (vfs := state.VALUE_FACTORIES) and (vf := vfs.get(field_attr_name)):
            def defaulter(arg):  # #here15
                x = vf(arg, tlistener)
                if not _value_is_considered_to_be_set(x):
                    xx(f"No policy for {field_attr_name!r} VALUE_FACTORY result: {x!r}")
                return (x,)  # #here1
            yield 'value factory defaulter', defaulter
        dcf = dataclass_fields[field_attr_name]  # dcf = dataclass field

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
                assert dataclass_none == dcf.default_factory
            else:
                def defaulter():
                    return (dcf.default,)  # #here1
                yield 'dataclass field default value', defaulter

    def determine_any_UNEXPECTEDS_by_beginning_USE_PARAMS():
        add_unexpected, unexpecteds = _build_unexpecteds()
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

    def derive_ALLOW_LIST_from_three_sources():
        indexer = _IndexBuilder(coll, tlistener)
        for k in ('ALLOW_LIST',
                  'FORMAL_PARAMETERS_DICTIONARY',
                  'VALUE_FACTORIES',
                  ):
            setattr(state, k, (getattr(indexer, k)))

    from dataclasses import fields as func, MISSING as dataclass_none
    dataclass_fields = {dcf.name: dcf for dcf in func(coll.dataclass)}
    use_params = {}
    state = main  # #watch-the-world-burn
    stop = _Stop
    tlistener = _build_throwing_listener(listener, stop)

    try:
        return main()
    except stop as the_stop:
        return the_stop.result_sexp  # at writing, always None BUT MAYBE NOT NOW


def _IndexBuilder(coll, tlistener):
    class IndexBuilder:
        pass

    def export(func):
        setattr(IndexBuilder, func.__name__, property(lambda _: func()))
        return func

    def memoize(func):
        def use_func():
            if k not in memo:
                memo[k] = func()
            return memo[k]
        k = func.__name__
        use_func.__name__ = k
        return use_func

    memo = {}

    @export
    def ALLOW_LIST():
        return {k: None for k in allow_list_keys()}

    def allow_list_keys():
        # The ALLOW_LIST is the (fpns of) the FATTRs list minus VALUE_FACTORIES
        # Don't bother creating name keys if you're not looking for it (ick)
        pool = None
        if (dct := VALUE_FACTORIES()):
            pool = {k: None for k in dct.keys()}

        for attr in formal_attributes():
            if pool:
                k = coll.name_converter.use_key_via_store_key(attr.column_name)
                if k in pool:
                    pool.pop(k)
                    continue
            yield form_parameter_name_for(attr)

        assert not pool

    @export
    def VALUE_FACTORIES():
        return getattr(coll.dataclass, 'VALUE_FACTORIES', None)

    @export
    def primary_key_field_name():
        return formal_entity().primary_key_field_name

    @export
    def FORMAL_PARAMETERS_DICTIONARY():
        return {k: v for k, v in build_formal_parameters_dictionary()}

    def build_formal_parameters_dictionary():
        for attr in formal_attributes():
            k = form_parameter_name_for(attr)
            yield k, attr

    def formal_attributes():
        return formal_entity().to_formal_attributes()

    @export
    @memoize
    def formal_entity():
        return coll.EXPERIMENTAL_HYBRIDIZED_FORMAL_ENTITY_(tlistener)

    def form_parameter_name_for(attr):
        return attr.identifier_for_purpose(_FORM_PARAMETER_NAME_PURPOSE)

    return IndexBuilder()


def _build_unexpecteds():
    def add_unexpected(category, attr_name):
        if category not in unexpecteds:
            unexpecteds[category] = []
        unexpecteds[category].append(attr_name)
    unexpecteds = {}
    return add_unexpected, unexpecteds


def _explain_no_change(listener, use_k, same_value):
    def lines():
        yield f"{use_k!r} is already set to this value"
    listener('info', 'expression', 'about_field', use_k,
             'attribute_is_already_this_value', lines)


def _explain_existing_value(listener, verb, use_k, existing_value):
    def lines():
        if True:  # one day, don't do this for big structures
            tail = f" ({existing_value!r})"
        yield (f"for {use_k!r}, {verb} doesn't "
               f"currently confirm previous value{tail}")
    listener('warning', 'expression', 'about_field', use_k,
             'caution_thrown_to_wind', lines)


def _explain_missing_required(listener, fa):
    def lines():
        label = _label(fa)
        yield f"{label} is required"  # #here4
    listener('error', 'expression', 'about_field', _form_key(fa), 'missing_required', lines)


def _explain_unexpecteds(listener, unexpecteds, coll):
    def lines():
        for cat, ks in unexpecteds.items():
            yield f"parameter(s) {cat.replace('_', ' ')}: {tuple(ks)!r}"
    listener('error', 'expression', 'unrecognized_or_malformed_parameters', lines)


def _build_normalizerer(colz):
    """build a function that builds a #here12-style normalizer"""
    # (this is sort of a glue-function (dispatching) retrofitting to older code)

    def normalizer_via_formal_attribute(fa):
        implementing_function = implementing_function_via_formal_attribute(fa)
        if implementing_function is None:
            return

        def normalize(unsanitized_s, listener):
            # assert isinstance(unsanitized_s, str)  # #here13 for now
            # no - let int thru - needs design
            return implementing_function(unsanitized_s, fa, listener)
        return normalize

    def implementing_function_via_formal_attribute(fa):
        base_type = fa.type_macro.LEFTMOST_TYPE
        func = func_via_base_type.get(base_type)
        if func:
            return func(fa)
        xx(f"have fun: {tm.string!r}")

    def for_base_type(typ):
        def decorator(func):
            func_via_base_type[typ] = func
        return decorator

    func_via_base_type = {}

    @for_base_type('text')
    def _(fa):
        tm = fa.type_macro
        if 'text' == tm.string:
            return _text_normalizer
        if tm.kind_of('line'):
            return _text_normalizer
        if tm.kind_of('paragraph'):
            assert 'paragraph' == tm.string  # for now
            return _paragraph_normalizer
        xx(f"have fun: {tm.string}")

    @for_base_type('tuple')
    def _(fa):
        tm = fa.type_macro
        arg = tm.generic_alias_arg_  # ..
        if str == arg:
            return _paragraph_normalizer
        if isinstance(arg, str):  # [#872.H] assume fent name
            return _dont_allow_this_to_be_set_normalizer
        xx(f"Neato, make normalizer for {tm.string!r}")

    @for_base_type('instance_of_class')
    def _(fa):
        return _build_class_based_normalizerer(fa, colz)

    @for_base_type('int')  # won't be a base type forever, probably
    def _(_):
        return _int_normalizer

    return normalizer_via_formal_attribute


def _build_class_based_normalizerer(fa, colz):  # #here14
    fent_name = fa.type_macro.type_macro_ancestors_[1]
    coll = colz[fent_name]  # this is a HUGE amount of surface area for one thing
    dc = coll.dataclass
    if hasattr(dc, '__members__'):
        return _build_enum_normalizer(fa, dc)
    xx(f"We like the idea of this, but not covered: {fa.column_name}:{fent_name}")


def _build_enum_normalizer(fa, enum_class):
    def normalize(unsanitized_s, same_fa, listener):
        """(We would rather use `(<strange-str> in <enum-class>)` but doing
        so currently raises a DeprecationWarning about an upcoming behavior
        change (at writing, can't confirm it's the change we want) so we're
        just avoiding it altogether for now; instead using an exception as
        a conditional ick/meh):"""

        try:
            enum_class(unsanitized_s)  # throws if not valid value
            return ()  # #here12: empty tuple means accept value as-is
        except ValueError:
            pass
        explain(listener, unsanitized_s)

    def explain(listener, unsanitized_s):
        def lines():
            yield ''.join(reversed(tuple(reversed_pieces())))

        def reversed_pieces():
            label = fa.identifier_for_purpose(_LABEL_PURPOSE)
            stack = list(reversed(tuple(repr(item.value) for item in iter(enum_class))))
            if not stack:
                yield f"(empty enum for {label})"
                return
            yield stack.pop()
            if stack:
                yield " or "
                yield stack.pop()
                while stack:
                    yield ", "
                    yield stack.pop()
            yield f"{label} must be "

        listener('error', 'expression', 'about_field', form_k, 'failed_validation', lines)

    form_k = _form_key(fa)
    return normalize


def _int_normalizer(mixed_value, fa, listener):
    """(this was written before precondition #here13)"""

    if isinstance(mixed_value, int):
        return (mixed_value,)  # #here1
    xx(f"neato, convert to int from string with regex whatever: {mixed_value!r}")


def _paragraph_normalizer(x, fa, listener):
    k = fa.identifier_for_purpose(_FORM_PARAMETER_NAME_PURPOSE)  # retrofit

    # Make sure type is string, furthermore make sure string is nonempty
    wv = _text_normalizer(x, fa, listener)
    if wv is None:
        return

    if 0 < len(wv):
        x, = wv

    # NOTE normally we stream but we want to just make it easier

    # Split on newlines, preserving them
    import re
    lis = re.split('(?<=\n)(?=.)', x)

    # If the carriage return char is anywhere, be gone! (weird browser thing)
    # (we do this after splitting in case we end up needing to use '\r' later)
    if -1 != x.find('\r'):
        lis = [s.replace('\r', '') for s in lis]

    # Strip trailing whitespace (spaces, tabs) from lines (preserve newline)
    # (we added this when we didn't understand that recins always adds a single
    # space after the '+' on multiline strings, but no matter.)
    def f(s):
        md = re.match(r'^(.*[^ \t]|)[ \t]+\n\Z', s)
        if not md:
            return s
        return md[1] + '\n'

    lis = [f(s) for s in lis]

    # If the last line didn't terminate (probably), termindate it
    # (#todo: Actually we don't like it.)
    if False and not (len(lis[-1]) and '\n' == lis[-1][-1]):
        lis[-1] = f"{lis[-1]}\n"

    # EXPERIMENTAL enforce this here, hard-codedly:
    # "standard linux terminal size" for a paragraph (80x24)

    max_w, max_h = 80, 24
    use_max_w = max_w + 1  # don't count newline against the max

    # What are the offsets of lines that are too wide lol?
    bads = tuple(i for i in range(0, len(lis)) if use_max_w < len(lis[i]))

    # How many lines are we over the max number of lines?
    over = max(0, len(lis)-max_h)

    if bads or over:
        return _explain_rectangle(listener, bads, over, lis, max_w, max_h, k)

    # == BEGIN hotfix for recins bug probably #todo
    # Find all the line that END in a backslash (also check something)
    def yes(line):
        md = bad_rx.search(line)
        if not md:
            return
        assert '\\' == md[1]  # because #here6
        return True
    bad_rx = re.compile('(.?)\\\\$')
    bads = tuple(i for i in range(0, len(lis)) if yes(lis[i]))
    if bads:
        return _explain_recins_bug(listener, bads, lis, k)
    # == END

    # Since we're normalizing for storage into recins, it's a string we want
    x = ''.join(lis)
    return (x,)  # #here1


def _dont_allow_this_to_be_set_normalizer(x, fa, listener):
    k = fa.identifier_for_purpose(_LABEL_PURPOSE)
    xx(f"this is an assertion that {k!r} is never set")


# == Explain things

def _explain_recins_bug(listener, bads, lis, k):
    def lines():
        s, oxford_np, are = _express_line_numbers(bads)
        yield f"Line{s} {oxford_np} cannot end in a backslash."
        yield "This is probably because of a recins bug."
    listener('error', 'expression', 'about_field', k, 'recins_bug', lines)


def _explain_rectangle(listener, bads, over, tup, max_w, max_h, k):
    # If the first too-wide line is also already past the row limit, focus.
    if not bads or (max_w <= bads[0]):
        return _explain_rectangle_too_tall(listener, over, tup, max_h, k)
    return _explain_rectangle_too_wide(listener, bads, tup, max_w, k)


def _explain_rectangle_too_wide(listener, bads, tup, max_w, k):
    def lines():
        s, oxford_np, are = _express_line_numbers(bads)
        yield f"Line{s} {oxford_np} {are} too long."
        yield f"Max line width is {max_w}."
    listener('error', 'expression', 'about_field', k, 'too_wide', lines)


def _express_line_numbers(bads):
    line_nos = [str(i+1) for i in bads]
    if 1 < len(bads):
        line_nos[-1] = f'{line_nos[-2]} and {line_nos.pop()}'
        s, are = 's', 'are'
    else:
        s, are = '', 'is'
    oxford_np = ', '.join(line_nos)
    return s, oxford_np, are


def _explain_rectangle_too_tall(listener, over, tup, max_h, k):
    def lines():
        yield f"has too many lines. Max is {max_h}; this has {max_h + over}."
    listener('error', 'expression', 'about_field', k, 'too_tall', lines)


def _text_normalizer(mixed_value, fa, listener):
    use_k = fa.identifier_for_purpose(_FORM_PARAMETER_NAME_PURPOSE)
    if not isinstance(mixed_value, str):
        xx(f"cover strange type, expected str had {type(mixed_value)}")
    if not len(mixed_value):
        xx(f"cover let's required nonzero length strings (for {use_k!r})")
    # == BEGIN #hotfix
    #    somewhere along the pipeline, if we don't escape backslashes
    #    they get swallowed
    mixed_value = mixed_value.replace('\\', '\\\\')  # :#here6
    # == END
    return (mixed_value,)  # #here1


def _send_it_back_to_recset(pkfn, EID, use_direcs, coll, tlistener, is_dry):

    assert use_direcs  # make sure at least one

    def args_args():
        # Each attribute-directive needs its own whole command because recutils
        # (Otherwise you get "recset: error: please specify just one action.")
        for use_k, direc in use_direcs.items():
            yield tuple(args_for_just_one_action(use_k, direc))

    def args_for_just_one_action(use_k, direc):
        # Express program name, record type
        yield 'recset'
        yield f'-t{name_converter.store_record_type}'

        # Express the selection expression
        yield f'-e{pkfn}="{EID}"'  # assume #here7 string is validated

        # For just this one attribute-directive:
        store_k = name_converter.store_key_via_use_key(use_k)
        typ = direc[0]

        # == BEGIN assume #here5
        yield f'-f{store_k}'

        if 'UPDATE_ATTRIBUTE' == typ:
            # UPDATE_ATTRIBUTE wants to assert previous existence but 2 hard
            existing_value, new_value = direc[1:]
            if existing_value is not None:
                _explain_existing_value(tlistener, typ, use_k, existing_value)
            yield f'-s{encode(new_value)}'  # --set
        elif 'CREATE_ATTRIBUTE' == typ:
            add_value, = direc[1:]
            yield f'-a{encode(add_value)}'  # --add
        else:
            if 'DELETE_EXISTING_ATTRIBUTE' != typ:
                xx(f"oops, should not have {typ!r} per #here8")
            leng = len(direc)
            assert leng in range(1, 3)
            if 2 == leng:
                _explain_existing_value(tlistener, typ, use_k, direc[1])
            yield '-d'
        # == END

        # "give a detailed report if the integrity check fails"
        yield "--verbose"

        # (unlike CREATE, you must express the recfile or blocks reading STDIN)
        yield coll.recfile

    name_converter = coll.name_converter
    encode = _encode_for_subprocess

    args_args = tuple(args_args())
    for args in args_args:
        _do_send_it_back_to_recset(args, is_dry, tlistener)


def _do_send_it_back_to_recset(args, is_dry, listener):
    def lines():
        yield _shell_escape_FOR_DISPLAY_ONLY(args)
    lines.COMMAND_ARGS = args
    listener('info', 'expression', 'recutils_command', 'recset', lines)
    if not is_dry:
        sout_lines = _call_subprocess(args, listener)
        assert not len(sout_lines)


def _send_it_back_to_recins(sanitized_parameters, coll, listener, is_dry):

    assert sanitized_parameters  #  make sure at least one

    def args():
        yield 'recins'
        name_converter = coll.name_converter
        for use_k, mixed_v in sanitized_parameters.items():
            store_k = name_converter.store_key_via_use_key(use_k)
            yield f'-f{store_k}'
            use_v = _encode_for_subprocess(mixed_v)
            yield f"-v{use_v}"

        yield f"-t{name_converter.store_record_type}"

        # "give a detailed report if the integrity check fails"
        yield "--verbose"

        # If you don't provide a recfile arg, it writes new lines to stdout
        if not is_dry:
            yield coll.recfile

    args = tuple(args())
    def lines():
        yield _shell_escape_FOR_DISPLAY_ONLY(args)
    listener('info', 'expression', 'recutils_command', 'recins', lines)
    sout_lines = _call_subprocess(args, listener)

    if is_dry:
        def lines():
            return sout_lines
        listener('info', 'expression', 'would_have_written_these_lines', lines)
    else:
        assert 0 == len(sout_lines)

    return 'recins_success', sanitized_parameters


def _shell_escape_FOR_DISPLAY_ONLY(args):
    return ' '.join(_do_shell_escape_FOR_DISPLAY_ONLY(args))


def _do_shell_escape_FOR_DISPLAY_ONLY(args):
    import re

    def escape_the_double_quotes():
        return rx_double.sub(escape_double, arg)

    def escape_double(md):
        return ''.join(('\\', md['double_or_backslash']))

    rx_double = re.compile(r'(?P<double_or_backslash>"|\\)')

    def surround_in_double_quotes():
        return ''.join(('"', arg, '"'))

    def surround_in_single_quotes():
        return ''.join(("'", arg, "'"))

    def signature():
        result = set()
        for md in rx_sig.finditer(arg):
            k = next(k for k in these if md[k])
            result.add(k)
            if leng == len(result):
                return result
        return result

    rx_sig = re.compile('(?:(?P<space> )|(?P<single>\')|(?P<double>"))')
    these = tuple(rx_sig.groupindex.keys())
    leng = len(these)

    for arg in args:
        sig = signature()
        has_double = 'double' in sig
        has_single = 'single' in sig
        has_space = 'space' in sig
        if has_double:
            if has_single:
                yield escape_the_double_quotes()
            else:
                yield surround_in_single_quotes()
        elif has_single:
            yield surround_in_double_quotes()
        elif has_space:
            yield surround_in_single_quotes()
        else:
            yield arg


def _encode_for_subprocess(mixed_value):
    if isinstance(mixed_value, str):
        # (at #history-C.2 we discovered this bug during visual testing
        #  but sadly it's not covered LOL)
        if len(mixed_value):
            return mixed_value
        xx("Storing the empty string is never allowed - see here")
        """At BOTH points where this function is called, if we were to return
        the empty string, it would break the semantics of the command tuple
        as constructed: An empty string concatted after "-s" or "-a" is still
        that same token, so the command line interpreter consumes the
        *subsequent* token for its argument; erroneously setting values meant
        to be blank to the value "--verbose" (the token that just *happens* to
        come after this part of the expression yikes!).
        This could be fixed by using *two* tokens instead of one for for "--set"
        and "--add" parts, HOWEVER per [#891.6], we should never be storing
        a blank string as an attribute value anyway. It's convenient using this
        function as a last-line of defense sanity check against that (currently)
        """
    if isinstance(mixed_value, int):
        return str(mixed_value)
    xx(f"have fun no problem with {type(mixed_value)}: {mixed_value!r}")


def _value_is_considered_to_be_set(x):
    """This used to be a one-liner, but at #history-C.2 we needed to complicate
    this: if a defaulter (factory or value) sets the default to `()` (empty
    tuple), we want to allow this. But (for now) if a defaulter results in
    either `None` or the empty string, we want to consider these not set and
    raise an exception; because (except for some fantastical imaginings we have
    yet to need) there should never be any reason to result in either of these
    two values from a defaulter. (Just don't have a defaulter)

    In a further experimentation, we munge the above use-case in with the
    others, namely: determining if the existing value of an entity (its member
    data) it to be considered as "set" or ot not.

    As yet a further concern, Whether or not this semantic taxonomy should be
    the same for the above two use cases of this function (and whatever other
    call-points); this is a related but seperate question and still open XX
    """

    # If the value is true-ish, it's definitely considered set
    if x:
        return True

    # The value is false-ish: something like: None, False, 0, "", [], (), {}
    if x is None:
        return False  # `None` is the quintessece of the "not set" value

    typ = type(x)
    if str == typ:
        return False  # We consider the empty string to be not set for XX reason

    if typ in (tuple, int, bool, float):
        return True  # the value False and the empty tuple *are* meaningful values

    xx(f"new or unexpected value type: {typ!r}")


def _call_subprocess(args, listener):
    from kiss_rdb.storage_adapters.rec import call_subprocess_ as func
    return func(args, listener)


def _build_throwing_listener(listener, stop):
    def tlistener(*emi):
        listener(*emi)
        if 'error' == emi[0]:
            raise stop()
    return tlistener


class _Stop(RuntimeError):
    def __init__(self, *sx):
        self.result_sexp = sx if len(sx) else None


def _label(fa):
    return fa.identifier_for_purpose(_LABEL_PURPOSE)


def _form_key(fa):
    return fa.identifier_for_purpose(_FORM_PARAMETER_NAME_PURPOSE)


def xx(msg=None):
    raise RuntimeError('ohai' + ('' if msg is None else f": {msg}"))


_LABEL_PURPOSE = ('label',)
_FORM_PARAMETER_NAME_PURPOSE = ('key',)  # near HTML_FORM_PARAMETER_NAME_PURPOSE

# #history-C.2
# #history-C.1
# #born
