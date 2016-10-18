module Skylab::TMX

  class API

    # this has to be able to regress (A) and (B) there's custom syntax
    # to parse. because why not, we have no long-running process, just
    # a shortlived request client.

    class << self

      def call * x_a, & p

        o = self.begin( & p )
        o.argument_scanner = ArgumentScanner___.via_array x_a
        bc = o.to_bound_call
        if bc
          bc.receiver.send bc.method_name, * bc.args, & bc.block
        else
          bc
        end
      end

      def to_didactic_operation_name_stream__
        self.begin._to_didactic_operation_name_stream
      end

      alias_method :begin, :new
      undef_method :new
    end  # >>

    # -

      def initialize & p
        @_emit = p
      end

      attr_writer(
        :argument_scanner,
      )

      def to_bound_call
        if @argument_scanner.no_unparsed_exists
          __when_no_args
        else
          __when_args
        end
      end

      def __when_no_args

        st = _to_didactic_operation_name_stream

        _parse_error_listener.call :error, :expression, :parse_error do |y|

          _any_of_these = say_formal_operation_alternation_ st

          y << "expecting #{ _any_of_these }"
        end

        UNABLE_
      end

      def __when_args

        sym = @argument_scanner.head_as_normal_symbol

        if :map == sym
          @argument_scanner.advance_one
          __when_map
        else
          __when_not_yet
        end
      end

      def __when_not_yet

        x = @argument_scanner.head_as_agnostic

        _parse_error_listener.call :error, :expression, :parse_error do |y|
          y << "currently, normal tmx is deactivated -"
          y << "won't parse #{ say_arguments_head_ x }"
        end
        UNABLE_
      end

      def __when_map

        o = Home_::Operations_::Map.begin( & @_emit )

        o.argument_scanner = @argument_scanner

        Common_::Bound_Call[ nil, o, :execute ]
      end

      def _parse_error_listener
        @_emit || Parse_error_listener___
      end

      def _to_didactic_operation_name_stream
        Stream_.call %w( map BLAH ) do |s|
          Common_::Name.via_slug s
        end
      end
    # -

    # ==

    class ArgumentScanner___

      class << self
        alias_method :via_array, :new
        undef_method :new
      end  # >>

      def initialize x_a
        if x_a.length.zero?
          @no_unparsed_exists = true
        else
          @scn = Common_::Polymorphic_Stream.via_array x_a
        end
      end

      def gets_one_as_is  # same as sibling
        x = @scn.current_token
        advance_one
        x
      end

      def advance_one  # same as sibling
        @scn.advance_one
        @no_unparsed_exists = @scn.no_unparsed_exists
        @_cache_ = nil
      end

      define_singleton_method :cached, DEFINITION_FOR_THE_METHOD_CALLED_CACHED_

      cached :head_as_agnostic do

        x = @scn.current_token
        if x.respond_to? :id2name
          Common_::Name.via_variegated_symbol x
        else
          Common_::Name.via_slug x  # ..
        end
      end

      def head_as_normal_symbol
        @scn.current_token
      end

      attr_reader(
        :no_unparsed_exists,
      )
    end

    # ==

    Parse_error_listener___ = -> *, & expression_p do

      buffer = nil

      p = -> line0 do
        buffer = line
        p = -> line1 do
          buffer = line1.dup
          last_line = line0
          punct_rx = /[-.?!]\z/
          p = -> line do
            if punct_rx !~ last_line
              buffer << '.'  # DOT_
            end
            last_line = line
            buffer << " #{ line }"
          end
          p[ line1 ]
        end
      end

      _y = ::Enumerator::Yielder.new do |line|
        p[ line ]
      end

      ExpressionAgent___.instance.calculate _y, & expression_p

      raise ArgumentError, buffer
    end

    ArgumentError = ::Class.new ::ArgumentError

    class ExpressionAgent___

      class << self
        def instance
          @___instance ||= new
        end
        private :new
      end  # >>

      alias_method :calculate, :instance_exec

      def say_formal_operation_alternation_ st
        _say_name_alternation :__say_formal_operation, st
      end

      def say_primary_alternation_ st
        _say_name_alternation :say_primary_, st
      end

      def _say_name_alternation m, st

        p = method m

        st.join_into_with_by "", " or " do |name|
          p[ name ]
        end
      end

      def __say_formal_operation name
        _same name
      end

      def say_primary_ name
        _same name
      end

      def say_arguments_head_ name
        _same name
      end

      def _same name
        name.as_lowercase_with_underscores_symbol.inspect
      end
    end

    # ==
  end
end
# #history: born for "map" operation
