# (see the help screen to the embedded CLI of this module.)

import re


def _CLI(sin, sout, serr, argv):
    # see _help_lines

    # == BEGIN  # #history-C.1
    def usage_lines():
        yield "usage: {{prog_name}} [lots of primaries defining the model..]\n"  # [#857.13]
        yield "usage: {{prog_name}} -file FILE_WITH_SEXP_LINES\n"  # [#608.20]
        yield "usage: <output-sexp-lines> | {{prog_name}} -file -\n"  # [#608.20] [#608.21]

    from script_lib.via_usage_line import build_invocation
    invo = build_invocation(
            sin, sout, serr, argv, usage_lines=tuple(usage_lines()),
            docstring_for_help_description=_help_lines)
    rc, pt = invo.returncode_or_parse_tree()
    if rc is not None:
        return rc
    stack = invo.argv_stack
    dct = pt.values
    del pt
    # == END

    # If there's no remaining ARGV to parse (historical placement)
    if not stack:
        # If a filename was passed
        if dct:
            assert sin.isatty()
            path = dct.pop('file_with_sexp_lines')
            assert not dct
            fh = open(path)
        # Otherwise, read from STDIN
        else:
            assert not sin.isatty()
            fh = sin
        with fh:  # file will close at exit #here1
            abs_sch = abstract_schema_via_sexp_lines_(fh)  # listener one day
    else:  # #here5
        assert sin.isatty()
        assert not dct
        abs_sch = _CLI_state_machine(serr, sout, stack)

    if abs_sch is None:
        return 3

    w = sout.write
    for line in abs_sch.to_sexp_lines():
        w(line)
    return 0


def _help_lines(invocation):
    prog_namer = lambda: invocation.program_name
    yield '\n'
    yield "description: Make an abstract schema from a definition\n"
    yield '\n'
    yield "discussion:\n"
    yield '\n'
    yield "Normally this script parses ARGV for a schema definition to consume,\n"
    yield "and it produces an S-expression representation of that schema suitable\n"
    yield "to be consumed by other scripts that might consume such a format\n"
    yield "to do something interesting with it, like generate SQL or HTML forms.\n"
    yield '\n'
    yield "An abstract schema is simply a list of *one* or more formal entities.\n"
    yield "Each formal entity has a name and a list of *one* or more formal attributes.\n"
    yield "Each formal attribute has a name and maybe some properties.\n"
    yield '\n'
    yield "You can use this module/script to produce such a schema in two ways:\n"
    yield "from command line arguments (ARGV) and from S-expression strings\n"
    yield "(either in a file or from STDIN).\n"
    yield '\n'
    yield "An abstract schema can be defined on the command line by using\n"
    yield "certain keywords we call 'primaries' (in deference to BSD `find`),\n"
    yield "and sometimes through the use of POSITIONAL_ARGUMENTS as determined\n"
    yield "by the preceding primary.\n"
    yield '\n'
    yield "primaries and POSITIONAL_ARGUMENTS:\n"
    yield '\n'
    yield "-formal-entity  Starts a formal entity definition:\n"
    yield "                -formal-entity NAME <attr-def> [<attr-def> [..]]\n"
    yield "-attr           Starts a formal attribute definition:\n"
    yield "                -attr NAME [TYPE_MACRO] [<attr-prop> [<attr-prop> [..]]\n"
    yield "-key            An <attr-prop> flag indicating that this is the primary\n"
    yield "                key of the abstract entity. There can be max one.\n"
    yield "-optional       By default, formal attributes model required fields.\n"
    yield "                This flag makes the attribute optional.\n"
    yield "TYPE_MACRO      int|text|line|paragraph XX THIS IS WIP XX, not implemented yet.\n"
    yield '\n'
    yield "An example using the above:\n"
    yield '\n'
    yield f"  {prog_namer()} -formal-entity AA -attr BB -key -attr CC -optional\n"
    yield '\n'
    yield "The formal schema defined by your input is written as an S-expression\n"
    yield "to STDOUT. You can also use such an S-expression as *input* to the\n"
    yield "script, through the '-file' option. (Read from STDIN with '-file -'.)\n"
    yield "\n"
    yield "In such cases (if everything's working correctly), the same S-expression\n"
    yield "will be written to STDOUT as was read from input. This execution path\n"
    yield "exists merely to visually test that the round-trip works losslessly.\n"



