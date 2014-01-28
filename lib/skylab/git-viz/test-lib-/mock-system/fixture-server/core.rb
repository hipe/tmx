module Skylab::GitViz

  module Test_Lib_::Mock_System

    class Fixture_Server  # read [#018]:#introduction-to-the-middle-end

      Mock_System::Plugin_::Host[ self ]
      Mock_System::Socket_Agent_[ self ]

      def initialize serr, port_d, argv
        @argv = argv
        @buffer_a = []
        @is_running = false
        @serr = serr
        @port_d = port_d
        @y = ::Enumerator::Yielder.new( & serr.method( :puts ) )
      end

      def run
        ec = load_plugins
        ec ||= parse_parameters
        ec ||= init_responder
        ec ||= resolve_context
        ec ||= resolve_and_bind_socket
        ec || trap_interrupt
        ec ||= notify_plugins_of_start
        ec || run_loop
      end

    private

      def write_plugin_host_option_parser_options  # #hook-out
        @op.on '--port <p>', "specify an alternate port #{
            }other than the default #{ @port_d }" do |x|
          if /\A\d+\z/ =~ x
            @port_d = x.intern
          else
            @y << "port must be postive int, aborting. (had: #{ x.inspect })"
            @result_code = GENERAL_ERROR_
          end
        end
      end

      event_a = [ :on_build_option_parser ]

      def write_plugin_host_option_parser_help_option  # #hook-out
        @op.on '--help', "this screen." do
          @y << "usage: #{ ::File.basename $PROGRAM_NAME  } [opts]"
          @y << "description: fixture server. listens on port #{ @port_d }"
          @y << "options:"
          @op.summarize @y
          @result_code = SUCCESS_
        end
      end

      def parse_parameters
        ec = parse_options
        ec ||= post_parse_options
        ec || parse_arguments
      end

      def parse_options
        @result_code = nil
        @op.parse! @argv
        @result_code
      rescue ::OptionParser::ParseError => e
        @y << e.message
        EARLY_EXIT_
      end

      def post_parse_options
        emit_to_plugins :on_options_parsed
      end
      event_a << :on_options_parsed

      def parse_arguments
        if @argv.length.nonzero?
          @y << "unexpected argument: #{ argv.first.inspect }"
          GENERAL_ERROR_
        end
      end

      def init_responder
        @responder = self.class::Responder__.new @y
        emit_to_plugins :on_responder_initted, @responder
      end
      event_a << :on_responder_initted

      def resolve_and_bind_socket
        @socket = @context.socket ::ZMQ::REP
        d = @socket.bind "tcp://*:#{ @port_d }"
        d.nonzero? and when_socket_bind_failure d
      end

      def trap_interrupt
        trap "INT" do
          @y << "received interrupt signal."
          shutdown_if_necessary 'interrupt signal'
        end

        at_exit do  # typically issued explicitly only during echo-debugging
          if @is_running
            @y << "shutting down because received 'exit' callback."
            shutdown
          end
        end
      end

      def shutdown_if_necessary s
        if @is_running
          shutdown
        else
          @y << "(shutdown already in progress at #{ s })"
        end ; nil
      end

      def shutdown
        @is_running or fail "sanity - check 'is_running' before shutdown"
        @is_running = false
        @y << "shutting down plugins.."
        shutdown_every_plugin
        @serr.write "shutting down server .."
        ec = close_socket
        ec ||= terminate_context
        ec or begin @y << " done." ; nil end
      end

      def shutdown_every_plugin
        a = emit_to_every_plugin :on_shutdown
        a and when_some_plugins_have_issues_shutting_down
      end
      event_a << :on_shutdown

      def when_some_plugins_have_issues_shutting_down a
        first = true
        a.each do |conduit, ec|
          @y << "had issue shutting down '#{ conduit.name.as_human }'#{
            } plugin (exitcode #{ ec })"
          first or next
          first = true
          @result_code = ec
        end ; nil
      end

      def run_loop
        @is_running = true ; @result_code = SUCCESS_
        @y << "fixture server running #{ rb_environment_moniker } #{
          }listening on port #{ @port_d }"
        begin
          ec = exec_loop_body
          ec and break
        end while @is_running
        ec and @result_code = ec
        @result_code
      end

      def rb_environment_moniker
        "#{ rb_engine_moniker } #{ ::RUBY_VERSION }"
      end

      def rb_engine_moniker
        s = ::RUBY_ENGINE
        case s
        when 'ruby';'MRI ruby'
        else ; "#{ s } ruby"
        end
      end

      def exec_loop_body
        d = @socket.recv_strings @buffer_a
        if @is_running  # ignore recv interrupts except in in case of INT
          if 0 > d
            when_recv_failure
          else
            process_received_strings
          end
        end
      end

      def when_recv_failure
        ec = report_socket_recv_failure
        shutdown_if_necessary 'receive failure'
        ec
      end

      def process_received_strings
        response = @responder.process_strings @buffer_a
        @buffer_a.clear
        s_a = response.flatten_via_flush
        ec = emit_to_plugins :on_response, s_a
        ec or send_strings s_a
      end
      event_a << :on_response


      def notify_plugins_of_start
        emit_to_plugins :on_start
      end
      event_a << :on_start

      class Response_Agent_
        def initialize y, response
          @response = response ; @y = y ; nil
        end
        def bork s
          @response.add_iambicly_structured_statement :error, s
          GENERAL_ERROR_
        end
      end

      Plugin_Listener_Matrix = ::Struct.new( * event_a )
    end


    # ~ the plugin API touchbacks: exposed channels from plugin to host

    class Fixture_Server  # (re-open)

      def stderr_for_plugin_conduit  # #hook-out
        @serr
      end

      plugin_conduit_class

      # ~ give plugins the ability to clear this cache

      class Plugin_Conduit
        def clear_cache_for_manifest_pathname pn
          up.clear_cache_for_mani_pn_from_conduit pn
        end
      end
      def clear_cache_for_mani_pn_from_conduit pn
        @responder.clear_cache_for_manifest_pathname pn
      end

      # ~ give plugins the ability to shutdown the server

      class Plugin_Conduit
        def shutdown
          up.shutdown_requested_by_plugin_conduit self
        end
      end
      def shutdown_requested_by_plugin_conduit cond
        @y << "received shutdown signal from #{ cond.name.as_human }.."
        shutdown_if_necessary 'plugin request' ; nil
      end


      # ~ constants used throughout this node

      EARLY_EXIT_ = 33 ; Fixture_Server = self
      GENERAL_ERROR_ = 3
      IO_THREADS_COUNT__ = 1
      MANIFEST_PARSE_ERROR_ = 36  # 3 -> m 9 -> p
      PROCEDE_ = nil ; SUCCESS_ = 0
    end
  end
end
