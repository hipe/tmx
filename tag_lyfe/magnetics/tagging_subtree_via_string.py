"""
exactly as [#707.G] describes (in its various places), this module (file)

serves as a boundary wall around the specifics of the parser generator.
for this grammar (tagging), no other part of the sub-project should have
to know the specifics of working with our grammar and our parser-generator.

this takes as input a "one big string" and puts as output something like
our custom, native AST.
"""

from modality_agnostic import memoization as _
memoize = _.memoize


def doc_pairs_via_string(input_string):

    _model = _query_parser().parse(
            text=input_string,
            whitespace='',  # we do our own whitespace. see #here2
            )

    return _memoized_walker().walk(_model)


@memoize
def _memoized_walker():
    """as explained in the counterpart file (referenced in a tag at top of
    file), things regress more nicely when we load this lazily
    """

    import tag_lyfe.the_tag_model as native_models
    from tatsu.walkers import NodeWalker

    class MyWalker(NodeWalker):

        def walk_object(self, node):
            raise Exception(f'hello: {type(node)}')

        def walk__top_thing(self, node):
            """
            NOTE we are a GENERATOR which is NEAT HERE

            (make a little mess so we accomodate the document (string) both
            with and without taggings using the same function..
            """

            ft = node.first_tagging
            if ft is not None:

                _ts = self._my_walk_tagging_sep(node.head_sep)
                _ta = self.walk(ft)  # #TODO

                yield native_models.DocumentPair(_ts, _ta)

                for (tagging_sep, tagging) in node.more_taggings:

                    _ts = self.walk(tagging_sep)
                    _ta = self.walk(tagging)

                    yield native_models.DocumentPair(_ts, _ta)

            a = node.tail_garbage
            if len(a):
                use_tail = ''.join(a)
            else:
                use_tail = ''

            yield native_models.EndPiece(use_tail)

        def _my_walk_tagging_sep(self, node):
            if node is None:
                return ''
            else:
                return self.walk(node)  # #TODO

        def walk__tagging_separator(self, node):
            """
            MEMORY
            """
            flat_pieces = []

            def recurse(ast):
                for x in ast:
                    if isinstance(x, str):
                        flat_pieces.append(x)
                    else:
                        recurse(x)
            recurse(node.ast)
            return ''.join(flat_pieces)

        def walk__wahoo_tagging(self, node):
            head_stem = node.head_stem
            x = node.any_tail
            if x is None:
                return native_models.tagging_via_sanitized_tag_stem(head_stem)
            else:
                pcs = [native_models.BareNameComponent(head_stem)]
                for _colon, mixed_name in x:
                    pcs.append(self.walk(mixed_name))
                return native_models.deep_tagging_via_name_components(pcs)

        def walk__non_head_tag_surface_name_as_is(self, node):
            # #coverpoint1.8.2: plain doo-hah
            return native_models.BareNameComponent(node.ast)

        def walk__double_quoted_string(self, node):
            """
            #coverpoint1.8.3: neet
            make a sexp-like list structure that alternates between
            "raw_string" and "escaped_character"; this structure can be
            rendered in a surface or deep way depending on the client.
            """

            final_pieces = []
            chars = []

            def swallow_string():
                if len(chars):
                    final_pieces.append(('raw_string', ''.join(chars)))
                    chars.clear()

            for x in node.inside:
                is_escaped, s = self.walk(x)
                if is_escaped:  # #here2
                    # ##coverpoint1.8.4
                    swallow_string()
                    final_pieces.append(('escaped_character', s))
                else:
                    chars.append(s)

            swallow_string()

            return native_models.DoubleQuotedStringNameComponent(tuple(final_pieces))  # noqa: E501

        def walk__escaped_double_quote(self, node):  # ##coverpoint1.8.4
            return (True, '"')  # or (ick/meh) node.ast[1]

        def walk__not_double_quote(self, node):
            return (False, node.ast)  # #here2

    return MyWalker()


@memoize
def _query_parser():

    with open('tag_lyfe/grammars/the-tagging-grammar.ebnf') as fh:
        ebnf_grammar_big_string = fh.read()

    import tatsu
    _ = tatsu.compile(
            ebnf_grammar_big_string,
            asmodel=True,
            )
    return _


""".:[#707.H]: :#here2:

as it says in the TatSu documentation (in the "Grammar Syntax" section),

    If you do not define any whitespace characters, then you will have to
    handle whitespace in your grammar rules (as it’s often done in PEG parsers)

we do this here because we want fine-grained control of how we decide what
is and isn't whitespace. (actually we don't have much of a concept of it
in our grammar.)
"""

# #born.
