"""
the query model:
  - (is EXPERIMENTAL with regards to ALL of these following provisions)
  - is divorced from any particular parser generator (so, must take no
    parser-generator-generated AST's as construction arguments).
  - yet still can reconstruct itself into a surface string losslessly (..)
  - is practical to be used as an end-of-the-line business object, e.g
    for real queries (but put workers in magnets. this is a cold model.)

the idea is that:
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


def _to_string_using_wordables(self):
    """we don't use NULL_BYTE_ we use space! just like, a convention man"""

    return ' '.join(x.to_string() for x in self._wordables())


# == AND lists and OR lists

class UNSANITIZED_LIST:
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
            _sani_node = _unsani_node.sanitize(listener)
            return _sani_node  # #todo

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

    def to_string(self):
        itr = iter(self.children)
        pieces = [next(itr).to_string()]
        sep = _seperator_via_conjunction(self.conjunction)
        for node in itr:
            pieces.append(sep)
            pieces.append(node.to_string())
        return ''.join(pieces)


class AND_List(_AND_or_OR_List):

    def yes_no_match_via_tag_subtree(self, subtree):
        yes = True
        for child in self.children:
            _yes_ = child.yes_no_match_via_tag_subtree(subtree)
            if not _yes_:
                yes = False
                break
        return yes

    @property
    def conjunction(self):
        return AND


class OR_List(_AND_or_OR_List):

    def yes_no_match_via_tag_subtree(self, subtree):
        for child in self.children:
            yes = child.yes_no_match_via_tag_subtree(subtree)
            if yes:
                break
        return yes

    @property
    def conjunction(self):
        return OR


def _build_sep_via_conj():  # silly fun..

    def same(s, which):
        def f():
            surface = f' {s} '  # #space-for-null-byte

            def g():
                return surface
            cache[which] = g
            return _seperator_via_conjunction(which)
        return f

    cache = {  # :#here1
            AND: same('and', AND),
            OR: same('or', OR),
            }

    def _seperator_via_conjunction(which):
        return cache[which]()

    return _seperator_via_conjunction


AND = 1  # (define these here because they are used in the next call #here1)
OR = 2


_seperator_via_conjunction = _build_sep_via_conj()


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

    to_string = _to_string_using_wordables

    def _wordables(self):
        yield _NOT_AS_WORDABLE
        for x in self._function._wordables():
            yield x


class _NOT_AS_WORDABLE:  # #class-as-namespace

    def to_string():
        return 'not'


# == deep tag components (unsanitized then sanitized)

class _UnsanitizedDeepSelector:

    def __init__(self, tup, ut):

        def to_pieces():
            yield ut.unsanitized_tag_stem
            for x in tup:
                yield x.unsanitized_component_stem

        self._unsanitized_pieces = tuple(to_pieces())
        pass

    def sanitize(self, listener):
        pieces = pop_property(self, '_unsanitized_pieces')
        last = len(pieces) - 1

        def f(cursor, deep_class):
            s = pieces[cursor]
            if last == cursor:
                # near [#707.C]: for now allow any string for value expression
                return _ValueBasedTailSelector(s)
            else:
                if not _validate_tag_stem_name(listener, s):
                    return
                child = f(cursor + 1, _NonHeadDeepSelector)
                if child is None:
                    return
                return deep_class(s, child)

        return f(0, _DeepSelector)


class UnsanitizedDeepSelectorComponent:

    def __init__(self, unsanitized_component_stem):
        self.unsanitized_component_stem = unsanitized_component_stem


class _DeepSelNode:

    def _to_string_shallow(self):
        return f"{self._this_one_char}{self._component_stem}"


class _DeepSelDeepNode(_DeepSelNode):

    def __init__(self, sanitized_tag_stem, child):
        self._this_test = _build_this_test(sanitized_tag_stem, child)
        self._component_stem = sanitized_tag_stem
        self._child = child

    def _components(self):
        yield self
        for x in self._child._components():
            yield x


class _DeepSelector(_DeepSelDeepNode):

    def yes_no_match_via_tag_subtree(self, subtree):
        return _in_subtree_match_any_one(subtree, self._this_test)

    def to_string(self):
        _wee = [node._to_string_shallow() for node in self._components()]
        return ''.join(_wee)

    def _wordables(self):
        yield self

    _this_one_char = '#'


class _NonHeadDeepSelector(_DeepSelDeepNode):

    def _yes_no_match_via_tagging(self, tagging):
        return self._this_test(tagging)  # #hi.

    _this_one_char = ':'


class _ValueBasedTailSelector(_DeepSelNode):

    def __init__(self, any_string):
        self._component_stem = any_string

    def _yes_no_match_via_tagging(self, tagging):
        if tagging.is_deep:
            # #coverpoint1.16.3: deeper tag matches shallower query
            return self._component_stem == tagging.tag_stem
        else:
            return self._component_stem == tagging.tag_stem

    def _components(self):
        yield self

    _this_one_char = ':'


# == the head tag component (unsanitized then sanitized)

class UnsanitizedShallowOrDeepTag:

    def __init__(self, unsanitized_tag_stem):
        self.unsanitized_tag_stem = unsanitized_tag_stem

    def become_deep__(self, tup):
        return _UnsanitizedDeepSelector(tup, self)

    def sanitize(self, listener):
        s = pop_property(self, 'unsanitized_tag_stem')
        if _validate_tag_stem_name(listener, s):
            return _ShallowTag(s)


class _ShallowTag:

    def __init__(self, tag_stem):
        self.tag_stem = tag_stem

    def yes_no_match_via_tag_subtree(self, subtree):
        target = self.tag_stem

        def yes_no_via_tag(tag):
            return tag.tag_stem == target

        return _in_subtree_match_any_one(subtree, yes_no_via_tag)

    def _wordables(self):
        yield self

    def to_string(self):  # BUILDS STRING ANEW AT EACH CALL. ##here2
        return f'#{self.tag_stem}'


# == support


def _in_subtree_match_any_one(subtree, yes_no_via_tag):
    yes = False
    for tag in subtree:  # ..
        if yes_no_via_tag(tag):
            yes = True
            break
    return yes


def _build_this_test(query_component_stem, query_child):

    def yes_no_via_tag(tagging):
        # you know that your query (from this node) is deep..

        if tagging.is_deep:
            if query_component_stem == tagging.tag_stem:
                return query_child._yes_no_match_via_tagging(tagging.child)
            else:
                return False  # covered
        else:
            # #coverpoint1.16.2 deeper query won't match shallower tagging
            return False

    return yes_no_via_tag


def _validate_tag_stem_name(listener, s):  # #track [#707.C] when we formalize
    return True


# #born.
