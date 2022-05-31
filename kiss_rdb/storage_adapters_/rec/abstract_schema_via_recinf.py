import re

def abstract_entity_via_recfile_(recfile, store_record_type, listener):
    import re
    assert re.match('^[A-Z][a-zA-Z]+$', store_record_type)
    args = (
        'recinf',  # this should be under an abstraction layer
        f'-t{store_record_type}',
        '-d',  # include full record descriptors
        # '--print-sexps'  Would be neat but we didn't write it this way
        recfile)

    if listener:
        def express():
            yield ' '.join(args)  # ..
        listener('info', 'expression', 'recutils_command', 'recinf', express)

    from . import call_subprocess_ as func
    sout_lines = func(args, listener)
    abs_sch = abstract_schema_via_recinf_lines(sout_lines, listener)
    # ..
    return abs_sch[store_record_type]


def abstract_schema_via_recinf_lines(lines, listener):

    # == States

    def from_first_state():
        yield if_REC_line, handle_REC_line

    def from_after_REC_line():
        yield if_special_field, handle_non_REC_special_field
        yield if_blank_line, handle_blank_line

    # == Actions

    def handle_REC_line():
        state.column = 6  # len('%rec: ')
        s = layer_one_parse()['the_rest']
        if not re.match('^[a-zA-Z]+$', s):
            raise line_error(f"Strange-looking record set type: {s!r}")
        init_entity_scratch_space(s)
        move_to(from_after_REC_line)

    def handle_non_REC_special_field():
        typ, the_rest = layer_one_parse().groups()
        func = things.get(typ, None)
        if func is None:
            if 'rec' == typ:
                raise line_error("'rec' must be the first line in the group")
            raise line_error(f"{typ!r} unrecognized or not implemented, sorry")
        state.column = len(typ) + 3  # '%', ':', ' '
        func()

    def handle_blank_line():
        consume_entity_scratch_space()
        move_to(from_first_state)

    # == Matchers

    def if_REC_line():
        return 'rec' == any_name_of_special_field()

    def if_special_field():
        return layer_one_parse() is not None

    def if_blank_line():
        return '\n' == line

    # == Handlers for the Special Fields
    # (special fields in vendor documentation order:
    # https://www.gnu.org/software/recutils/manual/Record-Sets-Properties.html)

    def thing(f):  # decorator
        things[f.__name__] = f
        return f

    things = {}

    @thing
    def mandatory():
        dct = state.entity_scratch_space['is_optional']
        for term in right_hand_side_terms():
            # we could parse each term, but why
            see_native_field_name(term)
            dct[term] = False  # overwriting possibly previous values

    @thing
    def allowed():
        # #todo we don't understand exactly how this manifests practically natively
        for term in right_hand_side_terms():
            see_native_field_name(term)

    @thing
    def key():
        field_name = expect_this_number_of_terms(1)
        dct, k = state.entity_scratch_space, 'primary_key_native_name'
        if k in dct:
            who = dct['native_record_type_name']
            raise line_error(f"multiple key defs for {who!r}?")
        see_native_field_name(field_name)
        dct[k] = field_name

    @thing
    def doc():
        xx()

    @thing
    def typedef():
        """As far as we're concerned (EXPERIMENTALly), the only reason to ever
        have a typedef in a participating native collection is to align its
        typology lexicon to our standard, abstract one. The canonic example is
        the idea of a "paragraph" being a thing:

        For example, kiss recognizes "paragraph" as one of its built-in,
        universal standard abstract types. This is not, however, a native type
        here. Natively we can signify we want to use this type through a typedef.

        The typedef ("paragraph" in this example) may have actual meta-attribute
        values that make sense in some way natively (like "size 1920")

        We _enforce_ native naming conventions that were suggested (but not
        proscribed) in the native documentation.
        """

        expect_minmax_number_of_terms(2, None)
        native_type_name = right_hand_side_terms()[0]

        dct, k = typedef_cache, native_type_name
        if k in dct:
            raise line_error("redefinition of {native_type_name!r}?")

        *heads, tail = native_type_name.split('_')
        if 't' != tail:
            state.column += len(native_type_name)
            raise line_error("For now, must end in \"_t\"")

        if 1 < len(heads):
            snake = '_'.join(heads).lower()
        else:
            term, = heads  # ..
            snake = _snake_via_camel(term)
        dct[k] = type_macro_(snake, line_stopping_listener)

    @thing
    def type():
        """we can get three kinds of things from a '%type' statement:
        1) it may be the first mention of a field, in which case it determines
        the formal attribute's position. 2) when it's a foreign key definition,
        that and 3) (when it's a plain old type statement) it tells us type
        information about the field in native language.
        """

        # Be sure it's 2 or 3 terms long
        pcs = right_hand_side_terms()
        leng = len(pcs)
        if leng < 2 or 3 < leng:
            raise line_error("expecting 2 or 3 right hand side terms")

        # See the native field name
        stack = list(reversed(pcs))
        native_field_name = stack.pop()
        state.column += len(native_field_name) + 1
        see_native_field_name(native_field_name)

        # Maybe handle the foreign key
        if 3 == leng:
            return handle_foreign_key_thing(native_field_name, *stack)

        # Maybe it's a native type
        native_type_expression, = stack
        md = re.match('^(?:(?P<uc>[A-Z])|(?P<lc>[a-z]))', native_type_expression)
        if not md:
            raise line_error(f"type expression not [a-zA-Z]?")
        if md['lc']:
            tm = type_macro_(native_type_expression, line_stopping_listener)

        # If it's a typedef'd type, get the type macro from the cache
        else:
            dct, k = typedef_cache, native_type_expression
            tm = dct.get(k, None)
            if tm is None:
                raise line_error("Didn't see a %typedef for this")

        dct, k = state.entity_scratch_space['attr_types'], native_field_name
        if k in dct:
            raise line_error("Redefinition of type for {k!r}?")
        dct[k] = tm

    @thing
    def constraint():
        xx()

    # == Support for above

    def cache(f):  # decorator
        def use_f():
            if k not in cache_about_line:
                cache_about_line[k] = f()
            return cache_about_line[k]
        k = f.__name__
        return use_f

    def consume_entity_scratch_space():
        dct = state.entity_scratch_space
        formal_entity_camel_name = dct.pop('native_record_type_name')
        order = tuple(dct.pop('native_field_names_seen').keys())
        PKNN = dct.pop('primary_key_native_name', None)
        is_optional = dct.pop('is_optional')
        attr_types = dct.pop('attr_types')

        fk_pair = dct.pop('foreign_key_pair', None)
        fk_local_column_name = None
        if fk_pair:
            fk_local_column_name, foreign_table_name = fk_pair

        assert 0 == len(dct)
        state.entity_scratch_space = None

        # (reminder: recutils special fields aren't field-centric so we don't
        # have a choice: we have to wait until this point to build fattrs.)

        formal_attrs = []
        for native_attr_name in order:
            kw = {'listener': line_stopping_listener}

            if (tm := attr_types.get(native_attr_name)):
                kw['type_macro'] = tm

            if PKNN == native_attr_name:
                kw['is_primary_key'] = True

            if is_optional.get(native_attr_name):
                kw['null_is_OK'] = True

            if fk_local_column_name == native_attr_name:
                kw['is_foreign_key_reference'] = True
                kw['referenced_table_name'] = foreign_table_name
                kw['referenced_column_name'] = None  # assume PK of remote table

            # (changed to use native (camel) name for column_name at #history-C.1)
            assert re.match('^[A-Z]', native_attr_name)
            formal_attrs.append(formal_attribute_via(native_attr_name, **kw))

        fe = formal_entity_via(
            formal_entity_camel_name, formal_attrs, line_stopping_listener)
        state.several_formal_entities.append(fe)

    def handle_foreign_key_thing(native_field_name, _3rd_term, _2nd_term):
        if 'rec' != _2nd_term:
            raise line_error("Expecting 'rec' keyword (for FK declaration)")
        dct, k = state.entity_scratch_space, 'foreign_key_pair'
        if k in dct:
            raise line_error("Multiple foreign key declarations?")
        dct[k] = (native_field_name, _3rd_term)

    def see_native_field_name(name):
        state.entity_scratch_space['native_field_names_seen'][name] = None

    def init_entity_scratch_space(record_set_type_name):
        state.entity_scratch_space = (dct := {})
        dct['native_field_names_seen'] = {}
        dct['native_record_type_name'] = record_set_type_name
        dct['attr_types'] = {}
        dct['is_optional'] = {}

    def expect_this_number_of_terms(num):
        expect_minmax_number_of_terms(num, num)
        if 1 == num:
            return right_hand_side_terms()[0]
        return right_hand_side_terms()

    def expect_minmax_number_of_terms(minimum, maximum):
        act = len(right_hand_side_terms())
        if minimum is not None and act < minimum:
            direction = -1
        elif maximum is not None and maximum < act:
            direction = 1
        else:
            return
        only = ''
        if minimum == maximum:
            head = f"Needed exactly {minimum} term(s)"
        elif -1 == direction:
            head = f"Needed at least {minimum} term(s)"
            only = 'only '
        else:
            head = f"Needed at most {maximum} term(s)"
        what = "None" if 0 == act else f"{only}"
        raise line_error(f"{head}, had {what}")

    def any_name_of_special_field():
        md = layer_one_parse()
        return md and md['name_LHS']

    @cache
    def right_hand_side_terms():
        return tuple(layer_one_parse()['the_rest'].split(' '))

    @cache
    def layer_one_parse():
        return layer_one_rx.match(line)

    layer_one_rx = re.compile('^%(?P<name_LHS>[a-z]+):[ ](?P<the_rest>.+$)')
    typedef_cache = {}
    cache_about_line = {}

    from kiss_rdb.magnetics_.abstract_schema_via_definition import \
            abstract_schema_via_abstract_tables as abstract_schema_via, \
            abstract_table_via_name_and_abstract_columns as formal_entity_via, \
            abstract_column_via as formal_attribute_via, \
            type_macro_

    # == state machine mechanics

    def line_stopping_listener(*emi):
        assert 'expression' == emi[1]
        assert 'error' == emi[0]  # or just ignore 'info'
        big_string = ''.join(f"{s}\n" for s in emi[-1]())
        raise line_error(big_string)

    def line_error(message):
        if '\n' in message:
            message_lines = re.split('(?<=\n)(?=.)', message)
        else:
            message_lines = (message,)

        def lineser():
            for line in message_lines:
                yield line
            for line in _context_lines(input_line, lineno, state.column, lines):
                yield line

        input_line = line
        emit_line_error(lineser)
        return _Stop()

    def emit_line_error(lineser):
        listener('error', 'expression', 'line_error', lineser)

    def move_to(state_function):
        state.state_function = state_function

    state = from_first_state  # #watch-the-world-burn
    state.several_formal_entities = []
    move_to(from_first_state)

    class _Stop(RuntimeError):
        pass

    # ==

    lineno = 0
    try:
        for line in lines:
            lineno += 1
            state.column = None
            cache_about_line.clear()

            yes = False
            for matcher, action in state.state_function():
                yes = matcher()
                if yes:
                    break

            if not yes:
                lines = _explain_no_transition(
                        state.state_function, line, lineno, column, lines)
                emit_line_error(lambda: lines)
                raise _Stop()

            action()
        line = None

        if not hasattr(state, 'entity_scratch_space'):
            raise line_error("no recinf lines?")

        if state.entity_scratch_space:
            consume_entity_scratch_space()

        formal_ents = state.several_formal_entities
        if 0 == len(formal_ents):
            raise line_error("empty file?")

        return abstract_schema_via(formal_ents)  # ..
        # (we suspect that nowhere do we validate foreign key refs)

    except _Stop:
        pass