def _CLI_state_machine(serr, sout, stack):

    def can_stop_here(f):
        f.can_stop_here = None  # hasattr is used
        return f

    # ==

    def from_beginning_state():
        yield if_FORMAL_ENTITY_keyword, will_move_to(from_after_formal_ent_kw)

    def from_after_formal_ent_kw():
        yield if_common_name, handle_entity_name

    def from_after_entity_name():
        yield if_ATTR_keyword, begin_attribute
        yield if_FORMAL_ENTITY_keyword, will_move_to(from_after_formal_ent_kw)
        yield if_end_of_stream, wow_you_made_it_to_the_end

    def from_after_attribute_keyword():
        yield if_common_name, handle_attribute_name

    @can_stop_here
    def from_after_attribute_name():
        yield if_probably_type_macro, handle_type_macro
        for k, f in from_after_type_macro():
            yield k, f

    @can_stop_here
    def from_after_type_macro():
        yield if_ATTR_keyword, roll_over_attr_because_next_attr
        yield if_OPTIONAL_keyword, handle_optional
        yield if_KEY_keyword, handle_key

    # ==

    def if_probably_type_macro():
        s = stack[-1]
        assert s  # (new at #history-C.1)
        if '-' == s[0]:
            return
        return True  # validate #here2

    def if_common_name():
        if stack[-1] is None:
            return
        return re.match('^[A-Za-z][A-Za-z0-9_]+$', stack[-1])

    def if_FORMAL_ENTITY_keyword():
        return '-formal-entity' == stack[-1]

    def if_ATTR_keyword():
        return '-attr' == stack[-1]

    def if_OPTIONAL_keyword():
        return '-optional' == stack[-1]

    def if_KEY_keyword():
        return '-key' == stack[-1]

    # ==

    def handle_entity_name():
        dct = {'formal_entity_name': stack_pop(), 'formal_attrs_dct': {}}
        state.formal_entity_args = dct
        return move_to(from_after_entity_name)

    def handle_attribute_name():
        state.formal_attr_params = {'formal_attribute_name': stack_pop()}
        return move_to(from_after_attribute_name)

    def handle_type_macro():
        arg = stack_pop()
        tm = type_macro_(arg, listener)
        if tm is None:
            return
        state.formal_attr_params['type_macro'] = tm
        return move_to(from_after_type_macro)

    def handle_optional():
        stack_pop()
        state.formal_attr_params['null_is_OK'] = True
        return True  # stay in current state

    def handle_key():
        stack_pop()
        state.formal_attr_params['is_primary_key'] = True
        return True

    def roll_over_attr_because_next_attr():
        ok = close_current_formal_attribute()
        if not ok:
            return
        stack_pop()
        return move_to(from_after_attribute_keyword)

    def begin_attribute():
        stack_pop()
        return move_to(from_after_attribute_keyword)

    def close_because_end_of_input():
        assert 0 == len(stack)
        if not state.formal_attr_params:
            return
        ok = close_current_formal_attribute()
        assert ok  # raise don't check return value it's too

    def close_current_formal_attribute():
        dct = state.formal_attr_params
        state.formal_attr_params = None
        k = dct.pop('formal_attribute_name')
        abstract_type = dct.pop('type_macro', 'text')  # ..
        coll_dct = state.formal_entity_args['formal_attrs_dct']
        if k in coll_dct:
            xx(f"more than one definition for attribute '{k}'")
        abs_attr = abstract_column_via(k, abstract_type, None, **dct)
        coll_dct[k] = abs_attr
        return True

    def close_current_formal_entity():
        coll_dct = state.abstract_schema_dct
        dct = state.formal_entity_args
        state.formal_entity_args = None
        k = dct.pop('formal_entity_name')
        if k in coll_dct:
            xx(f"more than one definition for entity '{k}'")
        attr_dct = dct.pop('formal_attrs_dct')
        assert not dct
        abs_ent = formal_ent_via(k, attr_dct.values(), listener=None)
        # (the above will check redundanty for collision, meh)
        coll_dct[k] = abs_ent
        return True

    # == state & input mechanics

    def find_next_action():
        for matcher, action in state.function():
            yn = matcher()
            if yn:
                return action
        write_lines_about_expected_from_current_state()

    def will_move_to(where):
        def action():
            stack_pop()
            return move_to(where)
        return action

    def move_to(where):
        state.function = where
        return True

    def stack_pop():
        tok = stack.pop()
        state.tokens_did.append(tok)  # should be rotating buffer but meh
        return tok

    def write_lines_about_expected_from_current_state():
        head_token = repr(stack[-1]) if 1 < len(stack) else 'end of input'
        from_where = state.function.__name__.replace('_', ' ')
        serr.write(f"unexpected {head_token} {from_where}\n")
        def these():
            for matcher, _ in state.function():
                yield _human_via_fname(matcher.__name__)

        these = tuple(these())
        if 1 < len(these):
            one_of, end = f' one of: (', ')'
        else:
            one_of, end = ': ', ''
        serr.write(f"expecting{one_of}{', '.join(these)}{end}\n")
        for line in _two_context_lines(state.tokens_did, stack):
            serr.write(line)

    def listener(*emi):
        *chan, lineser = emi
        assert 'expression' == chan[1]
        for line in lineser():
            serr.write(f"{line}\n")

    # ==

    state = write_lines_about_expected_from_current_state  # #watch-the-world-burn
    state.abstract_schema_dct = {}
    state.function = from_beginning_state
    state.tokens_did = []

    from kiss_rdb.magnetics_.abstract_schema_via_definition import \
            abstract_schema_via_dictionary, \
            abstract_table_via_name_and_abstract_columns as formal_ent_via, \
            abstract_column_via, \
            type_macro_

    while True:
        action = find_next_action()
        if not action:
            return
        ok = action()
        if not ok:
            return
        if 0 == len(stack):
            break

    if not hasattr(state.function, 'can_stop_here'):
        write_lines_about_expected_from_current_state()
        return

    close_because_end_of_input()
    close_current_formal_entity()  # SOON expand grammar for multiple ents
    dct = state.abstract_schema_dct
    state.abstract_schema_dct = None
    return abstract_schema_via_dictionary(dct)


