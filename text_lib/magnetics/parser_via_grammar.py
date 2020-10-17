"""
.#born to help us universalize non-click CLI..

This was early-abstracted from a rough sketch of an attempt at adding
options to cheap_arg_parse..

.#history-A.1 gets a new parser with a similar "philosophy" but an all new,
ground-up, blind rewrite. One day unify.
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
    tox = _scanner_via_list(tokens)

    # at the top node, exit criteria is this. (at non-top node, it's ')')
    def keep_going():
        return tox.more

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
        do = self._symbols.retrieve_entity
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

    while token_scanner.more:

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

        tok = tox.next()  # ..
        # if not tox.empty and 'as' == tox.peek ..

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


def WIP_PARSER_BUILDER_VIA_DEFINITION(define_grammar):
    # this returns a "parser" that requires the client to know about our
    # internal parser workings (directives). It should probably not stay
    # exposed like this but for reasons, during development it is.

    return _BuildTopmostParserBuilder(define_grammar).execute()


class _BuildTopmostParserBuilder:

    def __init__(self, defintion):
        self._forward_reference_names = set()
        self._symbol_definitions = {}
        defintion(self)

    def define(self, symbol_name, parser):
        if symbol_name in self._symbol_definitions:
            raise _MyRuntimeError(f"already defined: '{symbol_name}'")
        self._symbol_definitions[symbol_name] = parser

    def sequence(self, *component_tuples):
        return _SequenceNonterminal(component_tuples, self)

    def alternation(self, *symbol_names):
        return _AlternationNonterminal(symbol_names, self)

    def regex(self, rxs):
        return _RegexTerminal(rxs)

    # ==

    def see_symbol_name(self, sym):
        self._forward_reference_names.add(sym)

    def execute(self):

        forward_refs = tuple(self._forward_reference_names)
        del self._forward_reference_names

        symbol_defs = self._symbol_definitions
        del self._symbol_definitions

        missing = tuple(k for k in forward_refs if k not in symbol_defs)
        if len(missing):
            raise _MyRuntimeError(f'define these: ({", ".join(missing)})')

        symbol_names = tuple(symbol_defs.keys())

        parser_builders = {}
        for k in symbol_names:
            parser_builders[k] = symbol_defs[k].build_parser_builder(parser_builders)  # noqa: E501

        topmost_symbol = symbol_names[0]

        def build_parser():
            return parser_builders[topmost_symbol](topmost_symbol)

        return build_parser


def _build_sequence_parser_builder(components, pbs):

    length = len(components)
    assert(length)

    full_range = range(0, length)

    offset_of_last_required = None
    for i in full_range:
        if components[i].must_match:
            offset_of_last_required = i

    has_required = offset_of_last_required is not None

    class SequenceParser:

        def __init__(self, name):
            self.symbol_name = name
            self._parsers = [None for _ in full_range]
            self._did_thing = [False for _ in full_range]
            self._ = [0, 0]
            self._find_next_end()
            self._AST = {}

        def parse_line(self, line):

            while True:
                direc = None
                for parser, comp, offset in self._current_swath:
                    direc = parser.parse_line(line)
                    if direc is not None:
                        break  # first match always wins for now (no lookahead)

                if direc is None:
                    return self._when_not_found()

                direc_name = direc[0]

                if 'done_but_rewind' == direc_name:
                    tup = self._when_child_done(direc[1], parser, comp, offset)
                    if 'stay' != tup[0]:
                        xx()
                    continue
                break

            if 'stop' == direc_name:
                return direc

            return self._when_found(direc, parser, comp, offset)

        def receive_EOF(self):  # EXPERIMENTAL very very rough right now
            if has_required:
                if offset_of_last_required < self._[0]:
                    xx()
                else:
                    pass
            else:
                xx()

            beg, end = self._
            swath_size = end - beg
            if 1 != swath_size:
                xx()
            pp = self._parsers[beg]

            if pp._do_recurse_EOF:

                AST_er = pp.receive_EOF()
                assert(AST_er)
                cc = components[i]

                direc = self._when_child_done(AST_er, pp, cc, beg)
                assert('stay' == direc[0])  # or wwhatever

            return self._release_AST_er()

        def _when_not_found(self):
            # If you didn't find a match for this token but you have passed
            # your last required component, then you can produce a complete
            # AST but you have to tell your parent to rewind one and try again

            def ok():
                return 'done_but_rewind', self._release_AST_er()  # #here1

            beg, end = self._
            if offset_of_last_required < beg:
                # The offset of the last required is before the swath
                return ok()

            if end <= offset_of_last_required:
                # The offset of the last required is after the swath
                return  # #here2

            # The offset of the last required is in the swath

            if 1 != (end - beg):
                # for starters, let's just focus on one component
                xx()

            assert(offset_of_last_required == beg)

            # The swath is pointing directly at the last required component.
            # It may be that the component is plural and we have met its
            # requirement already by immediatly previous token(s).
            # HOW WE TEST FOR THIS IS VERY BAD RIGHT NOW

            comp = components[beg]
            if not comp.do_keep:
                # we didn't do thing (todo, clarify this lol)
                if not self._did_thing[beg]:
                    return  # #here2 (covered)
                xx('cover me - what does it mean to have done the thing')

            k = comp.symbol_name
            if k not in self._AST:
                # The comp can match multiple (and is required) but no matches
                return  # #here2

            # The component can match multiple and has matched at least once
            if comp.has_custom_min_max:
                xx()  # more complicated, but not by much

            assert(len(self._AST[k]))
            return ok()  # whew!

        def _when_found(self, direc, parser, comp, offset):
            direc_name, direc_data = direc

            if 'done' == direc_name:
                return self._when_child_done(direc_data, parser, comp, offset)

            if 'stay' == direc_name:
                assert(direc_data is None)

                # now that this component is matching, you don't want to
                # include components to the left of us. inch forward if nec.
                self._[0] = offset
                return direc

            xx()

        def _when_child_done(self, AST_er, parser, comp, offset):

            # no matter what, don't send a parser more lines when it says done
            self._parsers[offset] = None

            if comp.do_keep:
                self._store_AST(AST_er(), comp)

            if comp.can_be_many:
                return self._when_plural_child_done(parser, comp, offset)
            else:
                return self._when_singular_child_done(parser, comp, offset)

        def _when_plural_child_done(self, parser, comp, offset):

            # when a plural parser reports 'done', we will have stored its
            # AST and released the parser, but we don't move the swath head
            # past this slot yet, so that future tokens (many) may match it.

            # however, because it matched, move (once) the swath head forward
            # to point at this slot. (no previous grammatical terms can match)

            # now that the slot is satisfied, if it was formerly constituting
            # the tail of the swath, move the swath forward when approriate.

            # we are asking to stay so we will likely use this:
            self._parsers[offset] = parser.cleared_parser()

            next_offset = offset + 1

            if not self._did_thing[offset]:
                self._did_thing[offset] = True
                self._[0] = offset

                # if the component was last in the swath
                if next_offset == self._[1]:
                    # if the component was last in the world
                    if length == next_offset:
                        # probably do nothing
                        # (plurals last in world are kinda tricky..)
                        pass
                    else:
                        # the component was last in the swath but not world,
                        # find new ending for the swath, now that it's satisf.
                        assert(comp.must_match)
                        self._find_next_end()
                else:
                    # the component was not last in the swath.
                    # nothing to advance.
                    pass

            return 'stay', None  # #here1

        def _when_singular_child_done(self, parser, comp, offset):

            next_offset = offset + 1

            # since component is done (and not plural) always move past it
            self._[0] = next_offset

            # if the component was the last in the swath
            if next_offset == self._[1]:

                # if the component was the last in the world
                if length == next_offset:
                    return 'done', self._release_AST_er()

                assert(comp.must_match)

                # the component was last in the swath but not last in
                # the world. there are more components after it
                self._find_next_end()

            return 'stay', None  # #here1

        def _store_AST(self, child_AST, comp):
            k = comp.symbol_name  # one day an 'as' option
            if comp.can_be_many:
                # set it as a list the first time, else append to it
                if k not in self._AST:
                    self._AST[k] = []
                self._AST[k].append(child_AST)
            else:
                assert(k not in self._AST)  # else an 'as' option
                self._AST[k] = child_AST

        def _release_AST_er(self):
            del self._

            def AST_er():
                x = self._AST
                del self._AST
                return x
            return AST_er

        def cleared_parser(self):
            return self.__class__(self.symbol_name)

        def phrase_for_expecting(self, symbol_name):
            return _PhraseViaPhrases(*self._phrases_for_expecting(symbol_name))

        def _phrases_for_expecting(self, symbol_name):
            def each_phrase():
                for parser, comp, _ in self._current_swath:
                    yield parser.phrase_for_expecting(comp.symbol_name)
            itr = iter(each_phrase())
            yield next(itr)
            or_p = _PhraseViaWords('or')
            for p in itr:
                yield or_p
                yield p

        @property
        def _current_swath(self):
            for i in range(* self._):
                yield self._parsers[i], components[i], i

        def _find_next_end(self):
            while True:
                old_begin, i = self._
                new_end = i + 1

                c = components[i]

                assert(self._parsers[i] is None)
                self._parsers[i] = pbs[c.symbol_name](c.symbol_name)

                self._[1] = new_end
                if length == new_end:
                    return

                if c.must_match:
                    break

        _do_recurse_EOF = True

    return SequenceParser


class _SequenceNonterminal:

    def __init__(self, component_tuples, g):
        def o(tup):
            c = _SequenceComponent(tup)
            g.see_symbol_name(c.symbol_name)
            return c
        self._components = tuple(o(tup) for tup in component_tuples)

    def build_parser_builder(self, pbs):
        return _build_sequence_parser_builder(self._components, pbs)


class _SequenceComponent:

    def __init__(self, tup):
        stack = list(reversed(tup))
        arity = stack.pop()

        self.has_custom_min_max = False
        if 'zero_or_one' == arity:
            can_be_zero = True
            can_be_many = False
        elif 'zero_or_more' == arity:
            can_be_zero = True
            can_be_many = True
        elif 'one' == arity:
            can_be_zero = False
            can_be_many = False
        elif 'one_or_more' == arity:
            can_be_zero = False
            can_be_many = True
        else:
            assert('between' == arity)
            assert(isinstance(min := stack.pop(), int))
            assert('and' == stack.pop())
            assert(isinstance(max := stack.pop(), int))
            assert(-1 < min)
            assert(-1 < max)
            assert(min < max)
            can_be_zero = 0 == min
            can_be_many = True
            self.has_custom_min_max = True
            self.min = min
            self.max = max

        symbol_name = stack.pop()

        self.do_keep = False
        if len(stack):
            token = stack.pop()
            # one day an 'as' feller
            assert('keep' == token)
            self.do_keep = True
            assert(not len(stack))

        self.must_match = not can_be_zero
        self.can_be_many = can_be_many
        self.symbol_name = symbol_name


__arities = {
        # excludes zero, goes to infinity
        'any': (False, False),  # (Case2617)
        'one': (True, False),  # (Case2595)
        'zero or one': (False, False),  # (Case2629)
        'one or more': (True, True),
        'zero or more': (False, True),
        }


def _build_alternation_parser_builder(symbol_names, parser_builders):

    class AlternationParser:

        def __init__(self, name):
            self.symbol_name = name
            self._is_collapsed = False

        def parse_line(self, line):
            # no lookahead, so we've got to resolve one immediately.
            # first one wins. if not found it's a failure

            if self._is_collapsed:
                direc = self._parser.parse_line(line)
                if direc is None:
                    # what to do when a long running fails. stop
                    return ('stop', None)
                found_sym = self._found_sym
            else:
                direc = None
                for found_sym in symbol_names:
                    parser = parser_builders[found_sym](found_sym)
                    direc = parser.parse_line(line)
                    if direc is not None:
                        break

                if direc is None:
                    return  # #here2

            # when a child reports done, we will report done,
            # and take me off the field coach.

            direc_name, direc_data = direc
            if 'done' == direc_name:
                def AST_er():
                    # a matchdata with no specific symbol name is useless
                    _child_AST = direc_data()
                    return (found_sym, _child_AST)
                return 'done', AST_er  # #here1

            # but if a child is long-running, we may have to change state to
            # remember this..

            if 'stay' == direc_name:
                if not self._is_collapsed:
                    self._is_collapsed = True
                    self._parser = parser
                    self._found_sym = found_sym
                return direc

            xx()

        def phrase_for_expecting(self, symbol_name):
            if self._is_collapsed:
                return self._parser.phrase_for_expecting(symbol_name)
            return _PhraseViaPhrases(*self._phrases_for_expecting(symbol_name))

        def _phrases_for_expecting(self, symbol_name):
            # we perhaps don't want symbol names in expressions. experimental
            yield _PhraseViaWords(
                    f"'{symbol_name}',", "which", "is", "one", "of", "(")
            itr = iter(each_phrase())
            yield next(itr)
            or_p = _PhraseViaWords('or')
            for p in itr:
                yield or_p
                yield p
            yield _PhraseViaWords(')')

        def cleared_parser(self):
            return self.__class__(self.symbol_name)

    def each_phrase():
        for symbol_name in symbol_names:
            parser = parser_builders[symbol_name](symbol_name)
            yield parser.phrase_for_expecting(symbol_name)

    return AlternationParser


class _AlternationNonterminal:

    def __init__(self, symbol_names, g):
        for s in symbol_names:
            g.see_symbol_name(s)
        self._forward_reference_names = symbol_names

    def build_parser_builder(self, pbs):
        return _build_alternation_parser_builder(
                self._forward_reference_names, pbs)


def _build_regex_parser(rx):

    class RegexParser:
        # stateless, no members

        def parse_line(self, line):
            md = rx.search(line)
            if md is None:
                return  # #here2

            def AST_er():
                return md
            return 'done', AST_er  # #here1

        def cleared_parser(self):
            return self

        def phrase_for_expecting(self, symbol_name):
            return _PhraseViaWords(f"'{symbol_name}'", f"(/{rx.pattern}/)")

        _do_recurse_EOF = False

    return RegexParser()


class _RegexTerminal:

    def __init__(self, rxs):
        self._rxs = rxs

    def build_parser_builder(self, _):
        import re
        parser = _build_regex_parser(re.compile(self._rxs))

        def build_parser(ignore_name):
            return parser
        return build_parser


def _THING_FROM_THING(symbol_table):
    return _caching_collection(_coll_via_deref_dict(symbol_table))


# == BEGIN [#873.16] other collection implementations
#    moved here #history-B.4

def _caching_collection(upstream_collection):
    def do_retrieve_entity(k, listener):
        if k not in cache:
            entity = upstream_collection.retrieve_entity(k, listener)
            if entity is None:
                raise RuntimeError('cover me - probably do NOT cache this')
                return
            cache[k] = entity
        return cache[k]
    cache = {}

    class coll:  # #class-as-namespace
        retrieve_entity = do_retrieve_entity
    return coll


def _coll_via_deref_dict(dct):
    def do_retrieve_entity(key, listener):
        return dct[key]()  # ..

    class coll:  # #class-as-namespace
        retrieve_entity = do_retrieve_entity
    return coll


# == END


# #[#510.2] blank slates (the four below)


class _SymbolTerm:
    pass


class _SubExpressionTerm:
    pass


class _SymbolTransition:
    is_sub_expression_transition = False


class _SubExpressionTransition:
    is_sub_expression_transition = True


def _scanner_via_list(tokens):
    from .scanner_via import scanner_via_list as func
    return func(tokens)


# -- whiners

def THESE_LINES(line, lineno, p):

    phrase = p.phrase_for_expecting(p.symbol_name)

    def lines():
        for s in lines_via_words(words(), 60):
            yield s
        yield line

    def words():
        for w in phrase.to_words():
            yield w
        yield 'at'
        yield 'line'
        yield f"{lineno}:"

    return lines()


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


def _when_unrecognized_input(listener, tox, transitions):
    def stcter():
        # you can hit this if you leave an empty string as a placeholder
        # in your parameter description spot. [#676] cover me
        _ = ''
        if tox.pos:
            _ = f' (after {repr(tox.tokens[tox.pos - 1])})'
        return {'reason': f"don't know how to parse {repr(tox.peek)}{_}"}
    listener('error', 'structure', 'parse_error', 'unrecognized_input', stcter)


def lines_via_words(words, limit):

    class WordBuffer:
        def __init__(self):
            self._line_words = []
            self._char_count_minus_spaces = 0

        def add_word(self, w):
            self._line_words.append(w)
            self._char_count_minus_spaces += len(w)
            if limit <= self._char_count_minus_spaces:
                return self._flush()

        def close(self):
            if len(self._line_words):
                return self._flush()

        def _flush(self):
            self._char_count_minus_spaces = 0
            s = ' '.join(self._line_words)
            self._line_words.clear()
            return s

    buff = WordBuffer()
    for w in words:
        s = buff.add_word(w)
        if s is not None:
            yield s
    s = buff.close()
    if s is not None:
        yield s


class _PhraseViaPhrases:
    def __init__(self, *phrases):
        self._phrases = phrases

    def to_words(self):
        for p in self._phrases:
            for w in p.to_words():
                yield w


class _PhraseViaWords:
    def __init__(self, *words):
        self._words = words

    def to_words(self):
        return self._words


def xx():
    raise RuntimeError('do me')


class _MyRuntimeError(RuntimeError):
    pass

# #history-B.4
# #history-A.1
# #born.
