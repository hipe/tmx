"""
:[#707.G]: parser-generator isolation:

this module (file) intends to be the only code that touches or has to
realy know about the specifics of the parser generator (in the scope of
this one grammar - there can be other such modules for other grammars).

also, see #here2 which explains how we isolate w/ re: to AST.
"""

from modality_agnostic import lazy


def RUMSKALLA(serr, query_s):

    def my_pprint(x):
        from pprint import pprint
        pprint(x, stream=serr, width=20, indent=4)

    itr = MAKE_CRAZY_ITERATOR_THING(query_s)
    print('the model:')
    my_pprint(next(itr))

    print('the unsani:')
    unsani = next(itr)

    from script_lib.magnetics.error_monitor_via_stderr import func
    monitor = func(serr)

    wat = unsani.sanitize(monitor.listener)

    print('the sani:')
    my_pprint(wat)

    return monitor.exitstatus


def MAKE_CRAZY_ITERATOR_THING(query_s):
    """the obviously huge disadvantage here is hardcoded offsets (in effect).

    the advantage is progressive output, good for debugging
    """

    model = query_model_via_big_string(query_s)
    yield model

    _walker = _memoized_walker()
    unsani = _walker.walk(model)
    yield unsani


def EXPERIMENTAL_NEW_WAY(tokens, listener):
    """ 33 months later we think we can do better than tatsu

    for our use case anyway. #history-B.4
    """

    sx = _recursive_sexp_via(tokens, listener)
    if sx is None:
        return
    from tag_lyfe.the_query_model import simplified_matcher_via_sexp_ as func
    return func(sx)


