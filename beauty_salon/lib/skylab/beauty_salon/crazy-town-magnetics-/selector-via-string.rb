# frozen_string_literal: true

module Skylab::BeautySalon

  class CrazyTownMagnetics_::Selector_via_String < Common_::MagneticBySimpleModel

    # ==

    class Selector___

      def initialize gsm, list, sym
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

        _ = ParseTree_via_String.call_by do |o|
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

    # -
      DEF_FOR_METH_CALLED_ETC_ = -> tok do  # "maybe parse this token"

        len = tok.length  # ick/meh
        actual_s = @_scn.peek len
        if actual_s == tok
          @_scn.pos += len
          ACHIEVED_
        end
      end
    # -

    class ParseTree_via_String < Common_::MagneticBySimpleModel

      # this follows exactly [#041] fig. 1.

      attr_writer(
        :string,
        :listener,
      )

      def execute
        @_scn = Home_.lib_.string_scanner.new remove_instance_variable :@string
        ok = __parse_feature_name_symbol
        ok &&= __parse_open_parens
        ok && __init_AND_list_of_boolean_tests
        while ok
          ok = __parse_component_name
          ok &&= __parse_boolean_binary_operator
          ok &&= __parse_double_quoted_string
          ok && __process_boolean_test
          ok || break
          _did = __maybe_parse_boolean_and
          _did ? redo : break
        end
        ok &&= __parse_close_parens
        ok &&= __expect_no_more_tokens
        ok && __flush
      end

      def __flush
        SelectorParseTree___.new(
          remove_instance_variable( :@_AND_list_of_boolean_tests ),
          remove_instance_variable( :@__feature_name_symbol ),
        )
      end

      # --

      def __process_boolean_test

        _comp_sym = remove_instance_variable :@__component_name_symbol
        _x = remove_instance_variable :@__last_literal_value
        _op_sym = remove_instance_variable :@_boolean_binary_operator

        _test = BooleanTest___.new _x, _comp_sym, _op_sym
        @_AND_list_of_boolean_tests.push _test ; NIL
      end

      def __init_AND_list_of_boolean_tests
        @_AND_list_of_boolean_tests = [] ; nil
      end

      # --

      def __expect_no_more_tokens
        if @_scn.eos?
          ACHIEVED_
        else
          _express_parse_error_contextualized do
            "expecting end of string"
          end
        end
      end

      def __maybe_parse_boolean_and
        _consume_any_whitespace
        if _maybe_parse_this_token '&&'
          # (ignored)
          @__BOOLEAN_OPERATOR_SYMBOL = :_AND_ ; ACHIEVED_
        end
      end

      def __parse_double_quoted_string
        _consume_any_whitespace
        ok = _parse_this_token '"'
        ok && __parse_the_rest_of_a_double_quoted_string_complicatedly
      end

      def __parse_the_rest_of_a_double_quoted_string_complicatedly

        ok = true
        buffer = ::String.new
        begin
          _yes = @_scn.skip %r(")
          _yes && break
          did = false
          s = @_scn.scan %r([^"\\]+)
          if s
            buffer << s
            did = true
          end
          if @_scn.skip %r(\\)
            ok = __parse_double_quote_for_string_ending
            ok || break
            buffer << '"'
            did = true
          end
          did && redo
          @_scn.eos? || interesting
          _express_parse_error_contextualized { "string is still open" }
          ok = false ; break
        end while above
        if ok
          @__last_literal_value = buffer
        end
        ok
      end

      def __parse_double_quote_for_string_ending
        _parse_this_token '"'
      end

      def __parse_component_name
        _consume_any_whitespace
        _parse_a_symbol_commonly :@__component_name_symbol
      end

      def __parse_feature_name_symbol
        _parse_a_symbol_commonly :@__feature_name_symbol
      end

      def __parse_boolean_binary_operator

        _consume_any_whitespace

        _parse_one_of_these do |o|
          if o.maybe_parse_this_token '=='
            @_boolean_binary_operator = :_EQ_ ; ACHIEVED_
          elsif o.maybe_parse_this_token '=~'
            @_boolean_binary_operator = :_EQ_ ; ACHIEVED_
          end
        end
      end

      def __parse_open_parens
        _parse_this_token '('
      end

      def __parse_close_parens
        _parse_this_token ')'
      end

      # --

      def _parse_one_of_these
        o = InefficientRecordingJobber___.new @_scn
        _yes = yield o
        if _yes
          ACHIEVED_
        else
          _express_parse_error_contextualized do
            "expecting #{ o.tried_tokens.map { |s| %("#{ s }") } * ' or ' }"
          end
        end
      end

      def _parse_a_symbol_commonly ivar
        s = _maybe_parse_this_regex %r([a-z][a-z0-9]*(?:_[a-z0-9]+)*)
        if s
          instance_variable_set ivar, s.intern ; ACHIEVED_
        else
          _clever_hack_for_error_message
        end
      end

      def _maybe_parse_this_regex rx
        @_scn.scan rx
      end

      def _parse_this_token s
        if _maybe_parse_this_token s
          ACHIEVED_
        else
          _clever_hack_for_error_message
        end
      end

      def _consume_any_whitespace
        @_scn.skip %r([ ]+)  # tabs meh
        NIL
      end

      def _clever_hack_for_error_message

        _loc = caller_locations( 2, 1 ).fetch 0

        moniker = _loc.base_label.match( /\A_*parse_/ ).post_match.
          gsub UNDERSCORE_, SPACE_

        _express_parse_error_contextualized do
          "expecting #{ moniker }"
        end
      end

      def _express_parse_error_contextualized

        if @_scn.eos?
          is_eos = true
        else
          str = @_scn.string
          pos = @_scn.pos
        end

        @listener.call :error, :expression, :parse_error do |y|

          head = yield

          if is_eos
            y << "#{ head } at end of input"
          else
            y << "#{ head }:"
            y << "    #{ str }"
            y << "    #{ DASH_ * pos }^"
          end
        end

        UNABLE_
      end

      define_method :_maybe_parse_this_token, DEF_FOR_METH_CALLED_ETC_
    end

    # ==

    SelectorParseTree___ = ::Struct.new :AND_list_of_boolean_tests, :feature_symbol

    BooleanTest___ = ::Struct.new :literal_value, :symbol_symbol, :comparison_function_name_symbol

    # ==

    class InefficientRecordingJobber___

      def initialize scn
        @tried_tokens = []
        @_scn = scn
      end

      def maybe_parse_this_token tok
        @tried_tokens.push tok
        __maybe_parse_this_token tok
      end

      define_method :__maybe_parse_this_token, DEF_FOR_METH_CALLED_ETC_

      attr_reader(
        :tried_tokens,
      )
    end

    # ==
    # ==
  end
end
# born.
