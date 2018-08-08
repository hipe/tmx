"""
the query model:
  - (is EXPERIMENTAL with regards to ALL of these following provisions)
  - is divorced from any particular parser generator (so, must take no
    parser-generator-generated AST's as construction arguments).
  - yet still can reconstruct itself into a surface string losslessly (..)
  - is practical to be used as an end-of-the-line business object, e.g
    for real queries (but put workers in magnets. this is a cold model.)

the idea is that :[#707.G]:
  - the model we use in our business code can avoid the peculiaries and
    particularities of whatever class of grammars happens to be supported by
    whatever parser generator we happen to be using. so for example, in our
    business code we can work with plain old recursive (tree-like) lists
    rather than ultra deep, narrow left (or right) recursive trees. this
    allows us to use more familiar looping idioms in our business code.
  - more generally, the structure of this model is "logical" (meaning we
    structure it the way that makes sense to in our heads) rather than
    "practical" (meaning the way we have to structure things to get our
    grammars to work). as our grammar evolves, we may have to make structural
    changes to it; but the model here can remain unmoved (ideally).
  - the insulation we get from having (in effect) two models reduces future
    pain drastically if we ever (gulp) refactor to a new parser generator.
    there is a well-defined boundary around the far model: it can't "leech out"
    into our business code. rather, it must output AST's that use this
    agnostic model exclusively. (we call this the "adaptation" of the parser
    generator to our native model.) this "quarantining" of parsing can
    outright prevent our business code from getting rattled when there's
    changes in how we parse.
  - because the model we use in our business code is not dependent on the
    parsing facility, we can build queries from plain old code if needed
    rather than needing to parse strings to build queries. not only is
    this more idiomatic/intuitive, more performant, less movies parts under
    such cases, it also makes testing easier and makes making an API easier.
in summary, this separation between grammar and model is probably the most
valuable abstraction layer we can have in this sub-project.

why lossless?
  - for now it's because we're doing "soft syntax errors" in a second pass
    (like semantic validation stuff) because (in part) it can allow us to
    craft more helpful, appropriately contextualized error messages about
    constructs. but when errors do occur, we want to do the input trace
    thing. maybe a smell. (because for example the way we want to use this
    node for API stuff has no crossover with this concern.)
"""


from tag_lyfe import (
        pop_property,
        )


# == support (early because etc)

""".:#here3: :[#707.F]: "wordables" is an experimental local micro-API:

a "wordable" is a component-ish that:
  - exposes `to_string()` which produces a string that
  - can be joined with other such strings meaningfully with a space and
  - probably dosn't contain any such separator spaces itself

for example, the name "Ta Nahesi Coates" would constist of three wordable
objects. one object's `to_string()` method would produce "Ta"; another
object would produce "Nahesi", etc. (we would prefer that a wordable not
output a string like "Ta Nahesi" because we would prefer that the client
(not the wordable) chose the separator character.)

this micro-API is useful because it:
  - trivializes the implementation of `to_string` for macro-components (that
    is, components that consist of only other components).
"""


def to_string_using_wordables_(self):
    """
    (see #here3 the "wordables" API of which we are perhaps the sole client)
    here we don't use NULL_BYTE_ we use space because we can and it's prettier
    """

    return ' '.join(x.to_string() for x in self.wordables_())


def wordable_via_string_(s):
    class x:  # #class-as-namespace
        def to_string():
            return s
    return x


# == parenthesized group

class UnsanitizedParenthesizedGroup:

    def __init__(self, ul):
        self._ul = ul

    def sanitize(self, listener):
        lis = pop_property(self, '_ul').sanitize(listener)
        if lis is None:
            return
        return _ParenthesizedGroup(lis)


class _ParenthesizedGroup:

    def __init__(self, lis):
        self._list = lis

    def yes_no_match_via_tag_subtree(self, subtree):  # just simple passthru
        return self._list.yes_no_match_via_tag_subtree(subtree)

    to_string = to_string_using_wordables_

    def wordables_(self):  # for #here3
        yield _open_paren_as_wordable
        for w in self._list.wordables_():
            yield w
        yield _close_paren_as_wordable


_open_paren_as_wordable = wordable_via_string_('(')
_close_paren_as_wordable = wordable_via_string_(')')


# == AND lists and OR lists

