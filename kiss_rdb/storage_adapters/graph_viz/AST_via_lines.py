from dataclasses import dataclass as _dataclass


# == Simple Models (above the sexp layer)

@_dataclass
class _NodeSexp:
    node_identifier: str
    attributes: dict
    lineno: int

    def __getitem__(self, i):
        assert 0 == i
        return self.sexp_type

    sexp_type = 'node_expression'


@_dataclass
class _EdgeSexp:
    left_node_ID: str
    left_port: str
    right_node_ID: str
    right_port: str
    attributes: dict
    lineno: int

    def to_string(self):
        return ''.join(s for row in self._to_piece_rows() for s in row)

    def _to_piece_rows(self):
        yield self.left_node_ID, ':', self.left_port
        yield ('->',)
        yield self.right_node_ID, ':', self.right_port

    def __iter__(self):
        return (getattr(self, k) for k in self._fields)

    def __getitem__(self, i):
        assert 0 == i
        return self.sexp_type

    _fields = ('sexp_type', 'left_node_ID', 'left_port',
               'right_node_ID', 'right_port', 'attributes', 'lineno')

    sexp_type = 'edge_expression'


def _finish_alist(alist):
    # if we ever keep whitespace for etc, move this up so you map sexps
    # to become AST's
    res = {}
    for k, sx in alist:
        if k in res:
            xx(f"cover me: clobber: {k!r}")
        typ, val = sx
        if 'identifier_as_attribute_value' == typ:
            pass
        else:
            assert 'double_quoted_string' == typ
            val = ''.join(_detach_from_surface(val))
        res[k] = val
    return res


def _detach_from_surface(sxs):
    itr = iter(sxs)
    for (k1, v1) in itr:
        (k2, v2) = next(itr)
        assert 'unencoded_string_content' == k1
        assert 'any_escape_sequence' == k2
        yield v1
        if v2 is None:
            continue
        if 'newline_escape_sequence' == k2:
            yield '\n'
        elif 'double_quote_escape_sequence' == k2:
            yield '"'
        else:  # (etc)
            assert 'tab_escape_sequence' == k2
            yield '\t'


# == Main thing (sexp layer is below this line)

