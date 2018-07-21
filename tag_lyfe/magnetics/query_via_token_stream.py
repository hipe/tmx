"""
this file has a "discussion" at #here1 #todo
"""


from modality_agnostic import memoization as _
memoize = _.memoize


def RUMSKALLA(serr, query_s):

    def my_pprint(x):
        from pprint import pprint
        pprint(x, stream=serr, width=20, indent=4)

    itr = MAKE_CRAZY_ITERATOR_THING(query_s)
    print('the model:')
    my_pprint(next(itr))

    print('the unsani:')
    unsani = next(itr)

    from script_lib.magnetics import listener_via_resources as _
    listener = _.listener_via_stderr(serr)

    wat = unsani.sanitize(listener)

    print('the sani:')
    my_pprint(wat)

    return 1 if wat is None else 0


def MAKE_CRAZY_ITERATOR_THING(query_s):
    """the obviously huge disadvantage here is hardcoded offsets (in effect).

    the advantage is progressive output, good for debugging
    """

    model = query_model_via_big_string(query_s)
    yield model

    _walker = _make_walker()
    unsani = _walker.walk(model)
    yield unsani


def _make_walker():
    """so:

    - ideally this scope will be the only place where we "wire up" all this
      parser-generator-specific stuff (including grammar) with our native,
      insulated AST model (see)

    - for now we enclose this whole doo-hah in this function call to
      load its dependency modules late for regression-friendliness and
      maybe efficiency for some cases. (no)
    """

    import tag_lyfe.the_query_model as native_models
    from tatsu.walkers import NodeWalker

    class MyWalker(NodeWalker):

        def walk_object(self, node):
            print(f'(reminder: {type(node)})')
            return node

        def walk__top_thing(self, node):
            # say something about #here1
            child_EEK_stack = self.walk(node.payload)
            child_EEK_stack.reverse()
            return native_models.UNSANITIZED_LIST(tuple(child_EEK_stack))

        def walk__atom_or_branch(self, node):
            left = node.left
            right = node.right
            left_native_AST = self.walk(left)
            if right is None:
                return [left_native_AST]  # the buck starts :#here1
            else:
                child_EEK_stack = self.walk(right)
                child_EEK_stack.append(left_native_AST)
                return child_EEK_stack

        def walk__continuing(self, node):
            a_o_o = node.and_or_or
            child_EEK_stack = self.walk(node.atom_or_branch)
            child_EEK_stack.append(a_o_o)
            return child_EEK_stack

        def walk__surface_tag(self, node):
            return native_models.UNSANITIZED_TAG(node.tag_stem)

    return MyWalker()


def query_model_via_big_string(big_string):

    parser = query_parser()

    model = parser.parse(
            text=big_string,
            # semantics=JimFlim(),
            )

    return model


@memoize
def query_parser():

    with open('tag_lyfe/grammars/the-query-grammar.ebnf') as fh:
        ebnf_grammar_big_string = fh.read()

    import tatsu
    _ = tatsu.compile(
            ebnf_grammar_big_string,
            asmodel=True,
            )
    return _


# #born.
