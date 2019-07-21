"""
.#born to help us universalize non-click CLI..

This was early-abstracted from a rough sketch of an attempt at adding
options to CHEAP_ARG_PARSE..
"""


class parser_via_grammar_and_symbol_table:

    def __init__(self, tokens, symbol_table):
        self._digraph, self._sequence_grammar = _build_digraph(tokens)
        _inner_coll = collection_via_THIS_ONE_THING(symbol_table)
        self._symbols = caching_collection_via_collection(_inner_coll)

    def parse(self, token_scanner, listener):
        def symbol_via(symbol_name):
            return _(symbol_name, None)  # ..
        _ = self._symbols.retrieve_entity_as_storage_adapter_collection
        return _parse(token_scanner, self._digraph, symbol_via,
                      self._sequence_grammar, listener)


def _parse(token_scanner, digraph, symbol_table, sequence_grammar, listener):

    ast = [None for _ in range(0, len(sequence_grammar))]
    transitions = digraph[0]  # #transitions

    last_used_offset_in_grammar = -1  # BE CAREFUL
    did_plurals_at = []

    while not token_scanner.is_empty:
        # the essence of all (packrat?) parsing: first match wins
        found_first_match = False
        for transition in transitions:
            # #transition:
            symbol_name, offset_in_grammar, move_to_offset = transition
            SOMETHING = symbol_table(symbol_name)
            found_first_match = SOMETHING.YES_I_AM_INTERESTED(token_scanner)
            if found_first_match:
                break
        if not found_first_match:
            return _when_transition_not_found(
                    listener, token_scanner, transitions)
        tup = SOMETHING.DO_THE_PARSE(token_scanner, listener)
        if tup is None:
            xx()
        decoded, = tup

        _, is_plural, _ = sequence_grammar[offset_in_grammar]  # #term
        if is_plural:
            if ast[offset_in_grammar] is None:  # (Case2626)
                ast[offset_in_grammar] = []
                did_plurals_at.append(offset_in_grammar)
            ast[offset_in_grammar].append(decoded)
        else:
            ast[offset_in_grammar] = decoded  # (Case2595)

        transitions = digraph[move_to_offset]
        last_used_offset_in_grammar = offset_in_grammar

    # We have succeeded it getting the grammar to satisfy the input tokens,
    # but did the input tokens satisfy all of the grammar? We must check:

    for i in range(last_used_offset_in_grammar + 1, len(sequence_grammar)):
        is_required, is_plural, symbol_name = sequence_grammar[i]  # #term
        if is_required:
            return _when_missing_required(listener, symbol_name, symbol_table)

    for i in did_plurals_at:
        ast[i] = tuple(ast[i])

    return tuple(ast)


# == BEGIN move these to kiss_rdb.LEGACY_collection_lib

class caching_collection_via_collection:

    def __init__(self, impl):
        self._cache = {}
        self._impl = impl

    def retrieve_entity_as_storage_adapter_collection(self, key, listener):
        if key not in self._cache:
            x = self._impl.retrieve_entity_as_storage_adapter_collection(
                    key, listener)
            assert(x)  # cover this - probably you do NOT want to cache fails
            self._cache[key] = x
        return self._cache[key]


class collection_via_THIS_ONE_THING:

    def __init__(self, dct):
        self._special_dictionary = dct

    def retrieve_entity_as_storage_adapter_collection(self, key, listener):
        _dereference = self._special_dictionary[key]  # ..
        _x = _dereference()
        return _x

# == END


def _build_digraph(tokens):  # #[#008.2]-adjacent (state machine sort of)
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

    def create_state(offset):
        assert(offset == len(states))
        states.append([])  # #transitions

    create_state(0)  # the start state is at offset zero
    left_boundary = 0

    tox = _TokenScanner(tokens)
    while not tox.is_empty:

        arity = tox.shift()
        symbol_name = tox.shift()  # ..
        # if not tox.is_empty and 'as' == tox.peek ..

        if 'any' == arity:  # (Case2617)
            includes_zero = True
            goes_to_infinity = False
        elif 'one' == arity:  # (Case2595)
            includes_zero = False
            goes_to_infinity = False
        elif 'one or more' == arity:
            includes_zero = False
            goes_to_infinity = True
        else:
            xx()

        """.#here1 is the key thing: this pair in concert with the
        "participating states" expresses a set of transitions to add to our
        graph.
        """

        future_new_state_offset = len(states)
        offset_in_grammar = len(sequence_grammar)
        _term = (not includes_zero, goes_to_infinity, symbol_name)  # #term
        sequence_grammar.append(_term)

        transition = (  # #transition
                symbol_name,
                offset_in_grammar,
                future_new_state_offset)
        for offset in range(left_boundary, future_new_state_offset):
            _state_trasitions = states[offset]  # #transitions
            _state_trasitions.append(transition)

        # as soon as you encounter any pair whose arity does not include zero,
        # it closes off a run of "maybes". It is a spot you have to hit. It
        # now forms the new beginning of a new run of "participating" nodes.

        if not includes_zero:
            left_boundary = future_new_state_offset  # (Case2595)

        # add the new node for the state implied by this pair
        create_state(future_new_state_offset)

        # if a pair's arity is unbounded, express that it transitions to self
        if goes_to_infinity:
            _state_trasitions = states[future_new_state_offset]  # #transitions
            _state_trasitions.append(transition)  # (Case2626)

    return states, sequence_grammar


class _TokenScanner:  # #testpoint  # [#008.4] a scanner

    def __init__(self, tokens):
        self._length = len(tokens)
        self._tokens = tokens
        self._pos = -1  # BE CAREFUL
        self.peek = None  # BE CAREFUL
        self.is_empty = False
        self.advance()

    def shift(self):
        x = self.peek
        self.advance()
        return x

    def advance(self):
        self._pos += 1
        if self._pos == self._length:
            self.is_empty = True
            del self._length
            del self._tokens
            del self._pos
            del self.peek
            return
        self.peek = self._tokens[self._pos]


# -- whiners

def _when_missing_required(listener, symbol_name, symbol_table):
    def structer():
        SOMETHING = symbol_table(symbol_name)
        xx()
        return SOMETHING  # no
    listener('error', 'structure', 'parse_error', 'missing_required', structer)


def _when_transition_not_found(listener, token_scanner, transitions):

    if len(transitions):  # (Case2611)
        return _when_unrecognized_input(listener, token_scanner, transitions)
    else:
        return _when_extra_input(listener, token_scanner)  # (Case2611)


def _when_extra_input(listener, token_scanner):
    def structer():
        xx()
    listener('error', 'structure', 'parse_error', 'extra_input', structer)


def _when_unrecognized_input(listener, token_scanner, transitions):
    def stcter():
        xx()
    listener('error', 'structure', 'parse_error', 'unrecognized_input', stcter)


def xx():  # #todo
    raise Exception('write me')

# #born.
