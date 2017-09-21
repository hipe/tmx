# frozen_string_literal: true

module Skylab::BeautySalon

  class CrazyTownMagnetics_::Selector_via_String < Common_::MagneticBySimpleModel

    # ==

    class Selector___

      def initialize tng, is_AND, list, sym
        @list_is_AND_list_not_OR_list = is_AND
        @list_of_boolean_tests = list
        @feature_symbol = sym
        @tupling = tng
      end

      def on_each_occurrence_in writable_hooks_plan, & receive_wrapped_sexp

        test_sexp = NodeTester_via_TestList_and_Tupling___.call_by do |o|
          o.test_list = @list_of_boolean_tests
          o.list_is_AND_list_not_OR_list = @list_is_AND_list_not_OR_list
          o.tupling = @tupling
        end

        writable_hooks_plan.on_this_one_type_of_node @feature_symbol do |s|

          wrapped = test_sexp[ s ]
          if wrapped
            receive_wrapped_sexp[ wrapped ]
          end
        end

        NIL
      end

      attr_reader(
        :list_of_boolean_tests,
        :feature_symbol,
      )
    end

    # ==

    # -
      attr_writer(
        :string,
        :listener,
      )

      def execute
        if __first_pass
          __second_pass
        end
      end

      def __second_pass
        if __names_are_valid
          t = remove_instance_variable :@_tree
          Selector___.new(
            remove_instance_variable( :@_tupling ),
            t.list_is_AND_list_not_OR_list,
            t.list_of_boolean_tests,
            t.feature_symbol,
          )
        end
      end

      def __names_are_valid
        if __check_and_resolve_entity_name
          __check_attribute_names
        end
      end

      def __check_and_resolve_entity_name
        if __check_that_name_is_in_list_of_known_grammar_symbols
          __check_that_we_have_our_special_meta_information_for_this_grammar_symbol
        end
      end

      def __check_attribute_names
        ok = true
        h = @_tupling::COMPONENTS
        @_tree.list_of_boolean_tests.each do |bool_test|
          k = bool_test.symbol_symbol
          if ! h[ k ]
            __levenshtein_for_component( k ) { h.keys }
            ok = false ; break
          end
        end
        ok
      end

      def __levenshtein_for_component ick_sym

        _express_parse_error do |y|

          _sym_a = yield

          _s_a = _sym_a.map { |sym| "'#{ sym }'" }

          y << %(grammar symbol '#{ _entity_name_symbol }' has no component "#{ ick_sym }".)
          y << "known component(s): #{ Common_::Oxford_and[ _s_a ] }"
        end
      end

      def __check_that_we_have_our_special_meta_information_for_this_grammar_symbol

        _ = Home_::CrazyTownMagnetics_::SemanticTupling_via_Node.
          tuplings_as_feature_branch.procure _entity_name_symbol, & @listener

        _store :@_tupling, _
      end

      def __check_that_name_is_in_list_of_known_grammar_symbols

        h = CrazyTownMagnetics_::NodeProcessor_via_Methods.grammar_reflection_hash
        if h[ _entity_name_symbol ]
          ACHIEVED_
        else
          __levenshtein_for_entity_name { h.keys }
        end
      end

      def __levenshtein_for_entity_name

        _express_parse_error do |y|

          _ks = yield

          ick_sym = _entity_name_symbol

          _s_a = Home_.lib_.human::Levenshtein.via(
            :item_string, ick_sym.id2name,
            :items, _ks,
            :stringify_by, -> k { k.id2name },
            :map_result_items_by, -> s { %('#{ s }') },
            :closest_N_items, 3,
          )
          y << %(unrecognized grammar symbol "#{ ick_sym }".)
          y << "did you mean #{ Common_::Oxford_or[ _s_a ] }?"
        end
      end

      def _entity_name_symbol
        @_tree.feature_symbol
      end

      def _express_parse_error
        @listener.call :error, :expression, :parse_error do |y|
          yield y
        end
        UNABLE_
      end

      def __first_pass

        _ = Here_::ParseTree_via_String.call_by do |o|
          o.string = remove_instance_variable :@string
          o.listener = @listener
        end
        _store :@_tree, _
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

    # -

    # ==

    class NodeTester_via_TestList_and_Tupling___ < Common_::MagneticBySimpleModel

      # implement boolean "test" expressions, eg. to find all method calls
      # in the corpus whose method name is `puts`:
      #
      #     method_call( method_name = 'puts' )
      #
      # (the above is didactic. actual labels for these terms may vary.)
      #
      # we produce a proc that receives document AST nodes and (when the
      # node matches) results in a "tupling" *instance* wrapping that AST
      # node.

      # the whole thing here is we don't create a tupling (viz wrapped node
      # instance) for every node of this type in the corpus. rather we only
      # create it IFF the node matches the selector body (the boolean tests).
      #
      # to implement this we have to access the components of the document
      # AST nodes using those components offsets before we can wrap them
      # in the tupling (which abstracts away the use of the offsets).

      attr_writer(
        :list_is_AND_list_not_OR_list,
        :test_list,
        :tupling,
      )

      def execute

        if 1 == @test_list.length
          _test_AST = remove_instance_variable( :@test_list )[0]
          __test_proc_via_test_AST _test_AST
        else
          self._HAVE_FUN__etc__ @list_is_AND_list_not_OR_list
        end
      end

      def __test_proc_via_test_AST test_AST

        NodeTester_via_Component_and_Test_AST___.call_by do |o|
          o.component = @tupling::COMPONENTS.fetch test_AST.symbol_symbol
          o.test_AST = test_AST
          o.tupling = @tupling
        end
      end
    end

    # ==

    class NodeTester_via_Component_and_Test_AST___ < Common_::MagneticBySimpleModel

      # (as documented in only client, above)

      attr_writer(
        :component,
        :test_AST,
        :tupling,
      )

      def execute
        send THESE___.fetch @test_AST.comparison_function_name_symbol
      end

      THESE___ = {
        _EQ_: :__node_test_proc_for_simple_value_equality,
      }

      def __node_test_proc_for_simple_value_equality

        mixed_target_value = __prepare_target_value_for_comparison

        component_offset = @component.offset

        -> n do

          if mixed_target_value == n.children.fetch( component_offset )
            @tupling.via_node_ n
          end
        end
      end

      def __prepare_target_value_for_comparison
        send THESE2___.fetch @component.type_symbol
      end

      THESE2___ = {
        symbol: :__prepare_target_value_for_comparison_when_symbol,
      }

      def __prepare_target_value_for_comparison_when_symbol

        # for certain #reasons1.3, the target name as expressed in selectors
        # looks like a single quoted string. befitting an AST, these names
        # come to us as strings. it is here that we convert this target name
        # to the same type as it will be in the document AST node (as symbol)
        # so that we only have to make this type conversion once per query,
        # as opposed to converting each document AST node that we traverse.

        @test_AST.literal_value.intern
      end
    end

    # ==

    Here_ = self

    # ==
    # ==
  end
end
# #tombstone-A.3: sunset hackish attemt to get ending line numbers with 'ruby_parser'
# #history-A.2: finish the bulk of the work of transition to ragel (for parsing selectors)
# #history-A.1: begin rewrite to use ragel
# born.