def _recursive_sexp_via(tokens, listener):

    def can_stop_here(f):  # #decorator
        f.can_stop_here = True
        return f

    # == States #[#008.2]

    def from_beginning():
        yield if_tag, parse_first_tag_at_bottom
        yield if_open_paren, handle_open_paren_like_a_big_baller_from_bottom

    def from_after_open_paren():
        yield if_tag, parse_first_tag_not_at_bottom
        yield if_open_paren, handle_open_paren_like_a_big_baller_from_not_botto

    @can_stop_here
    def from_after_first_matcher_at_bottom():
        yield if_AND_or_OR, convert_to_compound_and_move_to_after_conj_at_botto

    def from_after_first_matcher_not_at_bottom():
        yield if_AND_or_OR, convert_to_compound_and_move_to_after_conj_not_at_b
        yield if_close_paren, handle_close_paren_like_a_big_baller

    def from_after_conjuncter_at_bottom():
        yield if_tag, parse_additional_tag_and_move_to_after_addit_match_at_bot
        yield if_open_paren, handle_open_paren_like_a_big_baller_from_bottom

    def from_after_conjuncter_not_at_bottom():
        yield if_tag, parse_additional_tag_and_move_to_after_addit_match_not_at
        yield if_open_paren, handle_open_paren_like_a_big_baller_from_not_botto

    @can_stop_here
    def from_after_additional_matcher_at_bottom():
        yield if_appropriate_conjuncter, lambda: move(from_after_conjuncter_at_bottom)  # noqa: E501

    def from_after_additional_matcher_not_at_bottom():
        yield if_appropriate_conjuncter, lambda: move(from_after_conjuncter_not_at_bottom)  # noqa: E501
        yield if_close_paren, handle_close_paren_like_a_big_baller

    # == Actions

    def parse_first_tag_at_bottom():
        parse_tag_and_add_to_frame()
        move(from_after_first_matcher_at_bottom)

    def parse_first_tag_not_at_bottom():
        parse_tag_and_add_to_frame()
        move(from_after_first_matcher_not_at_bottom)

    def convert_to_compound_and_move_to_after_conj_at_botto():
        convert_to_compound()
        move(from_after_conjuncter_at_bottom)

    def convert_to_compound_and_move_to_after_conj_not_at_b():
        convert_to_compound()
        move(from_after_conjuncter_not_at_bottom)

    def convert_to_compound():
        frame = compound_matcher_stack[-1]
        matcher, = frame
        frame[0] = token  # 'and' or 'or'
        frame.append(matcher)

    def parse_additional_tag_and_move_to_after_addit_match_at_bot():
        parse_tag_and_add_to_frame()
        move(from_after_additional_matcher_at_bottom)

    def parse_additional_tag_and_move_to_after_addit_match_not_at():
        parse_tag_and_add_to_frame()
        move(from_after_additional_matcher_not_at_bottom)

    def handle_open_paren_like_a_big_baller_from_bottom():
        compound_matcher_stack.append([])
        move(from_after_additional_matcher_at_bottom)  # #here3
        state_function_stack.append(from_after_open_paren)

    def handle_open_paren_like_a_big_baller_from_not_botto():
        compound_matcher_stack.append([])
        move(from_after_additional_matcher_not_at_bottom)  # #here3
        state_function_stack.append(from_after_open_paren)

    def handle_close_paren_like_a_big_baller():
        finished = finish(compound_matcher_stack.pop())
        compound_matcher_stack[-1].append(finished)
        state_function_stack.pop()
        # (now we are in the correct state because of #here3)

    # -- action support

    def finish(compound_matcher_mutable_frame):
        # Reduce-away the complexity now of paren'd groups w/ only 1 element
        if 1 == len(compound_matcher_mutable_frame):
            sx, = compound_matcher_mutable_frame
            return sx
        return tuple(compound_matcher_mutable_frame)

    def parse_tag_and_add_to_frame():
        check_tag(token)
        compound_matcher_stack[-1].append(('simple_tag', token))

    def move(func):
        state_function_stack[-1] = func

    # == Conditions

    def if_tag():
        return '#' == token[0]

    def if_AND_or_OR():
        return 'and' == token or 'or' == token

    def if_appropriate_conjuncter():
        return compound_matcher_stack[-1][0] == token

    def if_open_paren():
        return '(' == token

    def if_close_paren():
        return ')' == token

    # ==

    def find_action():
        for condition, action in state_func()():
            yn = condition()
            if yn:
                return action

    def state_func():
        return state_function_stack[-1]

    def cstacker():
        line = ' '.join(seen_tokens)  # NOTE not seen idk why
        return ({'line': line, 'position': len(line)},)

    check_tag, stop = _build_simplified_tag_parser_and_stop(cstacker, listener)

    compound_matcher_stack = [[]]
    state_function_stack = [from_beginning]
    seen_tokens = []

    try:
        for token in tokens:
            seen_tokens.append(token)
            action = find_action()
            if action is None:
                _whine_about_no_transition(listener, seen_tokens, state_func())
                return
            action()
    except stop:
        return

    if 1 < len(compound_matcher_stack):
        _whine_about_unclosed_parens(listener, seen_tokens)
        return

    if not hasattr(state_func(), 'can_stop_here'):
        _whine_about_cant_stop_here(listener, seen_tokens, state_func())
        return

    root_frame, = compound_matcher_stack
    return finish(root_frame)


