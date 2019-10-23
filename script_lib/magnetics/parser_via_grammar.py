"""
.#born to help us universalize non-click CLI..

This was early-abstracted from a rough sketch of an attempt at adding
options to cheap_arg_parse..
"""

"""
Implemenentation notes:


# understanding "symbols" vs "sub-expressions"

"Symbols" are the things users define. "Sub-expressions" are the things
parenthesis define. We *could* munge sub-expressions in to our symbol
table because from the perspective of the parse they should function
identically; however, for now we keep them separate :#here2 for two reasons:

For one, it's ugly to munge generated names into the same namespace as
user-defined symbol names. For two: whereas the scope of a symbol is the
whole grammar, the scope of a sub-expression (that is, who needs to know
about it) is limited only to the grammar node that immediately houses it.
"""


def parser_via_grammar_and_symbol_table(tokens, symbol_table):

    # do the following only once per (outermost) grammar/syntax
    tox = TokenScanner(tokens)

    # at the top node, exit criteria is this. (at non-top node, it's ')')
    def keep_going():
        return not tox.is_empty

    _digraph, _seq_grammar, _sub_exp_parsers = _parse_parse(tox, keep_going)
    _use_symbol_table = _THING_FROM_THING(symbol_table)

    _gnode = _GrammarNode(_digraph, _seq_grammar, _sub_exp_parsers)

    return _Parser(_use_symbol_table, _gnode)


def _recurse(tox):
    def keep_going():
        if ')' == tox.peek:
            tox.advance()
            return False
        return True
    _digraph, _seq_grammar, _sub_exp_parsers = _parse_parse(tox, keep_going)
    return _GrammarNode(_digraph, _seq_grammar, _sub_exp_parsers)


class _Parser:

    def __init__(self, symbol_collection, grammar_node):
        self._gnode = grammar_node
        self._symbols = symbol_collection

    def parse(self, token_scanner, listener, stop_ASAP=False):

        def symz(symbol_name):
            return do(symbol_name, None)
        do = self._symbols.retrieve_entity_as_storage_adapter_collection

        return _parse(token_scanner, stop_ASAP, self._gnode, symz, listener)


class _GrammarNode:

    def __init__(self, digraph, seq_grammar, sub_exps):
        self.digraph = digraph
        self.sequence_grammar = seq_grammar
        self.sub_expressions = sub_exps


def _parse(token_scanner, stop_ASAP, grammar, symbols, listener, is_sub=False):
    digraph = grammar.digraph
    sequence_grammar = grammar.sequence_grammar

    ast = [None for _ in range(0, len(sequence_grammar))]
    grammar_length = len(sequence_grammar)

    last_used_offset_in_grammar = -1  # BE CAREFUL
    did_plurals_at = []

    def offset_of_first_missing():
        for i in range(last_used_offset_in_grammar + 1, grammar_length):
            if sequence_grammar[i].is_required:  # #term
                return i

    def finish_AST():
        for i in did_plurals_at:
            ast[i] = tuple(ast[i])
        return tuple(ast)

    # same args in sub-eps
    sub_exps = grammar.sub_expressions

    # changes each iteration
    transitions = digraph[0]  # #transitions

    while not token_scanner.is_empty:

        # the essence of all (packrat?) parsing: first match wins

        if stop_ASAP and offset_of_first_missing() is None:
            return finish_AST()

        # step one: find the first match based on peeking

        two = _peek(token_scanner, transitions, sub_exps, symbols)

        if two is None:
            i = offset_of_first_missing()

            if i is None:  # if there's no missing required
                if stop_ASAP:
                    return finish_AST()
                if is_sub:  # unparseable extra becomes parent's responsibility
                    return finish_AST()

            return _when_transition_not_found(
                    listener, i, token_scanner, transitions)

        use_transition, node = two

        # step two: does the ONE matching symbol succeed in parsing?

        if use_transition.is_sub_expression_transition:
            decoded = _parse(token_scanner, stop_ASAP, node, symbols,
                             listener, is_sub=True)
            if decoded is None:
                return None
        else:
            wv = node.parse_as_subparser(token_scanner, listener)
            if wv is None:  # wv = wrapped value
                return  # (Case5442)
            decoded, = wv

        offset_in_grammar = use_transition.offset_in_grammar
        if sequence_grammar[offset_in_grammar].is_plural:
            if ast[offset_in_grammar] is None:  # (Case2626)
                ast[offset_in_grammar] = []
                did_plurals_at.append(offset_in_grammar)
            ast[offset_in_grammar].append(decoded)
        else:
            ast[offset_in_grammar] = decoded  # (Case2595)

        transitions = digraph[use_transition.move_to_offset]
        last_used_offset_in_grammar = offset_in_grammar

    # We have succeeded it getting the grammar to satisfy the input tokens,
    # but did the input tokens satisfy all of the grammar? We must check:

    i = offset_of_first_missing()
    if i is not None:
        return _when_missing_required(listener, i)

    return finish_AST()


def _peek(tox, transitions, sub_exps, symbols):

    for trans in transitions:
        # this may be more ornate than necessary just to be safe for now #here2
        if trans.is_sub_expression_transition:
            node = sub_exps[trans.sub_expression_identifier]  # noqa: E501
            _two = _peek(tox, node.digraph[0], node.sub_expressions, symbols)
            did_match = False if _two is None else True
        else:
            node = symbols(trans.symbol_name)
            did_match = node.match_by_peek_as_subparser(tox)

        if did_match:  # first match wins, like "packrat parser"
            return trans, node


