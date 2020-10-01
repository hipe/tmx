"""
exactly as [#707.G] describes (in its various places), this module (file)

serves as a boundary wall around the specifics of the parser generator.
for this grammar (tagging), no other part of the sub-project should have
to know the specifics of working with our grammar and our parser-generator.

this takes as input a "one big string" and puts as output something like
a big S-expression.
"""

from modality_agnostic import lazy


def doc_pairs_via_string(input_string):
    return _walk_using_this('the_only_walker', input_string)


def _walk_using_this(which, input_string):
    walker = getattr(_walkers(), which)
    model = _query_parser().parse(
            text=input_string,
            whitespace='')  # we do our own whitespace. see #here2
    return walker.walk(model)


@lazy
def _walkers():
    """as explained in the counterpart file (referenced in a tag at top of
    file), things regress more nicely when we load this lazily
    """

    from tatsu.walkers import NodeWalker

    def attrs(*attrs):  # #decorator
        def decorator(orig_f):
            def use_f(walker, node):
                vals = (getattr(node, attr) for attr in attrs)
                return orig_f(walker, *vals)
            return use_f
        return decorator

    class SexpBasedWalker(NodeWalker):

        def walk_object(self, node):
            raise RuntimeError(f'ohai: {type(node)}')

        def walk__top_thing(self, node):
            # kind of an ugly asymmetry that every other method results in
            # sexps but we result in an AST but meh

            cx = tuple(self.top_thing_children(node))
            sx = 'top_thing', cx
            from tag_lyfe.the_tagging_model import ast_via_sexp_ as func
            return func(sx)

        @attrs('head_sep', 'first_tagging', 'more_taggings', 'tail_garbage')
        def top_thing_children(
                self, head_sep, first_tagging, more_taggings, tail_garbage):

            if first_tagging:
                for sep, tag in ((head_sep, first_tagging), *more_taggings):
                    if sep:
                        wat1 = self.walk(sep)
                        assert isinstance(wat1, str)
                    else:
                        wat1 = ''
                    wat2 = self.walk(tag)
                    yield 'not_tag_then_tag', wat1, wat2

            if len(tail_garbage):
                yield 'not_tag_then_tag', ''.join(tail_garbage), None

        def walk__tagging_separator(self, node):
            def recurse(ast):
                for x in ast:
                    if isinstance(x, str):
                        flat_pieces.append(x)
                    else:
                        assert isinstance(x, list)
                        recurse(x)
            flat_pieces = []
            recurse(node.ast)
            return ''.join(flat_pieces)

        @attrs('head_stem', 'any_tail')
        def walk__wahoo_tagging(self, head_stem, any_tail):
            assert isinstance(head_stem, str)  # #[#022]
            if any_tail is None:
                return 'shallow_tagging', '#', head_stem
            cx = tuple(self.child_tag(colon, x) for colon, x in any_tail)
            return 'deep_tagging', '#', head_stem, cx

        def child_tag(self, colon, node):
            assert ':' == colon
            various = self.walk(node)
            assert isinstance(various, tuple)
            return 'tagging_subcomponent', ':', various

        def walk__non_head_tag_surface_name_as_is(self, node):
            assert isinstance(node.ast, str)
            return ('non_head_bare_tag_stem', node.ast)

        def walk__double_quoted_string(self, node):
            """
            make a sexp-like list structure that alternates between
            "raw_string" and "escaped_character"; this structure can be
            rendered in a surface or deep way depending on the client.
            (Case1030)
            """

            sxs, chars = [], []

            def swallow_string():
                if len(chars):
                    sxs.append(('raw_string', ''.join(chars)))
                    chars.clear()

            for x in node.inside:
                hello, is_escaped, s = self.walk(x)
                assert 'hello_internally' == hello
                if is_escaped:  # #here2
                    swallow_string()  # (Case1040) 1/2
                    sxs.append(('escaped_character', '\\', s))
                else:
                    chars.append(s)

            swallow_string()
            return 'double_quoted_string', '"', tuple(sxs), '"'

        def walk__escaped_double_quote(self, node):
            return 'hello_internally', True, '"'  # (Case1040) 2/2

        def walk__not_double_quote(self, node):
            return 'hello_internally', False, node.ast

        def walk__bracketed_lyfe(self, node):
            string, = node.the_inside
            assert isinstance(string, str)  # [#022]
            return 'bracketed_lyfe', '[', string, ']'

    class walkers:  # #as-namespace-only
        the_only_walker = SexpBasedWalker()

    return walkers


""".:#here3: one day we might not want to bother calling walk if we know
exactly what kind of (grammatical) node this is #open [#709.C])
"""


@lazy
def _query_parser():
    from tag_lyfe import grammar_path_
    _grammar_path = grammar_path_('the-tagging-grammar.ebnf')

    with open(_grammar_path) as fh:
        ebnf_grammar_big_string = fh.read()

    import tatsu
    return tatsu.compile(
            ebnf_grammar_big_string,
            asmodel=True)


""".:[#707.H]: :#here2:

as it says in the TatSu documentation (in the "Grammar Syntax" section),

    If you do not define any whitespace characters, then you will have to
    handle whitespace in your grammar rules (as it’s often done in PEG parsers)

we do this here because we want fine-grained control of how we decide what
is and isn't whitespace. (actually we don't have much of a concept of it
in our grammar.)
"""

# #history-B.3: overhaul to use new simplified sexp pattern
# #born.
