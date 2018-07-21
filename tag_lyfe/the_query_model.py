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
            return None

        elif 0 == len(stack):
            return sani_node  # CHANGE STRUCTURE (native ASTs: no 1-len lists)
        else:
            sani_nodes = [sani_node]
            current_and_or_or = stack.pop()  # assume
            while True:

                sani_node = sanitized_node_via_stack_pop()
                if sani_node is None:
                    return None

                sani_nodes.append(sani_node)
                if 0 == len(stack):
                    break

                next_and_or_or = stack.pop()  # assume
                if current_and_or_or != next_and_or_or:

                    self._whine(listener, sani_nodes, next_and_or_or, current_and_or_or)  # noqa: E501

                    return None

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
    @property
    def conjunction(self):
        return AND


class OR_List(_AND_or_OR_List):
    @property
    def conjunction(self):
        return OR


# (these have to be defined here because they are used #here1 below)
AND = 1
OR = 2


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


_seperator_via_conjunction = _build_sep_via_conj()


_AND_list_or_OR_list_via_conjunction_string = {
        'and': AND_List,
        'or': OR_List,
        }




class UNSANITIZED_TAG:

    def __init__(self, unsanitized_tag_stem):
        self.unsanitized_tag_stem = unsanitized_tag_stem

    def sanitize(self, listener):
        return ALL_PURPOSE_TAG(self.unsanitized_tag_stem)


class ALL_PURPOSE_TAG:

    def __init__(self, tag_stem):
        self.tag_stem = tag_stem

    def to_string(self):  # BUILDS STRING ANEW AT EACH CALL
        return f'#{self.tag_stem}'


# #born.