def _two_context_lines(tokens_did, stack):
    margin = '  '
    pieces, curr_len, max_len = [], 0, 60
    would_add_these = []

    # Keep adding tokens already done (from the end) till we would meet/exceed
    first = True
    while len(tokens_did):
        if first:
            first = False
            would_add_len = 0
        else:
            would_add_these.append(' ')
            would_add_len = 1
        tok = tokens_did[-1]
        would_add_these.append(tok)
        would_add_len += len(tok)
        would_be_len = curr_len + would_add_len
        if max_len < would_be_len:
            break
        for s in would_add_these:
            pieces.append(s)
        would_add_these.clear()
        tokens_did.pop()
        curr_len = would_be_len
        if max_len == curr_len:
            break
    if not first:
        pieces.append(margin)
    pieces = list(reversed(pieces))

    # If we hadn't reached the end of input, add the head token
    if 1 < len(stack):
        pieces.append(' ')
        pieces.append(stack[-1])
        cursor_begin = curr_len + 1
        cursor_width = len(stack[-1])
    else:
        cursor_begin = curr_len
        cursor_width = 1

    pieces.append('\n')
    yield ''.join(pieces)
    yield ''.join((margin, ' '*cursor_begin, '^'*cursor_width, '\n'))


def _human_via_fname(fname):
    stack = list(reversed(fname.split('_')))
    if 'if' != stack[-1]:
        return repr(fname)
    stack.pop()
    if 'keyword' == stack[0]:
        tail = '-'.join(reversed(stack[1:])).lower()
        return f"'-{tail}'"
    return ' '.join(reversed(stack))


# ==