def _parse_parse(tox, keep_going):
    # #[#008.2]-adjacent (state machine sort of)
    """Turn a grammar sequence into a state machine (graph).

    A grammar sequence is a list of pairs: each pair is an arity and a symbol.
    To build the state machine (FSA) we traverse each pair in order from
    beginning to end, while keeping track of a "range of participating states".
    (Imagine keeping a left pointer finger and a right pointer finger on an
    ever-growing list of the states you're adding to your graph.)

    👉 When you step on to a pair whose arity *does* include zero, add it
    to a list of nodes that can transition to the one you are adding.

    👉 Otherwise (and you step on to a pair whose arity does *not* include
    zero), this starts a new run of "maybes"..
    """

    states = []
    sequence_grammar = []
    sub_expressions = None

    def create_state(offset):
        assert(offset == len(states))
        states.append([])  # #transitions

    create_state(0)  # the start state is at offset zero
    left_boundary = 0

    while keep_going():
        excludes_zero, goes_to_infinity = __arities[tox.peek]  # ..
        tox.advance()

        tok = tox.shift()  # ..
        # if not tox.is_empty and 'as' == tox.peek ..

        """.#here1 is the key thing: this pair in concert with the
        "participating states" expresses a set of transitions to add to our
        graph.
        """

        future_new_state_offset = len(states)
        offset_in_grammar = len(sequence_grammar)

        if '(' == tok:
            _sub_expression_parser = _recurse(tox)
            if sub_expressions is None:
                sub_expressions = [None]  # for OCD, skip 0 as valid ID
            subexp_ID = len(sub_expressions)
            sub_expressions.append(_sub_expression_parser)
            term = _SubExpressionTerm()
            trans = _SubExpressionTransition()
            term.sub_expression_identifier = subexp_ID
            trans.sub_expression_identifier = subexp_ID
        else:
            term = _SymbolTerm()  # #term
            trans = _SymbolTransition()
            term.symbol_name = tok
            trans.symbol_name = tok

        term.is_required = excludes_zero
        term.is_plural = goes_to_infinity
        sequence_grammar.append(term)

        trans.offset_in_grammar = offset_in_grammar
        trans.move_to_offset = future_new_state_offset

        for offset in range(left_boundary, future_new_state_offset):
            _state_trasitions = states[offset]  # #transitions
            _state_trasitions.append(trans)

        # as soon as you encounter any pair whose arity does not include zero,
        # it closes off a run of "maybes". It is a spot you have to hit. It
        # now forms the new beginning of a new run of "participating" nodes.

        if excludes_zero:
            left_boundary = future_new_state_offset  # (Case2595)

        # add the new node for the state implied by this pair
        create_state(future_new_state_offset)

        # if a pair's arity is unbounded, express that it transitions to self
        if goes_to_infinity:
            _state_trasitions = states[future_new_state_offset]  # #transitions
            _state_trasitions.append(trans)  # (Case2626)

    return states, sequence_grammar, sub_expressions


__arities = {
        # excludes zero, goes to infinity
        'any': (False, False),  # (Case2617)
        'one': (True, False),  # (Case2595)
        'zero or one': (False, False),  # (Case2629)
        'one or more': (True, True),
        'zero or more': (False, True),
        }


def _THING_FROM_THING(symbol_table):
    from kiss_rdb.magnetics.via_collection import (
            CACHING_COLLECTION_VIA_COLLECTION,
            collection_via_DICTIONARY_OF_DEREFERENCERS)
    _inner_coll = collection_via_DICTIONARY_OF_DEREFERENCERS(symbol_table)
    return CACHING_COLLECTION_VIA_COLLECTION(_inner_coll)


# #[#510.2] blank slates (the four below)


class _SymbolTerm:
    pass


class _SubExpressionTerm:
    pass


class _SymbolTransition:
    is_sub_expression_transition = False


class _SubExpressionTransition:
    is_sub_expression_transition = True


class TokenScanner:  # #[#008.4] a scanner
    # NOTE this is now used experimentally also as a character scanner!

    def __init__(self, tokens):
        self._length = len(tokens)
        self.tokens = tokens
        self.pos = -1  # re value: BE CAREFUL! re name: be like ruby meh
        self.peek = None  # BE CAREFUL
        self.is_empty = False
        self.advance()

    def flush_the_rest(self):
        x = self.tokens[self.pos:]
        self.advance_to_position(self._length)
        return x

    def shift(self):
        x = self.peek
        self.advance()
        return x

    def advance(self):
        self.advance_to_position(self.pos + 1)

    def advance_to_position(self, pos):
        self.pos = pos
        if self.pos == self._length:
            self.is_empty = True
            del self._length
            del self.pos
            del self.peek
            return
        self.peek = self.tokens[self.pos]


# -- whiners

def _when_missing_required(listener, offset_in_grammar):
    def structer():
        return {'offset_in_grammar': offset_in_grammar}
    listener('error', 'structure', 'parse_error', 'missing_required', structer)


def _when_transition_not_found(listener, i, token_scanner, transitions):

    if i is None:
        # when no missing required, say it is unexpected (i.e extra) input
        # rather than splaying available transitions EXPERIMENTAL
        return _when_extra_input(listener, token_scanner)   # (Case2611)

    # (Case2598)
    return _when_unrecognized_input(listener, token_scanner, transitions)


def _when_extra_input(listener, token_scanner):
    def structer():
        raise Exception('cover me')  # [#676] cover me
    listener('error', 'structure', 'parse_error', 'extra_input', structer)


def _when_unrecognized_input(listener, token_scanner, transitions):
    def stcter():
        raise Exception('cover me')  # [#676] cover me
    listener('error', 'structure', 'parse_error', 'unrecognized_input', stcter)

# #born.
