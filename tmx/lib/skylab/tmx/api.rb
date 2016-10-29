module Skylab::TMX

  class API

    # this has to be able to regress (A) and (B) there's custom syntax
    # to parse. because why not, we have no long-running process, just
    # a shortlived request client.

    class << self

      def call * x_a, & p

        o = self.begin( & p )
        o.argument_scanner = Zerk_[]::API::ArgumentScanner.via_array x_a, & p
        bc = o.to_bound_call_of_operator
        if bc
          bc.receiver.send bc.method_name, * bc.args, & bc.block
        else
          bc
        end
      end

      def to_didactic_operation_name_stream__
        To_didactic_operation_name_stream__[]
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

      def to_bound_call_of_operator
        if @argument_scanner.no_unparsed_exists
          __when_no_args
        else
          __when_args
        end
      end

      def __when_no_args

        st = To_didactic_operation_name_stream__[]

        _parse_error_listener.call :error, :expression, :parse_error do |y|

          _any_of_these = say_formal_operation_alternation_ st

          y << "expecting #{ _any_of_these }"
        end

        UNABLE_
      end

      def __when_args

        sym = @argument_scanner.head_as_normal_symbol

        bx = Operations_name_cache__[]

        name = bx.h_[ sym ]
        if name
          @argument_scanner.advance_one
          __when_operation_found name
        else
          __when_operation_not_found bx
        end
      end

      def __when_operation_not_found bx

        x = @argument_scanner.head_as_strange_name

        _parse_error_listener.call :error, :expression, :parse_error do |y|

          y << "unknown operation #{ say_strange_arguments_head_ x }"

          _st = bx.to_value_stream

          y << "available operations: #{ say_formal_operation_alternation_ _st }"
        end
        UNABLE_
      end

      def __when_operation_found name

        _const = name.as_camelcase_const_string.intern

        _operation_class = Home_::Operations_.const_get _const, false

        o = _operation_class.begin( & @_emit )

        o.argument_scanner = @argument_scanner

        @operation_session = o  # experiment

        Common_::Bound_Call[ nil, o, :execute ]
      end

      def _parse_error_listener
        @_emit || Parse_error_listener___
      end

      attr_reader(
        :operation_session,
      )
    # -

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

      Zerk_[]::API::ArgumentScannerExpressionAgent.instance.
        calculate _y, & exp_p

      raise ArgumentError, buffer
    end

    ArgumentError = ::Class.new ::ArgumentError

    # ==

    To_didactic_operation_name_stream__ = -> do
      Operations_name_cache__[].to_value_stream
    end

    Operations_name_cache__ = Lazy_.call do
      Box_via_autoloaderized_module_[ Home_::Operations_ ]
    end

    # ==
  end
end
# #history: born for "map" operation
