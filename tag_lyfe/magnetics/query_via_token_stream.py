"""
:[#707.G]: parser-generator isolation:

this module (file) intends to be the only code that touches or has to
realy know about the specifics of the parser generator (in the scope of
this one grammar - there can be other such modules for other grammars).

also, see #here2 which explains how we isolate w/ re: to AST.
"""

from modality_agnostic import lazy


def RUMSKALLA(serr, query_s):

    def my_pprint(x):
        from pprint import pprint
        pprint(x, stream=serr, width=20, indent=4)

    itr = MAKE_CRAZY_ITERATOR_THING(query_s)
    print('the model:')
    my_pprint(next(itr))

    print('the unsani:')
    unsani = next(itr)

    from script_lib.magnetics.error_monitor_via_stderr import func
    monitor = func(serr)

    wat = unsani.sanitize(monitor.listener)

    print('the sani:')
    my_pprint(wat)

    return monitor.exitstatus


def MAKE_CRAZY_ITERATOR_THING(query_s):
    """the obviously huge disadvantage here is hardcoded offsets (in effect).

    the advantage is progressive output, good for debugging
    """

    model = query_model_via_big_string(query_s)
    yield model

    _walker = _memoized_walker()
    unsani = _walker.walk(model)
    yield unsani


@lazy
def _memoized_walker():
    """isolate parser-generator specifics w/ re: to AST :#here2:

    so:

    - ideally this scope will be the only place where we "wire up" all this
      parser-generator-specific stuff (including grammar) with our native,
      insulated AST model (see)

    - for now we enclose this whole doo-hah in this function call to
      load its dependency modules late for [#010.6] regression-friendliness and
      maybe efficiency for some cases. (no)
    """

    import tag_lyfe.the_query_model as native_models
    from tatsu.walkers import NodeWalker

    class MyWalker(NodeWalker):

        def walk_object(self, node):  # #open #[#709.B] temporary for dev
            _msg = f'write me: walker for: {type(node)}'
            raise Exception(_msg)
            print(_msg)
            return node

        def walk__top_thing(self, node):
            return self._unsanitized_list(node)

        def walk__parenthesized_group(self, node):
            _unsani_list = self._unsanitized_list(node)
            return native_models.UnsanitizedParenthesizedGroup(_unsani_list)

        def _unsanitized_list(self, node):
            # the buck (array) starts at #here1
            child_EEK_stack = self.walk(node.item_or_list_as_local_top)
            child_EEK_stack.reverse()
            return native_models.UnsanitizedList(tuple(child_EEK_stack))

        def walk__conjuncted(self, node):
            a_o_o = node.and_or_or
            child_EEK_stack = self.walk(node.item_or_list)
            child_EEK_stack.append(a_o_o)
            return child_EEK_stack

        def walk__item_or_list(self, node):
            return self._same_buckstop(node)

        def walk__negated_function(self, node):
            _ohai = self.walk(node.negatable)
            return native_models.UnsanitizedNegation(_ohai)

        def walk__tagging_matcher(self, node):
            tp = self.walk(node.tagging_path)
            mf = node.modifying_suffix
            if mf is None:
                return tp
            else:
                mf = self.walk(mf[1])
                return mf.unsanitized_via_finish(tp)

        def walk__tagging_path(self, node):
            ut = self.walk(node.surface_tag)  # unsanitized tag
            ds = node.deep_selector
            if ds is None:
                return ut
            else:
                EEK_stack = self.walk(ds)
                EEK_stack.reverse()
                return ut.become_deep__(tuple(EEK_stack))

        def walk__deep_selector(self, node):
            return self._same_buckstop(node)

        def walk__deep_selector_component(self, node):
            return native_models.UnsanitizedDeepSelectorComponent(
                    node.deep_selector_rough_stem)

        def walk__surface_tag(self, node):
            return native_models.UnsanitizedShallowOrDeepTag(node.tag_stem)

        def walk__in_suffix(self, node):
            _unsani_in_suffix_payload = self.walk(node.in_suffix_payload)
            return native_models.UnsanitizedInSuffix(_unsani_in_suffix_payload)

        # -- begin would-be plugins

        def walk__list_of_values_for_in_suffix(self, node):
            from tag_lyfe.the_query_model_plugins import in_list_of_values as o
            x_a = self._SIMPLE_buckstop(node.values_for_in_suffix)
            x_a.reverse()
            return o.UnsanitizedInValuesFunction(tuple(x_a))

        def walk__numeric_range(self, node):
            from tag_lyfe.the_query_model_plugins import in_numeric_range as o
            begin_AST = self.walk(node.begin_number)
            end_AST = self.walk(node.end_number)
            return o.UnsanitizedInRange(begin_AST, end_AST)

        def walk__easy_number(self, node):
            use_string = node.integer_part
            float_strings = node.float_part
            if float_strings is None:
                use_number = int(use_string)
            else:
                decimal, digits, _ignore = float_strings  # (Case7050)
                use_string = f'{ use_string }{ decimal }{ digits }'
                use_number = float(use_string)
            from tag_lyfe.the_query_model_plugins import in_numeric_range as o
            return o.EasyNumber(use_number, use_string)

        def walk__hacky_regex_friendo(self, node):
            from tag_lyfe.the_query_model_plugins import in_regex as o
            return o.UnsanitizedInRegex(node.hacky_regex_payload)

        # -- end would-be plugins

        def walk__with_or_without_value(self, node):
            _yes = true_false_via_with_or_without[node.with_or_without]
            return native_models.UnsanitizedWithOrWithoutFirstStep(_yes)

        def _same_buckstop(self, node):
            return self._reversed_list_from_common_right_recursion(
                    node, self.walk, self.walk)

        def _SIMPLE_buckstop(self, node):
            return self._reversed_list_from_common_right_recursion(
                    node, lambda x: x, self._SIMPLE_buckstop)

        def _reversed_list_from_common_right_recursion(
                self, node, walk_left, walk_right):

            left = node.left
            right = node.right
            left_native_AST = walk_left(left)
            if right is None:
                return [left_native_AST]  # the buck starts :#here1
            else:
                mutable_reversed_list = walk_right(right)
                mutable_reversed_list.append(left_native_AST)
                return mutable_reversed_list

    true_false_via_with_or_without = {
            'with': True,
            'without': False,
            }

    return MyWalker()


def query_model_via_big_string(big_string):

    parser = query_parser()

    return parser.parse(
            text=big_string,
            whitespace='')  # see [#707.H] how we do our own whitespace


@lazy
def query_parser():
    from .tagging_subtree_via_string import grammar_path_ as func
    _grammar_path = func('the-query-grammar.ebnf')

    with open(_grammar_path) as fh:
        ebnf_grammar_big_string = fh.read()

    import tatsu
    return tatsu.compile(
            ebnf_grammar_big_string,
            asmodel=True)

# #born.