class UnsanitizedList:
    """
    get a thing in something like the form:

        [ item 1 [ , {'and'|'or'}, item 2 [..]]]

    BUT REVERSED.

    your only responsibility is to make sure that every conjuctive word
    is the same word.
    """

    def __init__(self, unsani_tup):
        self._unsanitized_tuple = unsani_tup

    def sanitize(self, listener):

        _tup = pop_property(self, '_unsanitized_tuple')
        stack = list(reversed(_tup))

        def sanitized_node_via_stack_pop():
            _unsani_node = stack.pop()
            return _unsani_node.sanitize(listener)

        sani_node = sanitized_node_via_stack_pop()
        if sani_node is None:
            return

        elif 0 == len(stack):
            return sani_node  # CHANGE STRUCTURE (native ASTs: no 1-len lists)
        else:
            sani_nodes = [sani_node]
            current_and_or_or = stack.pop()  # assume
            while True:

                sani_node = sanitized_node_via_stack_pop()
                if sani_node is None:
                    return

                sani_nodes.append(sani_node)
                if 0 == len(stack):
                    break

                next_and_or_or = stack.pop()  # assume
                if current_and_or_or != next_and_or_or:

                    self._whine(listener, sani_nodes, next_and_or_or, current_and_or_or)  # noqa: E501

                    return

        return self._build_thing(tuple(sani_nodes), current_and_or_or)

    def _whine(self, listener, sani_nodes, next_and_or_or, current_and_or_or):

        def _():
            _1st = current_and_or_or
            _2nd = next_and_or_or
            _thing = self._build_thing(sani_nodes, _1st)
            good_head = _thing.to_string()
            yield f"can't change from {_1st!r} to {_2nd!r} at the same level (use parens)"  # noqa: E501
            yield f'{good_head} {_2nd}'
            bars = '-' * (len(good_head) + 1)
            yield f'{bars}^'

        listener('error', 'expression', 'parse_error', 'mixed_AND_and_OR', _)
        # the above constitutes an externally referenced coverpoint :[#708.3]

    def _build_thing(self, sani_nodes, current_and_or_or):

        _cls = _AND_list_or_OR_list_via_conjunction_string[current_and_or_or]
        return _cls(sani_nodes)


class _AND_or_OR_List:

    def __init__(self, nodes_tup):
        self.children = nodes_tup

    to_string = to_string_using_wordables_

    def wordables_(self):  # for #here3

        conj_wordable = _wordable_via_conjunction[self.conjunction]

        childs = iter(self.children)
        for w in next(childs).wordables_():
            yield w
        for child in childs:
            yield conj_wordable
            for w in child.wordables_():
                yield w


AND = 1
OR = 2


class AND_List(_AND_or_OR_List):

    def yes_no_match_via_tag_subtree(self, subtree):
        yes = True
        for child in self.children:
            _yes_ = child.yes_no_match_via_tag_subtree(subtree)
            if not _yes_:
                yes = False
                break
        return yes

    conjunction = AND


class OR_List(_AND_or_OR_List):

    def yes_no_match_via_tag_subtree(self, subtree):
        for child in self.children:
            yes = child.yes_no_match_via_tag_subtree(subtree)
            if yes:
                break
        return yes

    conjunction = OR


_wordable_via_conjunction = {
        AND: wordable_via_string_('and'),
        OR: wordable_via_string_('or'),
        }


_AND_list_or_OR_list_via_conjunction_string = {
        'and': AND_List,
        'or': OR_List,
        }


# == negation

class UnsanitizedNegation:

    def __init__(self, function):
        self._function = function

    def sanitize(self, listener):
        _unsani = pop_property(self, '_function')
        sani = _unsani.sanitize(listener)
        if sani is None:
            return
        return _Negation(sani)


class _Negation:

    def __init__(self, function):
        self._function = function

    def yes_no_match_via_tag_subtree(self, subtree):
        _yes = self._function.yes_no_match_via_tag_subtree(subtree)
        return not _yes

    to_string = to_string_using_wordables_

    def wordables_(self):  # for #here3
        yield _NOT_AS_WORDABLE
        for x in self._function.wordables_():
            yield x


_NOT_AS_WORDABLE = wordable_via_string_('not')


# == tag as name chain (unsanitized then sanitized)

"""the "name chain" model :#here5:

(EDIT reconcile this with the newer [#705] digraph of the latest model)

categories of surface representation for (what we call) "taggings" include:
    - a simple, one-component tagging like `#foo`. (a "shallow tag".)
    - the tagging that looks like a name-value pair: `#foo:bar`
    - and taggings of arbitrary, deeper depth `#foo:bar:baz`

queries for matching tags have as a subset of their surface phenomena
expressions that look identical to taggings. that is, `#foo:bar` is a query
that matches taggings of `#foo:bar` (sort of).

for now we'll describe our current (simplified) model for queries for
taggings in the context of the older (more complicated) model it replaces:

it got too complicated to keep track of all the different classes: we had
sanitized and unsanitized for both "deep selectors" and shallow, and of deep
selectors we had head and non-head components. our answer to this is the
"name chain model":

what we used to call "deep selectors" we just call "name chains" now, and
what we used to call a "shallow tag" is just the 1-length case of a name chain.

every name chain has the following conceptual structure:

    head_node [ non_head_node [ non_head_node [..]]]

whereby:
  - every "link" in the chain is a _node_. (the terms are _somewhat_
    interchangeable but we prefer "node" to emphasize the recursive aspect..)
  - implementation-wise, we're doing the recursive thing for reasons (whereby:)
  - every node either has a child or doesn't have a child.
  - every node is either a "head" node or a non-head node. (only for rendering)
  - (corollary): all chains have exactly one "tail node" (which might also be
    the head node). the "tail node"-ness of a node is exactly one-to-one with
    whether or not the node has a child; that is, these are two features of
    the same category of node.
"""


