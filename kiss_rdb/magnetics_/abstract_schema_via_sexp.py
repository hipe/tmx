# Actually this is XX not XX but we're hiding that fact

import re


def _CLI(sin, sout, serr, argv):
    prog_name_long = argv[0]
    stack = [None, * reversed(argv[1:])]  # 'None' signals end of stream

    def prog_name():
        from os.path import basename
        return basename(prog_name_long)

    def help_was_passed_as_far_as_we_care_to_check():
        leng = stack_len()
        if 0 == leng:
            return False
        rx = re.compile('^--?h(?:e(?:lp?)?)?$')
        if rx.match(stack[-1]):
            return True
        if 1 == leng:
            return False
        return rx.match(stack[1])

    def stack_len():
        return len(stack) - 1  # because of special token 'None'

    if help_was_passed_as_far_as_we_care_to_check():
        for line in _help_lines(prog_name):
            serr.write(line)
        return 0

    # Normalize this not-necessary arg so subsequent validation is simpler
    if 0 == stack_len() and not sin.isatty():  # (#here2)
        stack.push('-')
        stack.push('-file')

    # Resolve any file arg
    file_arg = None
    if stack_len() and '-file' == stack[-1]:
        stack.pop()
        assert( file_arg  := stack.pop() )  # arg is required. UX meh
        # Assert that file arg (if present) was the only arg
        if stack_len():
            _ = repr(stack[-1])
            serr.write(f"'-file' primary must occur alone. Unexpected: {_}\n")
            return 3

    # A rule table that permutes {[no] STDIN}x{no_file_arg|file_arg_is[p|d]}

    stdin_case = 'no_STDIN' if sin.isatty() else 'STDIN'
    if file_arg is None:
        file_arg_case = 'no_file_arg'
    elif '-' == file_arg:
        file_arg_case = 'file_arg_is_dash'
    else:
        file_arg_case = 'file_arg_is_path'


    case = (stdin_case, file_arg_case)
    fh = err = None
    if ('no_STDIN', 'no_file_arg') == case:
        abs_sch = _CLI_state_machine(serr, sout, stack)
    elif ('no_STDIN', 'file_arg_is_path') == case:
        fh = open(file_arg)  # #here1
    elif ('no_STDIN', 'file_arg_is_dash') == case:
        err = "with '-file -', expecting STDIN but term is interactive\n"
    elif ('STDIN', 'no_file_arg') == case:
        assert stack_len()  # because #here2
        err = f"can't use STDIN *and* ARGV. unexpected: {stack[-1]!r}\n"
    elif ('STDIN', 'file_arg_is_path') == case:
        err = f"can't use STDIN *and* '-file PATH'. Use '-file -'.\n"
    else:
        assert ('STDIN', 'file_arg_is_dash') == case
        fh = sin

    if err:
        serr.write(err)
        return 3

    if fh:
        with fh:
            abs_sch = abstract_schema_via_sexp_lines_(serr, fh)

    if abs_sch is None:
        return 3

    w = sout.write
    for line in abs_sch.to_sexp_lines():
        w(line)
    return 0


def _help_lines(prog_namer):
    yield "It's too hard to explain this syntax formally (for now).\n"
    yield "Example: XX\n\n"


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
        yield if_ATTR_keyword, roll_over_attr_because_next_attr
        yield if_OPTIONAL_keyword, handle_optional
        yield if_KEY_keyword, handle_key
        yield if_end_of_input, FINISH_SOMEHOW

    # ==

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

    def if_end_of_input():
        one_way = 1 == len(stack)
        other_way = stack[-1] is None
        assert one_way == other_way
        return one_way

    # ==

    def handle_entity_name():
        dct = {'formal_entity_name': stack_pop(), 'formal_attrs_dct': {}}
        state.formal_entity_args = dct
        return move_to(from_after_entity_name)

    def handle_attribute_name():
        state.formal_attr_params = {'formal_attribute_name': stack_pop()}
        return move_to(from_after_attribute_name)

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

    def FINISH_SOMEHOW():
        if state.formal_attr_params:
            close_current_formal_attribute()
        stack_pop()
        return True

    def close_current_formal_attribute():
        dct = state.formal_attr_params
        state.formal_attr_params = None
        k = dct.pop('formal_attribute_name')
        coll_dct = state.formal_entity_args['formal_attrs_dct']
        if k in coll_dct:
            xx(f"more than one definition for attribute '{k}'")
        abstract_type = 'text'  # ..
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

    # ==

    state = write_lines_about_expected_from_current_state  # #watch-the-world-burn
    state.abstract_schema_dct = {}
    state.function = from_beginning_state
    state.tokens_did = []

    from kiss_rdb.magnetics_.abstract_schema_via_definition import \
            abstract_schema_via_dictionary, \
            abstract_table_via_name_and_abstract_columns as formal_ent_via, \
            abstract_column_via

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

def abstract_schema_via_sexp_lines_(serr, sin):
    # #todo needs a context stack too

    # (it's painful for us to do this but the alternative is absurd:)
    big_string = sin.read()

    def main():
        avoid_common_errors_from_vendor_lib()
        from sexpdata import loads as sexpdata_loads
        state.stack_stack = [list(reversed(sexpdata_loads(big_string)))]
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
                xx()
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

    def avoid_common_errors_from_vendor_lib():
        # Avoid this one FIXME error from vendor
        if 0 == len(big_string):
            stop("Input is empty string")

        # Avoid common issues with the parse
        if '(' != big_string[0]:
            stop(f"Expecting '(' had {big_string[0]!r} for first character")

    from kiss_rdb.magnetics_.abstract_schema_via_definition import \
            abstract_schema_via_abstract_tables as abs_sch_via, \
            abstract_table_via_name_and_abstract_columns as abs_ent_via, \
            abstract_column_via

    def stop(err):
        raise _Stop(err)

    class _Stop(RuntimeError):
        pass

    try:
        return main()
    except _Stop as e:
        serr.write(''.join(("Error: ", str(e), '\n')))
        serr.write(f"(in {sin.name})\n")


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
            if isinstance(x, str):

                # (we can't use 'repr' because single-quoted strings not ok)
                inner = escape_these_rx.sub(lambda md: f'\\{md[0]}', x)
                surface_s = ''.join(('"', inner, '"'))

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

# #born
