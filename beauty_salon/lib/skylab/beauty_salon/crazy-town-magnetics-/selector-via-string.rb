# frozen_string_literal: true

module Skylab::BeautySalon

  class CrazyTownMagnetics_::Selector_via_String < Common_::MagneticBySimpleModel

    # ==

    class Selector___

      def initialize gsm, list, sym
        self._NEEDS_CLEANUP
        @AND_list_of_boolean_tests = list
        @feature_symbol = sym
        @grammar_symbol_module = gsm
      end

      def on_each_occurrence_in writable_hooks_plan, & receive_wrapped_sexp

        test_sexp = @grammar_symbol_module.__write_sexp_tester_ @AND_list_of_boolean_tests

        writable_hooks_plan.on_this_one_kind_of_sexp__ @feature_symbol do |s|

          wrapped = test_sexp[ s ]
          if wrapped
            receive_wrapped_sexp[ wrapped ]
          end
        end

        NIL
      end

      attr_reader(
        :AND_list_of_boolean_tests,
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
            remove_instance_variable( :@_grammar_symbol_module ),
            t.AND_list_of_boolean_tests,
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
        h = @_grammar_symbol_module::COMPONENTS
        @_tree.AND_list_of_boolean_tests.each do |bool_test|
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
        k = _entity_name_symbol
        c = Common_::Name.via_variegated_symbol( k ).as_camelcase_const_string
        mod = These___
        if mod.const_defined? c, false
          @_grammar_symbol_module = mod.const_get c, false
          ACHIEVED_
        else
          __levenshtein_for_metafied do
            mod.constants.map { |cc| Common_::Name.via_const_symbol( cc ).as_variegated_symbol }
          end
        end
      end

      def __levenshtein_for_metafied

        _express_parse_error do |y|

          ick_sym = _entity_name_symbol

          _sym_a = yield

          _s_a = _sym_a.map { |sym| "'#{ sym }'" }

          y << %(currently we don't yet have metadata for grammar symbol '#{ ick_sym }'.)
          y << "(currently we have it for #{ Common_::Oxford_and[ _s_a ] }.)"
        end
      end

      def __check_that_name_is_in_list_of_known_grammar_symbols

        h = CrazyTownMagnetics_::Hooks_via_HooksDefinition::GRAMMAR_SYMBOLS
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

    module These___

      # ~

      class Call

        COMPONENTS = {
          method_name: :_xxx,
        }

        # ~ ( NOTE - this is a VERY rough proof of concept hack
        #
        #   - imagine a `true` primary instead (`call(true)` instead of
        #     `call(method_name="xx")`. imagine how that would look
        #
        #   - most of this should be abstracted out of this one thin subclass
        #
        # :#here-1

        def self.__write_sexp_tester_ and_list

          1 == and_list.length || self._HAVE_FUN__etc__
          test_tree = and_list.fetch 0

          :_EQ_ == test_tree.comparison_function_name_symbol || self._NOT_YET_IMPLEMENTED__regex_etc__
          :method_name == test_tree.symbol_symbol || self._NO_OTHER_COMPONENTS_YET_IMPLEMENTED_

          target_method_name_sym = test_tree.literal_value.intern

          -> s do

            # NOTE we don't create a wrapped sexp out of every (in this case)
            # method call in the corpus. rather, we only create the wrap IFF
            # the grammar symbol instance matches the selector (and in so
            # doing, becomes a "feature")) the cost of this is - do we really
            # wanna etc? think .. think .. NOTE

            _yes = target_method_name_sym == s.fetch( 2 )  # the thing.
            if _yes
              new s
            end
          end
        end

        # ~ )

        def initialize s
          @sexp = s
        end

        # ~ ( ##here-1

        def begin_lineno__

          # experimentally the beginning line number of the sexp is the
          # beginning line number of its root node (which we expect to be fine)

          @sexp.line
        end

        def end_lineno__

          # we don't cache this only because of how the method is used. WATCH THIS

          End_line_number_recursive__[ @sexp ]  # (see comment here)
        end

        # ~ )

        attr_reader(
          :sexp,
        )
      end

      # ~
    end

    # ==

    End_line_number_recursive__ = -> s do

      # NOTE this approach is fundamentally flawed as explained at
      # [#042.B] the problem with finding ending line numbers. as
      # an experiment we're trying it anyway because we think that at
      # least this will tell us what we want to know (if the feature
      # is multi-line)

      offset_of_rightmost_sexp = nil

      1.upto( s.length - 1 ) do |d|
        x = s.fetch d
        x || next  # "holes" like the `else` slot of an `if` node
        x.respond_to? :sexp_type or next
        offset_of_rightmost_sexp = d
      end

      if offset_of_rightmost_sexp
        End_line_number_recursive__[ s.fetch offset_of_rightmost_sexp ]
      else
        s.line
      end
    end

    # ==

    # ==

    # ==

    # ==

    Here_ = self

    # ==
    # ==
  end
end
# #history-A.2: finish the bulk of the work of transition to ragel (for parsing selectors)
# #history-A.1: begin rewrite to use ragel
# born.
