module Skylab::GitViz

  module Test_Lib_::Mock_System

    class Fixture_Server  # read [#018]:#introduction-to-the-middle-end

      Mock_System::Plugin_::Host[ self ]
      Mock_System::Socket_Agent_[ self ]
      include Socket_Agent_Constants_

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

      spec = build_mutable_callback_tree_specification
      spec << :on_build_option_parser

      def write_plugin_host_option_parser_help_option  # #hook-out
        @op.on '--help', "this screen." do
          @y << "usage: #{ ::File.basename $PROGRAM_NAME } [opts]"
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
      spec << :on_options_parsed

      def parse_arguments
        if @argv.length.nonzero?
          @y << "unexpected argument: #{ @argv.first.inspect }"
          GENERAL_ERROR_
        end
      end

      def init_responder
        @responder = self.class::Responder__.new @y
        emit_to_plugins :on_responder_initted, @responder
      end
      spec << :on_responder_initted

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
          PROCEDE_
        end
      end

      def shutdown
        @is_running or fail "sanity - check 'is_running' before shutdown"
        @is_running = false
        @y << "shutting down plugins.."
        shutdown_every_plugin
        @serr.write "shutting down server .."
        ec = close_socket_and_terminate_context
        ec or begin @y << " done." ; nil end
      end

      def shutdown_every_plugin
        a = emit_to_every_plugin :on_shutdown
        a and when_some_plugins_have_issues_shutting_down a ; nil
      end
      spec << :on_shutdown

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
        if @buffer_a.length.nonzero? and
            DASH__ != @buffer_a.fetch( 0 ).getbyte( 0 ) and
              prs_server_directive_from_buffer_a
          prcss_server_directive
        else
          prcss_received_strings_with_responder
        end
      end ; DASH__ = '-'.getbyte 0

      def prs_server_directive_from_buffer_a
        const_i = @buffer_a.fetch( 0 ).gsub( /(?:^|( ))([a-z])/ ) do
          "#{ '_' if $~[1] }#{ $~[2].upcase }"
        end.intern
        if Fixture_Server::Alternate_Responders__.const_defined? const_i, false
          @responder_const_i = const_i ; @buffer_a.shift ; true
        end
      end

      def prcss_server_directive
        const_i = @responder_const_i
        cls = Fixture_Server::Alternate_Responders__.const_get const_i, false
        name = Mock_System::Plugin_::Name.from_const const_i
        cond = plugin_conduit_cls.new( @y, self ).curry( name )
        responder = cls.new cond
        ec = responder.invoke @buffer_a
        @buffer_a.clear
        ec
      end

      def prcss_received_strings_with_responder
        response = @responder.process_strings @buffer_a
        @buffer_a.clear
        s_a = response.flatten_via_flush
        ec = emit_to_plugins :on_response, s_a
        ec or send_strings s_a
      end
      spec << :on_response


      def notify_plugins_of_start
        emit_to_plugins :on_start
      end
      spec << :on_start

      class Response_Agent_
        def initialize y, response
          @response = response ; @y = y ; nil
        end
        def bork s
          @response.add_iambicly_structured_statement :error, s
          GENERAL_ERROR_
        end
      end

      def emit_error_string s
        @y << s
      end

      Callback_Tree__ = spec.flush

    end


    # ~ the plugin API touchbacks: exposed channels from plugin to host

    class Fixture_Server  # (re-open)

      plugin_conduit_class
      class Plugin_Conduit  # ~ plugins can have raw stderr if they want it
        def stderr
          up.stderr_for_plugin_conduit
        end
      end
      def stderr_for_plugin_conduit  # #hook-out to
        @serr
      end

      class Plugin_Conduit  # ~ plugins that run threads need this
        def port_d
          up.port_d_for_plugin
        end
      end
      def port_d_for_plugin
        @port_d
      end

      class Plugin_Conduit  # ~ give plugins the ability to clear this cache

        def clear_cache_for_manifest_pathname pn
          up.clear_cache_for_mani_pn_from_conduit pn
        end
      end
      def clear_cache_for_mani_pn_from_conduit pn
        @responder.clear_cache_for_manifest_pathname pn
      end

      class Plugin_Conduit  # ~ give plugins the ability to shutdown the server
        def shutdown
          up.shutdown_requested_by_plugin_conduit self
        end
      end
      def shutdown_requested_by_plugin_conduit cond
        @y << "received shutdown signal from #{ cond.name.as_human }.."
        shutdown_if_necessary 'plugin request'
      end

      module Alternate_Responders__
        Autoloader_[ self, :boxxy ]
      end

      # ~ constants used throughout this node

      Fixture_Server = self
      GENERAL_ERROR_ = GENERAL_ERROR_
      MANIFEST_PARSE_ERROR_ = 36  # 3 -> m 9 -> p
      PROCEDE_ = nil ; SUCCESS_ = 0
    end
  end
end
