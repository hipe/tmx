# frozen_string_literal: true

module Skylab::BeautySalon

  class CrazyTownMagnetics_::Selector_via_String

    # -
    # -

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
        Selector___.new(
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
        s = _maybe_parse_this_regex %r([a-z]+(?:_[a-z]+)*)
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

    Selector___ = ::Struct.new :AND_list_of_boolean_tests, :feature_symbol

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