class UnsanitizedDeepSelectorComponent:
    """(built only to be consumed by the next class)"""

    def __init__(self, unsanitized_component_stem):
        self.unsanitized_component_stem = unsanitized_component_stem


class UnsanitizedShallowOrDeepTag:

    def __init__(self, unsanitized_tag_stem):
        self.unsanitized_tag_stem = unsanitized_tag_stem

    def become_deep__(self, tup):

        def to_pieces():
            yield self._release_head_name()
            for x in tup:
                yield x.unsanitized_component_stem

        return _UnsanitizedNameChain(tuple(to_pieces()))

    def sanitize(self, listener):  # i.e, stay shallow

        _s = self._release_head_name()
        _unc = _UnsanitizedNameChain((_s,))
        return _unc.sanitize(listener)

    def _release_head_name(self):
        return pop_property(self, 'unsanitized_tag_stem')


"""
about validating tag names :#here4:

- the broad idea is that the grammar itself does a coarse-pass de-facto
  validation of tag names (because the grammar describes a pattern for tag
  names, to the extent that it does)
- then in a second, fine-grained pass we can do a more detailed validation.
  (this is [#707.C] not yet fully implemented because we haven't decided
  what the exact spec should be and we don't really care yet.)
- but curve-ball: there are pieces that "seem like" the "value" part of a
  name-value pair. for example, we want to allow such an construction:
      #author:"Ta Nehisi Coates"
  but we don't want to allow spaces for elements that "feel like" tags:
      #"Ta Nahesi Coates"
  so not this either:
      #author:"Ta Nahesi Coates":awesome

so we want to validate as a tag name all those pieces of the name chain
that are not to be considered a possible "value piece". let's consider
where the "value piece" falls based on how many pieces total there are:

    1 piece:          tag_stem
    2 pieces:         tag_stem value_piece
    3 pieces:         tag_stem tag_stem value_piece
    4 pieces, etc:    tag_stem tag_stem tag_stem value_piece

- so note the first piece is always treated as a tag name and never a value
  piece, but otherwise the last piece is always treated as a value piece.
- [#707.E] tracks do not want the usual restrictions
  on tag names.
"""


class _UnsanitizedNameChain:

    def __init__(self, pcs):
        self._unsanitized_pieces = pcs

    def sanitize(self, listener):

        unsanitized_pieces = pop_property(self, '_unsanitized_pieces')
        length = len(unsanitized_pieces)

        # validate as a tag name those components from offset 0 to offset
        # length - 2 (or as appropriate). exactly #here4

        if 1 < length:
            # treat tail as a value-esque IFF 2 or or more components
            use_length = length - 1
        else:
            use_length = 1

        for i in range(0, use_length):
            if not _validate_tag_stem_name(listener, unsanitized_pieces[i]):
                return

        sanitized_pieces = unsanitized_pieces
        del(unsanitized_pieces)

        # now, build the chain from the inside out #here5

        current_node = None
        if 1 < length:
            for i in reversed(range(1, length)):
                current_node = _TagNameChainNonHeadNode(
                        sanitized_pieces[i], current_node)

        return _TagNameChainHeadNode(sanitized_pieces[0], current_node)


