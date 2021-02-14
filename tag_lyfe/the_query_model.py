"""
the query model:
  - (is EXPERIMENTAL with regards to ALL of these following provisions)
  - is divorced from any particular parser generator (so, must take no
    parser-generator-generated AST's as construction arguments).
  - yet still can reconstruct itself into a surface string losslessly (..)
  - is practical to be used as an end-of-the-line business object, e.g
    for real queries (but put workers in magnets. this is a cold model.)

the idea is that :[#707.G]:
  - the model we use in our business code can avoid the peculiarities and
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


# ==

def simplified_matcher_via_sexp_(sx):
    # experimental new 33 month later thing

    typ = sx[0]
    if 'simple_tag' == typ:
        surface, = sx[1:]
        return _SimplifiedTag(surface)

    cx = tuple(_simplified_matcher_children_of_compound(sx))
    return _simplified_compound_matcher(typ, cx)


def _simplified_matcher_children_of_compound(sx):
    for i in range(1, len(sx)):
        yield simplified_matcher_via_sexp_(sx[i])  # recurse


# == support (early because etc)

def _to_string_using_words(self):  # #history-B.4 buries overlong explanation
    return ' '.join(self.to_words())


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

    to_string = _to_string_using_words

    def to_words(self):
        # (at #history-B.4, no longer does its own parenthesis)
        for w in self._list.to_words():
            yield w

    is_compound_matcher = True


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


def _simplified_compound_matcher(and_or_or, cx):
    if 'and' == and_or_or:
        return AND_List(cx)
    assert 'or' == and_or_or
    return OR_List(cx)


class _AND_or_OR_List:

    def __init__(self, nodes_tup):
        self.children = nodes_tup

    def to_ASCII_tree_lines(self):
        return _ASCII_tree_lines_via_branch_node(self)

    to_string = _to_string_using_words

    def to_words(self):
        itr = iter(self.children)
        for w in next(itr).to_words():
            yield w
        for child in itr:
            yield self._conjunction_as_string
            if child.is_compound_matcher:
                yield '('
            for w in child.to_words():
                yield w
            if child.is_compound_matcher:
                yield ')'

    is_compound_matcher, is_leaf_matcher = True, False


def _AND_together_somehow(left, right):
    # Assume left is *not* an AND_List
    # Axiom: AND-ing together any matcher and an AND-list is the same as
    # prepending the matcher to the AND-list

    if right.is_compound_matcher and 'and' == right._conjunction_as_string:
        return right.__class__((left, *right.children))

    return AND_List((left, right))


class AND_List(_AND_or_OR_List):

    def AND_matcher(self, m):
        m.is_compound_matcher  # [#022]-like

        # Axiom: any AND-list can be AND'ed to by appending the matcher
        return self.__class__((*self.children, m))

    def yes_no_match_via_tag_subtree(self, subtree):
        yes = True
        for child in self.children:
            _yes_ = child.yes_no_match_via_tag_subtree(subtree)
            if not _yes_:
                yes = False
                break
        return yes

    def matchdatas_against_strings(self, strings):
        """You're not satisfied unless all your children are

        When no matches, result is None. Otherwise (and matches), result
        is a dictionary of one or more entries whose values are platform `re`
        matchdatas, and whose keys are whatever keys the child matchers employ
        (probably "tag surface strings"); probably something like:

            {'#apple': <re.Match object … >,
             '#banana': <re.Match object … >}

        There's a minor corollary to the above that can probably be safely
        ignored for most applications:

        The result structure is a flat dictionary of key-matchdata entries;
        whereas the query structure is a tree. So the result structure does
        not "isomorph" cleanly with the query structure. (We considered
        it but decided the complexity wasn't yet justified.)

        Rather, names that exist deeply in the query tree all "float up"
        to share the same flat namespace in the result structure.

        As such, it's possible to make a query tree that (while in the process
        of matching) produces multiple matchdatas under the same key (tag
        surface string) that each overwrite (shadow, clobber) the previous.

        This only happens if the query tree has re-ocurrences of the same tag
        (surface string), and other cases of short-circuiting and argument
        string occur.

        Probably such an occurrence is of no logical concern because the
        matchdatas, while different objects, are otherwise identical. (But
        it may suggest a sub-optimal query that squanders resources.)

        Superficially, it may seem that this only occurs with query trees
        that "don't make sense", like:

            "#apple and #banana and ( #pear or #apple )"

                     AND
                    / | \
                   /  |  OR --- #pear
                  /   |     \
            #apple  #banana  +-- #apple

        For all cases where argument strings match against the above,
        if the argument has "#pear" somewhwere in it, the second "#apple" is
        never considered, and so the first "#apple" is always the one that
        "won".

        (The way it breaks down is the "OR" node says "look for #pear in
        each input string. No? now look for #apple" in each.".)

        However, this will match against simply ("I love", "#banana + #apple"),
        in which case the matchdata from the query tree's *second* "#apple"
        is redundantly produced and overwrites the matchdata from the first.

        Probably a minor point.
        """

        matchdatas = None

        for offst, child in enumerate(self.children):
            ch_mds = child.matchdatas_against_strings(strings)
            if not ch_mds:
                return
            if matchdatas is None:
                matchdatas = ch_mds
            else:
                matchdatas.update(ch_mds)  # #here1

        assert matchdatas
        return matchdatas

    _ASCII_tree_label = 'AND'
    _conjunction_as_string = 'and'


class OR_List(_AND_or_OR_List):

    def AND_matcher(self, m):
        m.is_compound_matcher  # [#022]-like
        return _AND_together_somehow(self, m)

    def yes_no_match_via_tag_subtree(self, subtree):
        for child in self.children:
            yes = child.yes_no_match_via_tag_subtree(subtree)
            if yes:
                break
        return yes

    def matchdatas_against_strings(self, strings):
        """Short circuit after any first match"""

        for offst, child in enumerate(self.children):
            mixed = child.matchdatas_against_strings(strings)
            if mixed:
                return mixed

    _ASCII_tree_label = 'OR'
    _conjunction_as_string = 'or'


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

    to_string = _to_string_using_words

    def to_words(self):
        yield 'not'
        for w in self._function.to_words():
            yield w

    is_compound_matcher = False


# == tag as name chain (unsanitized then sanitized)

"""the "name chain" model :#here5:

.#open #707.K reconcile this with the newer [#705] digraph of the latest model)

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
        _inner_tagging = self.dig_recursive_(tagging)
        return _inner_tagging is not None

    def _init_dig_recursive(self):

        def name_matches(tagging):
            typ = tagging._type
            if typ in ('shallow_tagging', 'deep_tagging'):
                use_stem = tagging.head_stem
            elif 'non_head_bare_tag_stem' == typ:
                use_stem = tagging.self_which_is_string
            else:
                xx()
            return name_stem == use_stem

        name_stem = self._stem

        if self._has_child:
            def entrypoint_for_dig(tagging):
                if not tagging.is_deep:
                    # deeper query won't match shallower tag (Case3020)
                    return

                if not name_matches(tagging):
                    return

                stack = list(reversed(tagging.subcomponents))
                return child._do_dig_recursive(stack)

            child = self._child
        else:
            def entrypoint_for_dig(tagging):
                if not name_matches(tagging):
                    return
                if tagging.is_deep:
                    # Deeper tag matches shallower query (Case3030)
                    pass  # hi.
                return tagging

        def do_dig_recursive(stack):
            subtagging = stack.pop().body_slot
            if not name_matches(subtagging):
                return
            if self._has_child:
                if len(stack):
                    return child._do_dig_recursive(stack)  # recursive call
                # If the query goes deeper than the tagging, no match
                return
            # Query node has no childs. Yes match, regardless of tagging depth
            return subtagging  # or whatever

        self.dig_recursive_ = entrypoint_for_dig
        self._do_dig_recursive = do_dig_recursive

    def to_words(self):
        return (self.to_string(),)

    def to_string(self):  # BUILDS STRING ANEW AT EACH CALL.
        return ''.join(self._piece_strings())

    def _piece_strings(self):
        yield self._glyph_thing
        yield self._stem
        if self._has_child:
            for s in self._child._piece_strings():
                yield s

    is_compound_matcher = False


class _TagNameChainHeadNode(_NameChainNode):

    _glyph_thing = '#'


class _TagNameChainNonHeadNode(_NameChainNode):

    _glyph_thing = ':'


class _SimplifiedTag:

    def __init__(self, tag):
        import re
        self._regex = re.compile(''.join((r'(?:^|\s|[|(.])(', tag, r')\b')))
        # ("#ting" yes  "|#ting" yes  "(#ting" yes  ".#ting" yes   "##ting" no)

        self.as_surface_string = tag

    def AND_matcher(self, m):
        m.is_compound_matcher  # [#022]-like
        return _AND_together_somehow(self, m)

    def matchdatas_against_strings(self, strings):
        """Short-circuit after regex matches against any first argument string

        Result in None if no matches. Otherwise (and matched) result is a
        dictionary with one element whose value is the platform matchdata
        and whose key is your surface string

        If this matcher is a child of a compound matcher, this dictionary
        may be commandeered (mutated) by a caller #here1

        The platform matchdata exposes a property that allows you to know
        which string was matched against (by content or by object ID).
        """

        assert isinstance(strings, tuple)  # [#022]
        md = None  # maybe no strings
        for string in strings:
            if (md := self._regex.search(string)):
                break
        if md is None:
            return
        return {self.as_surface_string: md}

    def to_ASCII_tree_lines(self):
        return _ASCII_tree_lines_via_branch_node(self)  # exercise it

    def to_words(self):
        return (self.as_surface_string,)

    @property
    def _ASCII_tree_label(self):
        return self.as_surface_string

    is_compound_matcher, is_leaf_matcher = False, True


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

    to_string = _to_string_using_words

    def to_words(self):
        for w in self._tagging_query.to_words():
            yield w
        yield 'in'
        for w in self._in_suffix_payload.to_words():
            yield w


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
            found = child.dig_recursive_(tagging)
            if found is not None:
                return my_test(found)

        self._this_test = f
        self._child = child

    def yes_no_match_via_tag_subtree(self, subtree):  # ##here2
        return in_subtree_match_any_one_(subtree, self._this_test)

    to_string = _to_string_using_words

    def to_words(self):
        for w in self._child.to_words():
            yield w
        yield self._keyword
        yield 'value'


class _WithValue(_WithOrWithoutValue):

    def _my_test(tagging_node):
        return tagging_node.is_deep

    _keyword = 'with'


class _WithoutValue(_WithOrWithoutValue):

    def _my_test(tagging_node):
        return not tagging_node.is_deep

    _keyword = 'without'


# == xx


def _ASCII_tree_lines_via_branch_node(root_node):  # #[#612.8] one of two
    return _ASCII_tree_recursive('', '', root_node)


def _ASCII_tree_recursive(head, smear, node):
    yield f"{head}{node._ASCII_tree_label}\n"
    if node.is_leaf_matcher:
        return
    cx = node.children
    leng = len(cx)
    assert leng
    last = leng - 1
    if last:
        ch_head = f"{smear}├──"
        ch_smear = f"{smear}|  "

    last_ch_head = f"{smear}└──"
    last_ch_smear = f"{smear}  "

    for i in range(0, leng):
        if last == i:
            ch_head = last_ch_head
            ch_smear = last_ch_smear
        for line in _ASCII_tree_recursive(ch_head, ch_smear, cx[i]):
            yield line


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


def pop_property(o, attr):
    x = getattr(o, attr)
    delattr(o, attr)
    return x


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))


# #history-B.4 spike hand-written simplification as replacement for vendor
# #history-B.3: accomodate new simplified sexp pattern
# #history-A.1: deep vs shallow distinction out. simplified name-chain model in
# #born.