def sexps_via_lines(lines, listener=None):
    """NOTE this is a rough proof-of-concept. It will *not* parse all

    GraphViz documents, nor is it intended to [etc the usual disclaimer..]

    However, wherever it was a good fit, we tried to use names from the
    published grammar
    """

    # == States [#008.2]

    def from_beginning_state():
        yield if_open_digraph_line, move_to_inside_digraph

    def from_root_of_document():
        yield if_blank_line, ignore_for_now
        yield if_open_multiline_comment_line, enter_multiline_comment

    def from_inside_digraph():
        yield if_blank_line, ignore_for_now
        yield if_open_node_statement, handle_line_that_begins_node_statement
        yield if_edge_statement, handle_line_that_begins_edge_statement
        yield if_set_an_attribute_statement, ignore_for_now
        # comment line one day
        yield if_close_clurly, close_digraph

    def from_inside_attribute_list():
        yield if_scan_attribute_assignment_left_hand_side, push_to_attr_value
        yield if_skip_a_comma, do_nothing
        yield if_scan_close_square_bracket, pop_out_of_attr_list_kinda_big_deal

    def from_before_attribute_value():
        yield if_scan_a_double_quote, BEGIN_TO_PARSE_DOUBLE_QUOTED_VALUE
        yield true, parse_a_not_double_quoted_value

    def from_inside_double_quoted_string():
        yield true, parse_rest_of_inside_quoted_string

    def from_inside_multiline_comment():
        yield if_line_that_closes_multiline_comment, pop_out_of_multiline_comme
        yield true, ignore_for_now

    # == Actions

    def move_to_inside_digraph():
        move_to(from_root_of_document)
        push_to(from_inside_digraph)

    # -- mess with line scanning

    def handle_line_that_begins_node_statement():
        store['element_start_lineno'] = lineno
        store['current_entity_type'] = 'node'

        md = store.pop('last_match')
        store['current_node_identifier'] = md['node_identifier']

        scn = build_scanner(line)
        scn.advance_to_position(md.span()[1])
        store['current_string_scanner'] = scn

        push_to(from_inside_attribute_list)
        return parse_to_end_of_line()

    def handle_line_that_begins_edge_statement():
        store['element_start_lineno'] = lineno
        store['current_entity_type'] = 'edge'

        md = store.pop('last_match')
        store['left_node_identifier'], store['left_node_port'] = md.groups()

        scn = build_scanner(line)
        scn.advance_to_position(md.span()[1])
        store['current_string_scanner'] = scn

        store['right_node_identifier'] = scn.scan_required(identifier)
        rhs_port = None
        if ':' == scn.peek(1):
            scn.advance_by_one()
            rhs_port = scn.scan_required(identifier)
        store['right_node_port'] = rhs_port

        scn.skip_required(open_square_bracket)
        store['current_attribute_list'] = []

        push_to(from_inside_attribute_list)
        return parse_to_end_of_line()

    def push_to_attr_value():
        store['current_attribute_name']  # sanity check, catch it early
        push_to(from_before_attribute_value)

    def BEGIN_TO_PARSE_DOUBLE_QUOTED_VALUE():
        scn = self.scn
        sxs = _parse_rest_of_double_quoted_string_so_far(scn)
        typ, = sxs[-1]
        assert 'from_before_attribute_value' == stack[-1].__name__
        store['current_attribute_list'] = []
        if 'end_of_surface_line' == typ:
            sxs.pop()  # #here1
            store['current_double_quoted_string_sexp'] = sxs
            push_to(from_inside_double_quoted_string)
            return
        assert 'end_of_double_quoted_string' == typ
        xx("easy no problem. when the label ends on the same line. EASY")

    def parse_rest_of_inside_quoted_string():
        scn = build_scanner(line)
        sxs = _parse_rest_of_double_quoted_string_so_far(scn)
        typ, = sxs[-1]
        if 'end_of_surface_line' == typ:
            sxs.pop()  # #here1
            store['current_double_quoted_string_sexp'].extend(sxs)
            return  # stay
        assert 'end_of_double_quoted_string' == typ
        sxs.pop()  # #here1

        accum_sxs = store.pop('current_double_quoted_string_sexp')
        accum_sxs.extend(sxs)

        k = store.pop('current_attribute_name')

        val_sexp = 'double_quoted_string', accum_sxs
        store['current_attribute_list'].append((k, val_sexp))
        assert 'from_inside_double_quoted_string' == stack.pop().__name__
        assert 'from_before_attribute_value' == stack.pop().__name__  # 😢
        store['current_string_scanner'] = scn
        return parse_to_end_of_line()

    def parse_to_end_of_line():
        res = None
        while self.scn.more:
            action = find_transition()
            res = action()
            if res is None:
                continue
            # The only way you can produce something is at the end of the line
            assert self.scn.empty
            break
        store.pop('current_string_scanner')
        return res

    def parse_a_not_double_quoted_value():
        literal_value = self.scn.scan_required(identifier)
        k = store.pop('current_attribute_name')
        val_sexp = 'identifier_as_attribute_value', literal_value
        store['current_attribute_list'].append((k, val_sexp))
        assert 'from_before_attribute_value' == stack.pop().__name__

    # --

    def pop_out_of_attr_list_kinda_big_deal():
        assert 'from_inside_attribute_list' == stack[-1].__name__
        stack.pop()
        assert 'from_inside_digraph' == stack[-1].__name__  # or not
        typ = store.pop('current_entity_type')
        alist = store.pop('current_attribute_list')
        if 'edge' == typ:
            return finish_edge(alist)
        assert 'node' == typ
        return finish_node(alist)

    def finish_node(alist):
        iden = store.pop('current_node_identifier')
        this = _finish_alist(alist)  # ..
        use_lineno = store.pop('element_start_lineno')
        sx = _NodeSexp(iden, this, use_lineno)
        return 'yield_this', sx

    def finish_edge(alist):
        these = (
            store.pop('left_node_identifier'), store.pop('left_node_port'),
            store.pop('right_node_identifier'), store.pop('right_node_port'))
        this = _finish_alist(alist)  # ..
        use_lineno = store.pop('element_start_lineno')
        sx = _EdgeSexp(*these, this, use_lineno)
        return 'yield_this', sx

    def close_digraph():
        assert 'from_inside_digraph' == stack[-1].__name__
        stack.pop()
        assert 'from_root_of_document' == stack[-1].__name__

    # --

    def enter_multiline_comment():
        push_to(from_inside_multiline_comment)

    def pop_out_of_multiline_comme():
        assert 'from_inside_multiline_comment' == stack[-1].__name__
        stack.pop()

    def ignore_for_now():
        pass

    do_nothing = ignore_for_now

    # == Tests

    def if_blank_line():
        return '\n' == line

    def if_open_multiline_comment_line():
        md = open_comment_simple_rx.match(line)
        if md is None:
            return
        pos = line.find('*/', 2)
        if -1 != pos:
            xx("ugh can we not have single-line comments please")
        return True

    def if_line_that_closes_multiline_comment():
        pos = line.find('*/')
        return -1 != pos

    def if_open_digraph_line():
        return re.match(f'digraph {iden_rsx}[ ]?\\{{$', line)

    def if_set_an_attribute_statement():
        return re.match(f'{iden_rsx}=', line)  # big meh

    def if_open_node_statement():
        md = looks_like_open_node_rx.match(line)
        if md is None:
            return
        store['last_match'] = md
        return True

    def if_edge_statement():
        md = huge_peek_for_edge_rx.match(line)
        if md is None:
            return
        store['last_match'] = md
        return True

    # -- tests that use scanner

    def if_scan_attribute_assignment_left_hand_side():
        scn = self.scn
        scn.skip(one_or_more_space_characters)  # #here2
        s = scn.scan(identifier)
        if s is None:
            return
        store['current_attribute_name'] = s
        scn.skip_required(equals)
        return True

    def if_scan_a_double_quote():
        return self.scn.skip(double_quote)

    def if_skip_a_comma():
        # assume #here2
        return self.scn.skip(comma)

    def if_scan_close_square_bracket():
        scn = self.scn
        yes = scn.skip(close_square_bracket)
        if not yes:
            return
        # == BEGIN _skip_some_kind_of_end_of_line
        if '\n' == scn.peek(1):
            scn.advance_by_one()
            return True
        xx(f"Maybe this is an end-of-line comment which is allowed: {scn.rest()}")  # noqa: E501
        # == END

    def if_close_clurly():
        return '}\n' == line  # meh

    def true():
        return True

    # == used below

    iden_rsx = '[a-zA-Z_][a-zA-Z0-9_]*'

    # ==

    def cstacker():
        return ({'line': line},)

    from text_lib.magnetics.string_scanner_via_string import \
        build_throwing_string_scanner_and_friends as func
    o, build_scanner, stop = func(listener, cstacker)
    assert 'pattern_via_description_and_regex_string' == o.__name__

    identifier = o('identifier', iden_rsx)
    open_square_bracket = o('open square bracket', r'\[')
    equals = o("equals sign", '=')
    double_quote = o("double quote", '"')
    comma = o('comma', ',')
    close_square_bracket = o('close square bracket', r'\]')
    one_or_more_space_characters = o('spaces', '[ ]+')

    # ==

    import re

    looks_like_open_node_rx = re.compile(f"""
        (?P<node_identifier> {iden_rsx} )
        \\[
    """, re.VERBOSE)

    huge_peek_for_edge_rx = re.compile(f"""
        (?P<left_node_identifier> {iden_rsx} )
        (?: : (?P<left_node_port> {iden_rsx} ) )?
        ->
    """, re.VERBOSE)

    open_comment_simple_rx = re.compile(r'/\*')

    # == Interacting with FSA state:

    def move_to(state_function):
        stack[-1] = state_function

    def push_to(state_function):
        stack.append(state_function)

    # ==

    def find_transition():
        for test, action in stack[-1]():
            yn = test()
            if yn:
                return action

        reason_head = f"No transition found {stack[-1].__name__}"
        scn = store.get('current_string_scanner')
        if scn:
            def lines():
                yield ''.join(reason_head, '\n')
                yield "  {line}"
                yield ''.join(('  ', '-'*scn.pos, '^\n'))
            reason = ''.join(lines())
        else:
            reason = f"{reason_head} for {line!r}"
        xx(reason)

    # ==

    class HeyGuysWhatsUp:
        @property
        def scn(self):
            return store['current_string_scanner']

    self = HeyGuysWhatsUp()
    store = _NoClobberDict()
    stack = [from_beginning_state]

    lineno = 0
    try:
        for line in lines:
            lineno += 1
            while True:  # (there may be a 'redo' directive in the future)
                action = find_transition()
                direc = action()
                if direc is None:
                    break  # parse next line, if any
                typ = direc[0]
                assert 'yield_this' == typ
                product, = direc[1:]
                yield product
                break  # parse next line, if any
    except _Stop:
        return

    if 1 != len(stack):
        xx("something didn't close, can't end {stack[-1].__name__}")


