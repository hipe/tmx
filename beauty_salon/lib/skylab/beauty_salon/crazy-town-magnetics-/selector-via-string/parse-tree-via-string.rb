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
      end

      attr_writer(
        :listener,
        :string,
      )

      def execute

        require_relative 'grammar-'  # (can't autoload because #spot1.3)

        # the rest of this is boring stitching - the cost of splitting
        # parsing across two files

        _ok = _generated_grammar_module.call_by do |o|

          o.on_callish_identifier = method :__on_callish_identifier

          o.on_error_message = method :__on_error_message

          o.on_true_keyword = method :__on_true_keyword

          o.input_string = remove_instance_variable :@string

          o.listener = @listener

          @_grammar = o  # meh
        end

        case _ok
        when true ; __flush_tree
        when false ; UNABLE_
        else never
        end
      end

      def __flush_tree

        _yes = remove_instance_variable :@_true_keyword_was_used
        if ! _yes
          la_la_la
          is_AND = nil
          list = nil
        end
        o = SelectorParseTree___.new
          o.list_is_AND_list_not_OR_list = is_AND
          o.list_of_boolean_tests = list
          o.feature_symbol = remove_instance_variable :@__callish_identifier_symbol
        o.freeze
      end

      def __on_callish_identifier wat_s
        @__callish_identifier_symbol = wat_s.intern
      end

      def __on_true_keyword
        @_true_keyword_was_used = true
      end

      def __on_error_message msg

        g = @_grammar ; me = self

        @listener.call :expression, :error, :parse_error do |y|

          input_s = me.__get_original_string

          y << "#{ msg }:"

          buffer = '  '  # also margin

          y << "#{ buffer }#{ input_s }"

          buffer << ( DASH_ * g.current_position_ )
          buffer << '^'

          y << buffer
        end
      end

      def __get_original_string

        # (the original string is (or was) in fact sitting there ia one of
        # our ivars. so this is just something of a contact exercise..)

        d_a = @_grammar.THE_data
        d_a.last.zero? || fail
        d_a[ 0 ... -1 ].pack _generated_grammar_module::C_STAR
      end

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

    BooleanTest___ = ::Struct.new :literal_value, :symbol_symbol, :comparison_function_name_symbol

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