@lazy
def _memoized_walker():
    """isolate parser-generator specifics w/ re: to AST :#here2:

    so:

    - ideally this scope will be the only place where we "wire up" all this
      parser-generator-specific stuff (including grammar) with our native,
      insulated AST model (see)

    - for now we enclose this whole doo-hah in this function call to
      load its dependency modules late for [#010.6] regression-friendliness and
      maybe efficiency for some cases. (no)
    """

    import tag_lyfe.the_query_model as native_models
    from tatsu.walkers import NodeWalker

    class MyWalker(NodeWalker):

        def walk_object(self, node):  # #open #[#709.B] temporary for dev
            _msg = f'write me: walker for: {type(node)}'
            raise Exception(_msg)
            print(_msg)
            return node

        def walk__top_thing(self, node):
            return self._unsanitized_list(node)

        def walk__parenthesized_group(self, node):
            _unsani_list = self._unsanitized_list(node)
            return native_models.UnsanitizedParenthesizedGroup(_unsani_list)

        def _unsanitized_list(self, node):
            # the buck (array) starts at #here1
            child_EEK_stack = self.walk(node.item_or_list_as_local_top)
            child_EEK_stack.reverse()
            return native_models.UnsanitizedList(tuple(child_EEK_stack))

        def walk__conjuncted(self, node):
            a_o_o = node.and_or_or
            child_EEK_stack = self.walk(node.item_or_list)
            child_EEK_stack.append(a_o_o)
            return child_EEK_stack

        def walk__item_or_list(self, node):
            return self._same_buckstop(node)

        def walk__negated_function(self, node):
            _ohai = self.walk(node.negatable)
            return native_models.UnsanitizedNegation(_ohai)

        def walk__tagging_matcher(self, node):
            tp = self.walk(node.tagging_path)
            mf = node.modifying_suffix
            if mf is None:
                return tp
            else:
                mf = self.walk(mf[1])
                return mf.unsanitized_via_finish(tp)

        def walk__tagging_path(self, node):
            ut = self.walk(node.surface_tag)  # unsanitized tag
            ds = node.deep_selector
            if ds is None:
                return ut
            else:
                EEK_stack = self.walk(ds)
                EEK_stack.reverse()
                return ut.become_deep__(tuple(EEK_stack))

        def walk__deep_selector(self, node):
            return self._same_buckstop(node)

        def walk__deep_selector_component(self, node):
            return native_models.UnsanitizedDeepSelectorComponent(
                    node.deep_selector_rough_stem)

        def walk__surface_tag(self, node):
            return native_models.UnsanitizedShallowOrDeepTag(node.tag_stem)

        def walk__in_suffix(self, node):
            _unsani_in_suffix_payload = self.walk(node.in_suffix_payload)
            return native_models.UnsanitizedInSuffix(_unsani_in_suffix_payload)

        # -- begin would-be plugins

        def walk__list_of_values_for_in_suffix(self, node):
            from tag_lyfe.the_query_model_plugins import in_list_of_values as o
            x_a = self._SIMPLE_buckstop(node.values_for_in_suffix)
            x_a.reverse()
            return o.UnsanitizedInValuesFunction(tuple(x_a))

        def walk__numeric_range(self, node):
            from tag_lyfe.the_query_model_plugins import in_numeric_range as o
            begin_AST = self.walk(node.begin_number)
            end_AST = self.walk(node.end_number)
            return o.UnsanitizedInRange(begin_AST, end_AST)

        def walk__easy_number(self, node):
            use_string = node.integer_part
            float_strings = node.float_part
            if float_strings is None:
                use_number = int(use_string)
            else:
                decimal, digits, _ignore = float_strings  # (Case7050)
                use_string = f'{ use_string }{ decimal }{ digits }'
                use_number = float(use_string)
            from tag_lyfe.the_query_model_plugins import in_numeric_range as o
            return o.EasyNumber(use_number, use_string)

        def walk__hacky_regex_friendo(self, node):
            from tag_lyfe.the_query_model_plugins import in_regex as o
            return o.UnsanitizedInRegex(node.hacky_regex_payload)

        # -- end would-be plugins

        def walk__with_or_without_value(self, node):
            _yes = true_false_via_with_or_without[node.with_or_without]
            return native_models.UnsanitizedWithOrWithoutFirstStep(_yes)

        def _same_buckstop(self, node):
            return self._reversed_list_from_common_right_recursion(
                    node, self.walk, self.walk)

        def _SIMPLE_buckstop(self, node):
            return self._reversed_list_from_common_right_recursion(
                    node, lambda x: x, self._SIMPLE_buckstop)

        def _reversed_list_from_common_right_recursion(
                self, node, walk_left, walk_right):

            left = node.left
            right = node.right
            left_native_AST = walk_left(left)
            if right is None:
                return [left_native_AST]  # the buck starts :#here1
            else:
                mutable_reversed_list = walk_right(right)
                mutable_reversed_list.append(left_native_AST)
                return mutable_reversed_list

    true_false_via_with_or_without = {
            'with': True,
            'without': False,
            }

    return MyWalker()


def query_model_via_big_string(big_string):

    parser = query_parser()

    return parser.parse(
            text=big_string,
            whitespace='')  # see [#707.H] how we do our own whitespace


