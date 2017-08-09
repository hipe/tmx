if __FILE__ == $PROGRAM_NAME

  # (hackishly: if this file is invoked from the command line, it allows you
  # to test the parser against any arbitrary string you provide there, to
  # make development easier :#here1.)

  do_run_as_standalone_CLI_program = true
  require 'skylab/beauty_salon'
  Skylab::BeautySalon::CrazyTownMagnetics_.const_get :Selector_via_String, false
end

module Skylab::BeautySalon

  class CrazyTownMagnetics_::Selector_via_String::ParseTree_via_String < Common_::MagneticBySimpleModel

    # -
      def initialize
        yield self  # hi.
        @__mutex_for_etc = nil
      end

      attr_writer(
        :listener,
        :string,
      )

      def execute

        require_relative 'grammar-'  # (can't autoload because #reason1.1)

        # the rest of this is boring stitching - the cost of splitting
        # parsing across two files

        _ok = _generated_grammar_module.call_by do |o|

          o.on_callish_identifier = method :__on_callish_identifier

          o.on_test_identifier = method :__on_test_identifier

          o.on_regex_body = method :__on_regex_body

          o.on_literal_string = method :__on_literal_string

          o.on_is_AND_not_OR = method :__on_is_AND_not_OR

          o.on_true_keyword = method :__on_true_keyword

          o.input_string = remove_instance_variable :@string

          o.on_error_message = method :__on_error_message

          o.listener = @listener

          @_grammar = o  # meh
        end

        case _ok
        when true ; __flush_tree
        when false ; __flush_express_error_messages  # assume some (risky!)
        else never
        end
      end

      def __flush_tree

        _yes = remove_instance_variable :@_true_keyword_was_used
        if ! _yes
          is_AND = remove_instance_variable :@_is_AND_not_OR
          list = remove_instance_variable :@_boolean_tests
        end
        o = SelectorParseTree___.new
          o.list_is_AND_list_not_OR_list = is_AND
          o.list_of_boolean_tests = list
          o.feature_symbol = remove_instance_variable :@__callish_identifier_symbol
        o.freeze
      end

      def __on_callish_identifier s
        @__callish_identifier_symbol = s.intern
      end

      # --

      def __on_regex_body s

        o = RegexpBooleanTest___.new
          o.regexp_body_string = s
          o.symbol_symbol = remove_instance_variable :@_test_identifier_symbol

        _receive_boolean_test o
      end

      def __on_literal_string s

        o = LiteralValueBooleanTest___.new
          o.literal_value = s
          o.symbol_symbol = remove_instance_variable :@_test_identifier_symbol

        _receive_boolean_test o.freeze
      end

      def __on_test_identifier s
        @_test_identifier_symbol = s.intern
      end

      def _receive_boolean_test o
        send ( @_receive_boolean_test ||= :__receive_boolean_test_initally ), o
      end

      def __receive_boolean_test_initally o
        @_true_keyword_was_used = false
        @_is_AND_not_OR = nil  # if the list has one item, this shouldn't matter
        @_boolean_tests = []
        send ( @_receive_boolean_test = :__receive_boolean_test_subsequently ), o
      end

      def __receive_boolean_test_subsequently o
        @_boolean_tests.push o
      end

      # --

      def __on_is_AND_not_OR is_AND
        remove_instance_variable :@__mutex_for_etc
        @_is_AND_not_OR = is_AND
      end

      def __on_true_keyword
        @_true_keyword_was_used = true
      end

      # -- error caching and subsequent expression
      #
      #    (we cache them instead of expressing them outright so we can
      #     do the clever thing of expressing "expecting X or Y or Z")

      def __on_error_message msg

        _d = @_grammar.current_position_
        _err = ErrorAtPostion___.new _d, msg
        send ( @_receive_error_message ||= :__receive_initial_error_message ), _err
      end

      def __receive_initial_error_message err
        @_errors = []
        send ( @_receive_error_message = :__receive_subsequent_error_message ), err
      end

      def __receive_subsequent_error_message err
        @_errors.push err
      end

      def __flush_express_error_messages  # assume some

        me = self
        _err_a = remove_instance_variable :@_errors
        @listener.call :expression, :error, :parse_error do |y|
          me.__do_express_error_messages y, _err_a
        end
        UNABLE_
      end

      def __do_express_error_messages y, err_a   # assume some

        err_st = Stream_[ err_a ]
        err = nil
        leftmost_column = nil
        rightmost_column = nil

        see_offset_normally = -> do
          d = err.offset
          if d < leftmost_column
            leftmost_column = d
          elsif d > rightmost_column
            rightmost_column = d
          end
        end

        see_offset = -> do
          see_offset = see_offset_normally
          leftmost_column = err.offset
          rightmost_column = err.offset
        end

        message_buffer = nil

        do_see_subsequent_message = -> object_s do
          message_buffer << " or " << object_s
        end

        do_see_message = -> object_s do
          do_see_message = do_see_subsequent_message
          message_buffer = "expecting #{ object_s }"
        end

        see_message = -> do
          msg = err.message
          md = /\Aexpecting /.match msg
          if ! md
            self._COVER_ME__did_not_match_regexp__
          end
          do_see_message[ md.post_match ]
        end

        begin
          err = err_st.gets
          err || break
          see_offset[]
          see_message[]
          redo
        end while above

        message_buffer << ':'  # COLON_


        if leftmost_column == rightmost_column
          offset = leftmost_column
        else
          self._COVER_ME__OK_but_we_are_not_expecting_this__
        end

        me = self

          input_s = me.__get_original_string

        y << message_buffer

          buffer = '  '  # also margin

          y << "#{ buffer }#{ input_s }"

        buffer << ( DASH_ * offset )
          buffer << '^'

          y << buffer
        # -
      end

      ErrorAtPostion___ = ::Struct.new :offset, :message

      def __get_original_string

        # (the original string is (or was) in fact sitting there ia one of
        # our ivars. so this is just something of a contact exercise..)

        d_a = @_grammar.THE_data
        d_a.last.zero? || fail
        d_a[ 0 ... -1 ].pack _generated_grammar_module::C_STAR
      end

      # --

      def _generated_grammar_module
        ::Skylab__BeautySalon::CrazyTownMagnetics___Selector_via_String__Grammar_
      end

    # -

    # ==

    SelectorParseTree___ = ::Struct.new(
      :list_is_AND_list_not_OR_list,
      :list_of_boolean_tests,
      :feature_symbol,
    )

    RegexpBooleanTest___ = ::Struct.new(
      :regexp_body_string,
      :symbol_symbol,
    ) do
      def comparison_function_name_symbol
        :_RX_
      end
    end

    LiteralValueBooleanTest___ = ::Struct.new(
      :literal_value,
      :symbol_symbol,
    ) do
      def comparison_function_name_symbol
        :_EQ_
      end
    end

    # ==
    # ==
  end
end

if do_run_as_standalone_CLI_program  # (see #here1)

  argv = ::ARGV ; serr = $stdout

  if 1 == argv.length && /\A--?h(?:e(?:l(?:p)?)?)?\z/ !~ argv[0]

    y = ::Enumerator::Yielder.new do |s|
      serr.puts s  # (hi.)
    end

    _listener = -> * sym_a, & em_p do
      :expression == sym_a.first || fail
      nil.instance_exec y, & em_p
    end

    x = Skylab::BeautySalon::CrazyTownMagnetics_::Selector_via_String::ParseTree_via_String.call_by do |o|
      o.string = argv.fetch 0
      o.listener = _listener
    end

    if x
      serr.puts "(succeeded? #{ x.my_inspect_ })"
      es = 0
    else
      serr.puts "(parsing apparently failed (got #{ x.inspect }))"
      es = 5
    end
  else
    serr.puts "usage: #{ $PROGRAM_NAME } <input-string>"
    es = 5
  end
  exit es
end

# #born.