# == BEGIN ABSTRACTION CANDIDATES FOR STATE MACHINE

def _explain_no_transition(state_function, *context_pieces):
    words = state_function.__name__.split('_')
    words[0] = words[0].title()
    pcs = ' '.join(words)
    yield f"{' '.join(words)}, can't find a state transition."
    these = tuple(_noun_phrase_via_matcher(m) for m, a in state_function())
    yield f"Expecting {' or '.join(these)}."
    for line in _context_lines(*context_pieces):
        yield line[:-1]


def _noun_phrase_via_matcher(matcher):
    function_name = matcher.__name__
    md = re.match('^if_(?P<right_hand_side>.+)$', function_name)
    if not md:
        return function_name  # meh
    return md['right_hand_side'].replace('_', ' ')


def _context_lines(line, lineno, column, filehandle):
    left_piece = f"  {lineno}: "
    yield ''.join((left_piece, line[:-1], '\n'))
    if column is None:
        return
    yield ''.join((' '*len(left_piece), '-'*column, '^\n'))
    if not hasattr(filehandle, 'name'):
        return
    yield f"(in {filehandle.name})\n"

# == END

def _snake_via_camel(camel):
    memo = _snake_via_camel
    if memo.value is None:
        from kiss_rdb.storage_adapters_.rec import \
                name_convention_converters_ as nccs
        memo.value = nccs().snake_via_camel
    return memo.value(camel)


_snake_via_camel.value = None


def xx(msg=None):
    raise RuntimeError(''.join(('cover me', *((': ', msg) if msg else ()))))


if '__main__' == __name__:
    from kiss_rdb.storage_adapters_.rec._create_collection import \
            CLI_for_abstract_schema_via_recinf_ as _CLI
    from sys import stdin, stdout, stderr, argv
    exit(_CLI(stdin, stdout, stderr, argv))

# #history-C.1: use native (camel) name (not snake) as column name
# #born