@lazy
def query_parser():
    from .tagging_subtree_via_string import grammar_path_ as func
    _grammar_path = func('the-query-grammar.ebnf')

    with open(_grammar_path) as fh:
        ebnf_grammar_big_string = fh.read()

    import tatsu
    return tatsu.compile(
            ebnf_grammar_big_string,
            asmodel=True)


# ==

def _build_simplified_tag_parser_and_stop(cstacker, listener):
    # EXPERIMENTAL does check only for now

    def parse_tag(token):
        try:
            return main(token)
        except stop:
            pass

    def main(token):
        scn = build_string_scanner(token)
        scn.skip_required(leading_octothorpe)
        scn.skip_required(tag_body)
        scn.skip_required(the_end)

    from text_lib.magnetics.string_scanner_via_string import \
        build_throwing_string_scanner_and_friends as func
    o, build_string_scanner, stop = func(listener, cstacker)

    leading_octothorpe = o("'#'", '#')
    tag_body = o('tag body ([-a-z]..)', '[a-z]+(?:-[a-z]+)*')
    the_end = o('end of tag', r'\Z')

    return parse_tag, stop


# == Whiners

def _whine_about_no_transition(listener, seen_tokens, state_func):

    def lines():
        from_where = state_func.__name__.replace('_', ' ')
        reason = f"Can't parse token {seen_tokens[-1]!r} {from_where}."
        for line in _lines_for_reason_and_expecting(reason, state_func):
            yield line

        if 1 == len(seen_tokens):
            return

        for line in _ASCII_art_via_seen_tokens_about_token(seen_tokens):
            yield line

    seen_tokens = tuple(seen_tokens)  # localize it, don't trust the state
    listener('error', 'expression', 'parse_error', lines)


def _whine_about_cant_stop_here(listener, seen_tokens, state_func):
    def lines():
        word_stack = list(reversed(state_func.__name__.split('_')))
        if 'from' == word_stack[-1]:
            word_stack.pop()
        if 'after' != word_stack[-1]:  # (really, we want "preposition?")
            word_stack.append('at')
        words = list(reversed(word_stack))
        if 'bottom' == words[-1]:
            words.extend(('of', 'stack'))

        at_where = ' '.join(words)
        reason = f"Unexpected end of query {at_where}."  # sometimes awkward
        for line in _lines_for_reason_and_expecting(reason, state_func):
            yield line

        for line in _ASCII_art_via_seen_tokens_after_tokens(seen_tokens):
            yield line

    seen_tokens = tuple(seen_tokens)  # localize it, don't trust the state
    listener('error', 'expression', 'parse_error', lines)


def _whine_about_unclosed_parens(listener, seen_tokens):
    def lines():
        yield 'Query ended with unclosed parenthesis:'
        for line in _ASCII_art_via_seen_tokens_after_tokens(seen_tokens):
            yield line
    listener('error', 'expression', 'parse_error', lines)


# == Whiner Support

def _lines_for_reason_and_expecting(reason, state_func):

    or_list = ' or '.join(_formal_names_via_state_function(state_func))  # ..
    expecting_what = f"Expecting {or_list}."

    if 10 < len(or_list):  # heuristic
        yield reason
        yield expecting_what
        return
    yield ' '.join((reason, expecting_what))


def _ASCII_art_via_seen_tokens_about_token(seen_tokens):
    margin = _ASCII_margin
    head = ' '.join(seen_tokens[:-1])
    yield ''.join((margin, head, ' ', seen_tokens[-1]))
    yield ''.join((margin, ('-' * (len(head) + 1)), '^'))


def _ASCII_art_via_seen_tokens_after_tokens(seen_tokens):
    margin = _ASCII_margin
    all_dem = ' '.join(seen_tokens)
    yield ''.join((margin, all_dem))
    yield ''.join((margin, ('-' * len(all_dem)), '^'))


_ASCII_margin = '    '


def _formal_names_via_state_function(state_func):
    import re
    for (cond, _act) in state_func():
        tail = re.match('if_(.+)', cond.__name__)[1]
        yield tail.replace('_', ' ')

# #history-B.4 spike simplified replacement for vendor
# #born.
