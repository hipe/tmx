module Skylab::CodeMetrics

  class Operations_::Mondrian

    class CLI

      def initialize * five, ick

        @_did_err = false
        @_send_exitstatus = ick

        five[ -1 ] = [ * five.last, 'mondrian' ]  # meh
        @ARGV, @stdin, @stdout, @stderr, @program_name_string_array = five
      end

      def to_bound_call_of_operator
        if __help_is_requested
          __express_help
        else
          __init_listener_and_argument_scanner_and_boogey_down
        end
      end

      def __help_is_requested
        a = @ARGV
        if a.length.nonzero?
          rx = /\A--?h(?:e(?:l(?:p)?)?)?\z/
          rx =~ a.first || 1 < a.length && rx =~ a.last
        end
      end

      def __init_listener_and_argument_scanner_and_boogey_down

        @listener = method :__receive_emission

        _real_arg_scn = Common_::Polymorphic_Stream.via_array(
          remove_instance_variable( :@ARGV )
        )

        Zerk_lib_[]

        arg_scn = Zerk_::NonInteractiveCLI::MultiModeArgumentScanner.define do |o|

          o.user_scanner _real_arg_scn

          o.default_primary :path

          # o.subtract_primary :foo, _bar

          o.emit_into @listener
        end

        _op = Operation___.new arg_scn

        @__expag = arg_scn.expression_agent

        bc = _op.to_bound_call_of_operator
        if bc
          bc
        else
          Common_::Bound_Call[ nil, self, :__no_op ]
        end
      end

      def __no_op  # #waiting for [#010]
        if @_did_err
          @_send_exitstatus[ 3092 ]
          NIL  # false or nil all the same
        else
          ACHIEVED_
        end
      end

      def __receive_emission * chan, & msg_p

        :expression == chan.fetch(1) || fail

        case chan[0]
        when :error
          @_did_err = true
          io = @stderr
        when :info
          io = @stderr
        else fail
        end

        _y = ::Enumerator::Yielder.new do |line|
          io.puts line
        end

        @__expag.calculate _y, & msg_p

        NIL
      end
    end

    # ==

    Operation___ = self
    class Operation___

      def initialize scn
        @_args = scn

        @path = nil
      end

      def to_bound_call_of_operator
        if __parse_arguments
          Common_::Bound_Call[ nil, self, :execute ]
        end
      end

      def __parse_arguments
        if __do_parse_arguments
          __check_for_missing_requires
        end
      end

      def __check_for_missing_requires
        if @path
          ACHIEVED_
        else
          @_args.listener.call :error, :expression, :primary_parse_error do |y|
            y << "missing required parameter: #{ prim :path }"
          end
          UNABLE_
        end
      end

      def __do_parse_arguments
        matcher = @_args.matcher_for :primary, :against_hash, OPTIONS___
        ok = true
        until @_args.no_unparsed_exists
          ok = matcher.gets
          ok || break
          @_args.advance_one
          ok = send ok.branch_item_value
          ok || break
        end
        ok
      end

      OPTIONS___ = {
        path: :__parse_path,
        ping: :__parse_ping,
        const: :__parse_const,
      }

      def __parse_ping
        @_args.listener.call :info, :expression, :ping do |y|
          y << "hello from mondrian"
        end
        NIL
      end

      def __parse_path
        _store :@path, @_args.parse_primary_value( :must_be_trueish )
      end

      # --

      def execute
        @_mags = Home_::Magnetics
        ok = true
        ok &&= _store :@__tree_data, __tree_data_via_path
        ok &&= _store :@__shapes_layers, __shapes_layers_via_tree_data
        ok &&= __express_ascii_matrix_via_shapes_layers
        ok
      end

      def __express_ascii_matrix_via_shapes_layers
        _sl = remove_instance_variable :@__shapes_layers
        st = @_mags::AsciiMatrix_via_ShapesLayers[ _sl ]
        if st
          # ..
          st
        end
      end

      def __shapes_layers_via_tree_data
        remove_instance_variable :@__tree_data
        :_shapes_layers_stub_
      end

      def __tree_data_via_path
        remove_instance_variable :@path
        :_tree_data_stub_
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
    end

    # ==
  end
end
# #born