func = sexps_via_lines


def _parse_rest_of_double_quoted_string_so_far(scn):
    o = _parse_rest_of_double_quoted_string_so_far
    if o.x is None:
        o.x = _build_parse_rest_of_etc()
    return o.x(scn)


_parse_rest_of_double_quoted_string_so_far.x = None


def _build_parse_rest_of_etc():

    def parse_rest_of_double_quoted_string_so_far(scn):
        return list(do_parse_rest_of_double_quoted_string_so_far(scn))
        # list because allow popping #here1 because meh

    def do_parse_rest_of_double_quoted_string_so_far(scn):
        # Keep scanning the inside of the string while you have
        # either a run of ordinary content or a supported escape sequence
        while True:

            as_is = scn.scan(one_or_more_not_this_or_that)
            bs = scn.skip(a_backslash)
            if bs:
                what_kind = scn.scan_required(valid_backslash_ting)

            if not any((as_is, bs)):
                break

            if bs:
                if 'n' == what_kind:
                    typ = 'newline_escape_sequence'
                elif 't' == what_kind:
                    typ = 'tab_escape_sequence'
                else:
                    assert '"' == what_kind
                    typ = 'double_quote_escape_sequence'
            else:
                typ = None

            yield 'unencoded_string_content', (as_is or '')
            yield 'any_escape_sequence', typ

        # Either you're at the end of the line or the end of the d.quote

        if scn.empty:
            yield ('end_of_surface_line',)
            return

        scn.skip_required(double_quote)
        yield ('end_of_double_quoted_string',)

    from text_lib.magnetics.string_scanner_via_string import \
        pattern_via_description_and_regex_string as o

    one_or_more_not_this_or_that = o(
        'one or more not double quote or backslash', r'[^"\\]+')

    a_backslash = o('a backslash', r'\\')

    valid_backslash_ting = o("'t' or 'n' or '\"'", '[tn"]')

    double_quote = o("double quote", '"')

    return parse_rest_of_double_quoted_string_so_far


# ==

class _NoClobberDict(dict):  # #[#508.5] custom strict data structure

    def __setitem__(self, k, v):
        assert k not in self
        return super().__setitem__(k, v)


class _Stop(RuntimeError):
    pass


def xx(msg=None):
    raise RuntimeError(''.join(('cover me', *((': ', msg) if msg else ()))))

# #born
