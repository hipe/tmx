module Skylab::GitViz

  module Test_Lib_::Mock_System

    class Fixture_Server

      class Prepare_ < Response_Agent_

        Fixture_Server::Isomorphic_Interface_[ self,
          :use, :option_parser_methods,
          :required, :argument, :chdir_prefix_white_filter,
          :required, :accumulating, :argument, :command_white_filter_regex,
          :required, :argument, :manifest_path ]

        include Socket_Agent_Constants_  # error codes

        def initialize y, s_a, callbacks, response
          @argv = s_a  # #hook-out
          @callbacks = callbacks
          super y, response
        end

        def prepare
          ec = parse_options
          ec ||= resolve_extra_args
          ec ||= resolve_missing_args
          ec || echo_back_command
          ec || [ nil, build_some_request ]
        end

      private

        def resolve_extra_args
          if PING__ == @argv
            ping
          else
            super
          end
        end ; PING__ = %w( ping ).freeze

        def ping
          @response.add_iambicly_structured_statement :info,
            "the fixture server responder says 'hello' in response to your ping"
          EARLY_EXIT_
        end

        def emit_error_string s  # #hook-out
          @response.add_iambicly_structured_statement :error, s ; nil
        end

        def emit_info_string s
          @response.add_iambicly_structured_statement :info, s ; nil
        end

        def echo_back_command
          s_a = get_reconstruct_invocation_argv
          @response.add_iambicly_structured_statement :info, :iambic,
            :argv_tail, * s_a ; nil
        end

        def build_some_request
          Request__.new( * resolve_some_formal_parameter_a.map do |p|
            instance_variable_get p.ivar
          end )
        end

        Request__ = ::Struct.new( *
          PARAM_I_A__.map( & method( :send ) ).
            map( & :attr_reader_method_name) )
      end
    end
  end
end