def abstract_schema_via_sexp_lines_(fh):  # #testpoint

    def main():
        read_file_into_big_string()
        avoid_common_errors_from_vendor_lib()
        from sexpdata import loads as sexpdata_loads
        sx = sexpdata_loads(state.big_string)
        return _abstract_schema_via_sexp(sx)

    state = main  # #watch-the-world-burn

    def avoid_common_errors_from_vendor_lib():

        # Avoid this one FIXME error from vendor
        if 0 == len(state.big_string):
            stop("Input is empty string")

        # Avoid common issues with the parse
        if '(' != state.big_string[0]:
            stop(f"Expecting '(' had {state.big_string[0]!r} for first character")

    def read_file_into_big_string():
        state.big_string = big_string_somehow()

    def big_string_somehow():
        # (it's painful for us to do this but the alternative is absurd:)
        if hasattr(fh, 'read'):
            return fh.read()
        return ''.join(fh)  # ..

    stop = _stop

    try:
        return main()
    except _Stop as _:
        e = _
    msgs = [''.join(("Error: ", str(e), '\n'))]
    if hasattr(fh, 'name'):
        msgs.append("(in {fh.name})\n")
    xx(''.join(msgs))


def _abstract_schema_via_sexp(sx):  # #testpoint
    # #todo needs a context stack too

    def main():
        expect_and_consume_name('abstract_schema')
        expect_and_push('properties')
        expect_end_and_pop()
        state.out_stack.append([])
        expect_and_consume_one_or_more('abstract_entity', consume_entity)
        expect_end_and_pop()
        assert not state.stack_stack
        assert 1 == len(state.out_stack)
        abs_ents, = state.out_stack
        return abs_sch_via(abs_ents)

    state = main  # #watch-the-world-burn
    state.out_stack = []
    state.stack_stack = [list(reversed(sx))]
    del sx

    def use_stack(f):
        def use_f(*args):
            return f(*args, stack())
        return use_f

    # ==

    def consume_entity():
        name = expect_and_consume_any_string()
        attrs = []
        state.out_stack.append(attrs)
        expect_and_consume_one_or_more('abstract_attribute', consume_attribute)
        abs_ent = abs_ent_via(name, attrs, listener=None)
        state.out_stack.pop()
        state.out_stack[-1].append(abs_ent)
        expect_end_and_pop()

    @use_stack
    def consume_attribute(stack):
        name = expect_and_consume_any_string()
        type_macro = expect_and_consume_any_string()
        kw = {}

        # expect_and_consume_zero_or_more()
        while len(stack):
            if head_token_is_branch_node():
                pop_push()
                expect_and_consume_name('foreign_key')
                table_name = expect_and_consume_any_string()
                expect_end_and_pop()  # ..
                kw['is_foreign_key_reference'] = True
                kw['referenced_table_name'] = table_name
                continue
            s = stack.pop()
            if 'optional' == s:
                kw['null_is_OK'] = True
            elif 'key' == s:
                kw['is_primary_key'] = True
            else:
                xx(s)
        expect_end_and_pop()
        abs_attr = abstract_column_via(name, type_macro, listener=None, **kw)
        state.out_stack[-1].append(abs_attr)

    # ==

    @use_stack
    def expect_and_consume_one_or_more(name, consume, stack):
        while True:
            leng = len(state.stack_stack)
            expect_and_push(name)
            consume()
            assert leng == len(state.stack_stack)
            if 0 == len(stack):
                break
            if not head_token_is_branch_node():
                break
            # (we should be checking that first item of head is string but meh)

    @use_stack
    def expect_and_push(name, stack):
        if 0 == len(stack):
            stop(f"expected '{name}' at end of sexp")
        expect_head_token_is_branch_node()
        pop_push()
        expect_and_consume_name(name)

    @use_stack
    def expect_and_consume_name(name, stack):
        if 0 == len(stack):
            stop(f"expected '{name}' had empty stack")
        expect_string()
        x = stack[-1]
        if x != name:
            stop(f"expected '{name}' had {x!r}")
        stack.pop()

    @use_stack
    def expect_and_consume_any_string(stack):
        if 0 == len(stack):
            stop("expected string had empty stack")
        expect_string()
        return stack.pop()

    @use_stack
    def expect_string(stack):
        x = stack[-1]
        if not isinstance(x, str):
            stop(f"expected string had {_trunc(x)}")

    @use_stack
    def expect_head_token_is_branch_node(stack):
        if head_token_is_branch_node():
            return
        stop(f'expecting node to be string, had {_trunc(stack[-1])}')

    @use_stack
    def head_token_is_branch_node(stack):
        x = stack[-1]
        if hasattr(x, 'isascii'):
            return False

        # (set(dir(""))(set(dir([])).intersection(set(dir(())))))
        assert hasattr(x, '__class_getitem__')
        return True

    @use_stack
    def expect_end_and_pop(stack):
        if len(stack):
            stop(f"Expecting no more items. Unexpected: {_trunc(stack[-1])}")
        state.stack_stack.pop()

    def pop_push():
        x = state.stack_stack[-1].pop()
        state.stack_stack.append(list(reversed(x)))

    def stack():
        return state.stack_stack[-1]

    from kiss_rdb.magnetics_.abstract_schema_via_definition import \
            abstract_schema_via_abstract_tables as abs_sch_via, \
            abstract_table_via_name_and_abstract_columns as abs_ent_via, \
            abstract_column_via

    stop = _stop

    try:
        return main()
    except _Stop as _:
        e = _
    msgs = [''.join(("Error: ", str(e), '\n'))]
    xx(''.join(msgs))