class _NameChainNode:

    def __init__(self, name_stem, child=None):
        if child is None:
            self._has_child = False
        else:
            self._child = child
            self._has_child = True
        self._stem = name_stem
        self._init_dig_recursive()

    def yes_no_match_via_tag_subtree(self, subtree):  # ##here2
        return in_subtree_match_any_one_(subtree, self._simple_match)

    def _simple_match(self, tagging):
        _inner_tagging = self.dig_recursive_(tagging.root_node)
        return _inner_tagging is not None

    def _init_dig_recursive(self):

        name_stem = self._stem

        def name_matches(tagging_node):
            return name_stem == tagging_node.tag_stem

        if self._has_child:
            child = self._child

            def f(tagging_node):
                if not tagging_node.is_deep:
                    # #coverpoint1.16.2 deeper query won't match shallower tag
                    return
                if name_matches(tagging_node):
                    return child.dig_recursive_(tagging_node.child)
        else:
            def f(tagging_node):
                if name_matches(tagging_node):
                    if tagging_node.is_deep:
                        # #coverpoint1.16.3: deeper tag matches shallower query
                        return tagging_node
                    else:
                        return tagging_node
        self.dig_recursive_ = f

    def wordables_(self):  # for #here3
        yield self

    def to_string(self):  # BUILDS STRING ANEW AT EACH CALL.
        return ''.join(self._piece_strings())

    def _piece_strings(self):
        yield self._glyph_thing
        yield self._stem
        if self._has_child:
            for s in self._child._piece_strings():
                yield s


class _TagNameChainHeadNode(_NameChainNode):

    _glyph_thing = '#'


class _TagNameChainNonHeadNode(_NameChainNode):

    _glyph_thing = ':'


# == the in suffix

class UnsanitizedInSuffix:

    def __init__(self, unsanitized):
        self._unsanitized = unsanitized

    def unsanitized_via_finish(self, unsanitized_tagging):
        _ = pop_property(self, '_unsanitized')
        return _UnsanitizedInSuffixedTagging(unsanitized_tagging, _)


class _UnsanitizedInSuffixedTagging:

    def __init__(self, ut, uisp):
        self._unsanitized_tagging = ut
        self._unsanitized_in_suffix_payload = uisp

    def sanitize(self, listener):
        # (note the asymmetry: we pass `tagging` twice)
        tagging = pop_property(self, '_unsanitized_tagging').sanitize(listener)
        if tagging is None:
            return
        isp = pop_property(self, '_unsanitized_in_suffix_payload').sanitize_plus(  # noqa: E501
                listener, tagging)
        if isp is None:
            return
        return _InSuffixedTagging(tagging, isp)


class _InSuffixedTagging:
    """this fellow holds that the (at writing) 3 known grammatical features

    of the category "in suffix" all have the same surface form at the head:

        <tagging> in <xx>
    """

    def __init__(self, tagging_query, in_suffix_payload):
        self.yes_no_match_via_tag_subtree = in_suffix_payload.yes_no_match_via_tag_subtree  # wow  # noqa: E501
        self._in_suffix_payload = in_suffix_payload
        self._tagging_query = tagging_query

    to_string = to_string_using_wordables_

    def wordables_(self):  # hook-in for [#707.F] wordables
        for w in self._tagging_query.wordables_():
            yield w
        yield _in_wordable
        for w in self._in_suffix_payload.wordables_():
            yield w


_in_wordable = wordable_via_string_('in')


# == suffixed modifier: with or without value

class UnsanitizedWithOrWithoutFirstStep:

    def __init__(self, yes):
        self._yes = yes

    def unsanitized_via_finish(self, x):
        return _UnsanitizedWithOrWithoutValue(x, pop_property(self, '_yes'))


class _UnsanitizedWithOrWithoutValue:

    def __init__(self, child, yes):
        self._child = child
        self._yes = yes

    def sanitize(self, listener):
        x = pop_property(self, '_child').sanitize(listener)
        if x is None:
            return
        return (_WithValue if self._yes else _WithoutValue)(x)


class _WithOrWithoutValue:

    def __init__(self, child):
        my_test = self.__class__._my_test

        def f(tagging):
            found = child.dig_recursive_(tagging.root_node)
            if found is not None:
                return my_test(found)

        self._this_test = f
        self._child = child

    def yes_no_match_via_tag_subtree(self, subtree):  # ##here2
        return in_subtree_match_any_one_(subtree, self._this_test)

    to_string = to_string_using_wordables_

    def wordables_(self):  # for #here3
        for w in self._child.wordables_():
            yield w
        yield self._keyword_wordable
        yield _value_as_wordable


class _WithValue(_WithOrWithoutValue):

    def _my_test(tagging_node):
        return tagging_node.is_deep

    _keyword_wordable = wordable_via_string_('with')


class _WithoutValue(_WithOrWithoutValue):

    def _my_test(tagging_node):
        return not tagging_node.is_deep

    _keyword_wordable = wordable_via_string_('without')


_value_as_wordable = wordable_via_string_('value')


# == support

def in_subtree_match_any_one_(subtree, yes_no_via_tag):
    yes = False
    for tag in subtree:  # ..
        if yes_no_via_tag(tag):
            yes = True
            break
    return yes


def _validate_tag_stem_name(listener, s):  # #track [#707.C] when we formalize
    return True


# #history-A.1: deep vs shallow distinction out. simplified name-chain model in
# #born.
