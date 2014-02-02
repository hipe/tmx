module Skylab::GitViz

  module Test_Lib_::Mock_System

    class Fixture_Client  # [#024] taste the pain of too much docs

      Mock_System::Plugin_::Host[ self ]
      Mock_System::Socket_Agent_[ self ]
      include Socket_Agent_Constants_

      x = $VERBOSE ; $VERBOSE = nil ; GitViz::Lib_::ZMQ[] ; $VERBOSE = x

      def initialize program_name, sout, argv, port_d
        @argv = argv
        @poll_timeout_milliseconds = 1000
        @port_d = port_d
        @program_name = program_name
        @stdout = sout
        @tried_to_connect_with_plugins = false
        init_info_yielder
      end

    private

      def init_info_yielder
        @y = ::Enumerator::Yielder.new do |msg|
          msg.chomp!
          emit_info_string msg
        end
      end

      plugin_conduit_class
      class Plugin_Conduit
        GRAPHIC_PREFIX__ = nil
        def agent_prefix  # because our output needs to look CSV-esque,
          "#{ super }plugin "  # ..dont use graphics or indenting
        end
      end

      callbacks = build_mutable_callback_tree_specification
      callbacks << :on_build_option_parser

      def write_plugin_host_option_parser_options
        # currently all options exist only in the plugins
      end

      def write_plugin_host_option_parser_help_option
        @op.on '--help','this screen.' do
          @y << "usage: #{ ::File.basename $PROGRAM_NAME } [opts] -- [request]"
          @y << "options:"
          @op.summarize @y
          @result_code = EARLY_EXIT_
        end
      end

    public

      def invoke
        ec = load_plugins
        ec ||= parse_parameters
        ec ||= establish_connection
        ec || execute_with_connection
      end

    private

      def parse_parameters
        ec = parse_options
        ec || parse_arguments
      end

      def parse_arguments
        # let all pass thru to nextstream
      end

      def parse_options
        @result_code = PROCEDE_
        @op.parse!
        @result_code
      rescue ::OptionParser::ParseError => e
        emit_error_string e.message
        EARLY_EXIT_
      end

      def establish_connection
        resolve_context_and_bind_request_socket do |sckt|
          sckt.setsockopt ::ZMQ::LINGER, 0
        end
      end

      def execute_with_connection
        ec = init_poller_and_register_socket
        ec ||= send_request
        ec ||= poll_for_response
        ec_ = cleanup
        ec_ and ec.zero? and ec = ec_
        ec
      end

      def init_poller_and_register_socket
        @poller = ::ZMQ::Poller.new
        d = @poller.register @socket, ::ZMQ::POLLIN
        if 1 != d
          emit_error_string "expected 1, had #{ d } for registering poller"
          GENERAL_ERROR_
        end
      end

      def send_request
        send_strings @argv
      end

      def poll_for_response
        ec = poller_is_ready
        ec ||= do_the_polling
        ec || process_the_response_of_the_polling
      end

      def poller_is_ready
        if @poller.size.zero?
          emit_error_string "no items are being polled."
          GENERAL_ERROR_
        end
      end

      def do_the_polling
        begin
          @poll_again = false
          r = do_the_polling_once
        end while @poll_again
        r
      end

      def do_the_polling_once
        d = @poller.poll @poll_timeout_milliseconds
        case d
        when -1 ; when_ZMQ_error
        when  0 ; when_the_poll_indicates_no_readable_or_writable_sockets
        else    ; when_the_poll_indicates_N_number_of_ready_sockets d
        end
      end

      def when_the_poll_indicates_no_readable_or_writable_sockets
        if @tried_to_connect_with_plugins
          when_the_poll_indicates_no_sockets_and_tried_plugins_already
        else
          try_to_connect_with_plugins
        end
      end

      def when_the_poll_indicates_no_sockets_and_tried_plugins_already
        emit_error_string say_timeout_expired
        NO_SERVER_
      end

      def say_timeout_expired
        "no response from server after #{ timeout_s }#{
          } - is the server running? (try starting it with '#{
           }#{ path_to_fixture_server }' in a different terminal window)"
      end

      def timeout_s
        secs = @poll_timeout_milliseconds * 1.0 / 1000
        secs_d = secs.to_i
        1.0 == secs or s = 's'
        "#{ secs_d == secs ? secs_d : secs } second#{ s }"
      end

      def path_to_fixture_server
        GitViz::Test::Script.dir_pathname.join( 'fixture-server' ).to_path
      end

      def try_to_connect_with_plugins
        @tried_to_connect_with_plugins = true
        new_timeout_seconds = attempt_with_plugins :on_attempt_to_connect
        if new_timeout_seconds
          if new_timeout_seconds.respond_to? :to_f
            @poll_again = true
            @poll_timeout_milliseconds = new_timeout_seconds * 1000
            @y << "will try connecting again for plugin, #{
              }this time with a timeout of #{ timeout_s }.."
            PROCEDE_
          else
            @y << "expected floating point number, but some plugin resulted #{
              }in #{ GitViz::Lib_::Ick[ new_timeout_seconds ] }"
            NO_SERVER_
          end
        else
          emit_error_string say_could_not_connect_with_plugins
          NO_SERVER_
        end
      end
      callbacks.shorters :on_attempt_to_connect

      def say_could_not_connect_with_plugins
        "no response from server after #{ timeout_s } (tried connecting #{
        }with plugins). nothing else to try."
      end

      def when_the_poll_indicates_N_number_of_ready_sockets d
        if 1 != d
          emit_error_string "when is this ever not one? #{ d }"
          GENERAL_ERROR_
        end
      end

      def process_the_response_of_the_polling
        d = @socket.recv_strings( a = [] )
        if 0 > d
          report_and_result_in_socket_recv_failure
        else
          Re_Marshaller_.
            new( build_internal_dispatching_listener, a ).remarshall
        end
      end

      def cleanup
        rc = deregister_socket_from_poller
        rc_ = close_socket
        rc || rc_
      end

      def deregister_socket_from_poller
        x = @poller.deregister @socket, ::ZMQ::POLLIN
        if true != x
          emit_error_string "expected 'true' had #{ x } for deregister"
          GENERAL_ERROR_
        end
      end

      def build_internal_dispatching_listener
        Dispatching_Listener__.new do |dl|
          dl[ :debug ][ :string ] = method :emit_debug_string
          dl[ :info ][ :string ] = method :emit_info_string
          dl[ :info ][ :iambic ][ :argv_tail ] =
            method :emit_argv_tail_info_iambic
          dl[ :notice ][ :string ] = method :emit_notice_string
          dl[ :error ][ :string ] = method :emit_error_string
          dl[ :error ][ :iambic ][ :manifest_parse ] =
            method :emit_manifest_parse_error_iambic
          dl[ :payload ][ :iambic ][ :command ] =
            method :emit_command_payload_iambic
        end
      end

      def emit_debug_string s
        emit_row :debug, s
      end

      def emit_info_string s
        emit_row :info, s
      end

      def emit_argv_tail_info_iambic a
        emit_row :info, :iambic, :normalized_request, * a
      end

      def emit_notice_string s
        emit_row :notice, s
      end

      def emit_error_string s
        emit_row :error, s
      end

      def emit_manifest_parse_error_iambic a
        pe = Mock_System::Manifest_::Parse_Error.new a
        emit_row :error, "#{ pe.message }: #{ pe.path }"
        pe.render_ascii_graphic_location_lines do |s|
          s.chomp!
          emit_row :ascii_graphic, s
        end
      end

      def emit_command_payload_iambic a
        cmd = Command__.new
        a.each_slice( 2 ) do |k, v|
          cmd[ k ] = v
        end
        emit_row :payload, :fixed_width, :command, * cmd.to_a
      end
      Command__ = ::Struct.new :command, :cd_relpath,
        :any_stdout_path, :any_stderr_path, :result_code_x,
        :marshalled_freetags

      def emit_row * x_a
        @stdout.write "#{ x_a * "\t" }\n"
      end

      Callback_Tree__ = callbacks.flush
    end

    class Fixture_Client::Re_Marshaller_

      def initialize listener, a
        @a = a ; @rc_a = [] ; @listener = listener
      end

      def remarshall
        begin
          send :"#{ @a.shift }="
        end while @a.length.nonzero?
        flush
      end
    private
      def result_code=
        d = @a.shift.to_i
        if d.nonzero? or ! @rc_a.include? 0
          @rc_a << d
        end ; nil
      end
      def statement=
        @len_ = @a.shift.to_i
        @a_ = @a.shift @len_
        uniform_statement_processing_grammar
      end
      def uniform_statement_processing_grammar
        send :"when_#{ 2 < @len_ ? :many : @len_ }_fields"
      end
      def when_2_fields
        chan_i = @a_.first.intern ; x = @a_.last
        @listener.call chan_i, :string do x end ; nil
      end
      def when_many_fields
        chan_i = @a_.shift.intern ; shape_i = @a_.shift.intern
        form_i = @a_.shift.intern ; rest_a = @a_ ; @a_ = nil
        @listener.call chan_i, shape_i, form_i do rest_a end ; nil
      end
      def flush
        case @rc_a.length <=> 1
        when -1 ; when_no_result_codes
        when  0 ; when_one_result_code
        when  1 ; when_multiple_result_codes
        end
      end
      def when_one_result_code
        d = @rc_a.first
        emit_debug_string do
          "the backend gave result code '#{ d }'"
        end
        @rc_a.first
      end
      def when_no_result_codes
        emit_debug_string do
          "strange, got no result code from backend."
        end
        Fixture_Client::SUCCESS_
      end
      def when_multiple_result_codes
        emit_debug_string do
          "got a variety of nonzero result codes from backend, result is #{
            }first nonozero code among them. had: (#{ @rc_a * ', ' })"
        end
        @rc_a.detect( & :nonzero? ) or self.___logic_error___
      end
      def emit_debug_string & p
        @listener.call :debug, :string, & p ; nil
      end
    end

    class Fixture_Client::Dispatching_Listener__

      def initialize
        p = -> do
          ::Hash.new { |h, k| h[ k ] = p[] }
        end
        yield( @h = p[] ) ; nil
      end
      def call * i_a
        _p = i_a.reduce @h do |m, i|
          m.fetch( i ) { } or raise ::KeyError, say_no_callback( i, i_a )
        end
        _p.call yield
      end

      def say_no_callback i, i_a
        "bad channel path #{ i_a.inspect } - no callback registered for '#{i}'"
      end
    end

    class Fixture_Client  # (re-open)

      NO_SERVER_ = 25
      SUCCESS_ = 0 ; ZMQ_ERROR_CODE_ = -1

    end
  end
end