def _stop(err):
    raise _Stop(err)


class _Stop(RuntimeError):
    pass

# ==

def pretty_print_sexp_(mixed_branch_sexp, indent_for_children, margin):
    max_width = 60  # ..
    galley = []  # shared by the whole word

    def recurse_into_branch(my_margin, x):

        def flush_line():
            galley.append('\n')
            line = ''.join(galley)
            galley.clear()
            state.is_first_on_line = True
            state.w = 0
            return line

        def append_to_galley():
            if state.is_first_on_line:
                state.is_first_on_line = False
            else:
                galley.append(' ')
            galley.append(surface_s)
            state.w = would_be_width

        state = flush_line  # #watch-the-world-burn

        # Every such line run will start with the margin and the open paren
        assert not galley
        galley.append(my_margin)
        galley.append('(')
        state.is_first_on_line = True
        state.w = sum(len(s) for s in galley)

        ch_margin = f'{my_margin}{indent_for_children}'

        stack = list(reversed(tuple(x)))

        while len(stack):
            x = stack.pop()

            is_string = is_none = False
            if isinstance(x, str):
                is_string = True
            elif x is None:
                is_none = True

            if is_string:

                # (we can't use 'repr' because single-quoted strings not ok)
                inner = escape_these_rx.sub(lambda md: f'\\{md[0]}', x)
                surface_s = ''.join(('"', inner, '"'))
            elif is_none:
                surface_s = '()'  # I DONT KNOW

            if is_string or is_none:

                token_len = len(surface_s)
                would_be_width = state.w + token_len
                if not state.is_first_on_line:
                    would_be_width += 1

                # When the new string does NOT meet/put us over, keep looking
                if would_be_width < max_width:
                    append_to_galley()

                # New string puts us on or over the max. When it's *on*, no
                # need to keep looking. If _over_ but it's the first item,
                # print it now even tho it exceeds, else infinite loop
                elif would_be_width == max_width or state.is_first_on_line:
                    append_to_galley()
                    yield flush_line()
                # New string would put us over and it's not first.
                else:
                    yield flush_line()
                    galley.append(my_margin)
                    would_be_width = len(my_margin) + token_len
                    append_to_galley()
            else:
                # It would be a lot cooler if we allowed "short" branch nodes
                # to flow all within the same line if they fit. but this would
                # require a complexity we are not interested in implementing yet

                # (not sure if there's a guarantee that we have any galley'd)
                if len(galley):
                    yield flush_line()

                for line in recurse_into_branch(ch_margin, x):
                    yield line

        if 0 == len(galley):
            galley.append(my_margin)

        galley.append(')')
        yield flush_line()

    import re
    escape_these_rx = re.compile(r'[\\"]')

    return recurse_into_branch(margin, mixed_branch_sexp)


def _trunc(x):
    big_string = repr(x)
    leng = len(big_string)
    if leng <= 20:
        return big_string
    return ''.join((big_string[:17], '...'))


def xx(msg=None):
    raise RuntimeError(''.join(('have fun', *((': ', msg) if msg else ()))))


if '__main__' == __name__:
    import sys
    exit(_CLI(sys.stdin, sys.stdout, sys.stderr, sys.argv))

# #history-C.2 lose a CLI support function (abstracted too early) to a neighbor
# #history-C.1 "engine" not hand-written CLI
# #born
