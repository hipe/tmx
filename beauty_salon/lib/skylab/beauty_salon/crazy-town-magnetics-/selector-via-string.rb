# frozen_string_literal: true

module Skylab::BeautySalon

  class CrazyTownMagnetics_::Selector_via_String < Common_::MagneticBySimpleModel

    # ==

    class Selector___

      def initialize snc, is_AND, list, sym
        @list_is_AND_list_not_OR_list = is_AND
        @list_of_boolean_tests = list
        @feature_symbol = sym
        @structured_node_class = snc
      end

      def on_each_occurrence_in writable_hooks_plan, & receive_wrapped_sexp

        test_sexp = NodeTester_via_TestList_and_StructuredNodeClass___.call_by do |o|
          o.test_list = @list_of_boolean_tests
          o.list_is_AND_list_not_OR_list = @list_is_AND_list_not_OR_list
          o.structured_node_class = @structured_node_class
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
        :grammar_symbols_feature_branch,
        :listener,
        :string,
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
            remove_instance_variable( :@_structured_node_class ),
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

        has = @_structured_node_class.terminal_association_index_has_reference_as_function__

        to_symbol_scanner = -> do
          @_structured_node_class.to_symbolish_reference_scanner_of_terminals_as_grammar_symbol_class__
        end

        @_tree.list_of_boolean_tests.each do |bool_test|
          k = bool_test.symbol_symbol
          if ! has[ k ]
            __levenshtein_for_component k, & to_symbol_scanner
            ok = false ; break
          end
        end

        ok
      end

      def __levenshtein_for_component ick_sym

        _express_parse_error do |y, expag|

          ent_sym = _entity_name_symbol

          expag.calculate do

            y << %(grammar symbol '#{ ent_sym }' has no component "#{ ick_sym }".)

            simple_inflection do

              _sym_scn = yield
              buff = oxford_join ::String.new, _sym_scn do |sym|
                "'#{ sym }'"
              end
              y << "#{ the_only_ }known #{ n 'component' }: #{ buff }"
            end
          end
        end
      end

      def __check_that_we_have_our_special_meta_information_for_this_grammar_symbol

        _ = @grammar_symbols_feature_branch.procure__ _entity_name_symbol, & @listener

        _store :@_structured_node_class, _
      end

      # ~( ##spot1.3: probably has redundancy with this other levenshtein

      def __check_that_name_is_in_list_of_known_grammar_symbols

        fb = @grammar_symbols_feature_branch

        if fb.has_reference__ _entity_name_symbol
          $stderr.puts "ONCE: #{ _entity_name_symbol }"
          ACHIEVED_
        else
          _scn = fb.to_symbolish_reference_scanner_
          __levenshtein_for_entity_name _scn
        end
      end

      def __levenshtein_for_entity_name sym_scn

        _express_parse_error do |y|

          ick_sym = _entity_name_symbol

          _s_a = Home_.lib_.human::Levenshtein.via(
            :item_string, ick_sym.id2name,
            :items, sym_scn,
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

      def _express_parse_error & these_two_p
        __express_error :parse_error do |y|
          these_two_p[ y, self ]
        end
      end

      define_method :__express_error, DEFINITION_FOR_THE_METHOD_CALLED_EXPRESS_ERROR_

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

    class NodeTester_via_TestList_and_StructuredNodeClass___ < Common_::MagneticBySimpleModel

      # implement boolean "test" expressions, eg. to find all method calls
      # in the corpus whose method name is `puts`:
      #
      #     method_call( method_name = 'puts' )
      #
      # (the above is didactic. actual labels for these terms may vary.)
      #
      # we produce a proc that receives document AST nodes and (when the
      # node matches) results in a structured node wrapping that AST
      # node.

      # the whole thing here is we don't create a structured node instance
      # for every node of this type in the corpus. rather we only
      # create it IFF the node matches the selector body (the boolean tests).
      #
      # to implement this we have to access the components of the document
      # AST nodes using those components offsets before we can wrap them
      # in the structured node class (which abstracts away the use of the offsets).

      attr_writer(
        :list_is_AND_list_not_OR_list,
        :structured_node_class,
        :test_list,
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

        _asc = @structured_node_class.dereference_terminal_association__ test_AST.symbol_symbol

        NodeTester_via_Component_and_Test_AST___.call_by do |o|
          o.terminal_association = _asc
          o.test_AST = test_AST
          o.structured_node_class = @structured_node_class
        end
      end
    end

    # ==

    class NodeTester_via_Component_and_Test_AST___ < Common_::MagneticBySimpleModel

      # (as documented in only client, above)

      attr_writer(
        :structured_node_class,
        :terminal_association,
        :test_AST,
      )

      def execute
        send THESE___.fetch @test_AST.comparison_function_name_symbol
      end

      THESE___ = {
        _EQ_: :__node_test_proc_for_simple_value_equality,
      }

      def __node_test_proc_for_simple_value_equality

        mixed_target_value = __prepare_target_value_for_comparison

        component_offset = @terminal_association.offset

        -> n do

          if mixed_target_value == n.children.fetch( component_offset )
            @structured_node_class.via_node_ n
          end
        end
      end

      def __prepare_target_value_for_comparison
        send THESE2___.fetch @terminal_association.type_symbol
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
