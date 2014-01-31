module Skylab::GitViz

  module Test_Lib_::Mock_System

    class Fixture_Server  # read [#018]:#introduction-to-the-middle-end

      Mock_System::Plugin_::Host[ self ]
      Mock_System::Socket_Agent_[ self ]
      include Socket_Agent_Constants_

      def initialize serr, port_d, argv
        @argv = argv ; @buffer_a = []
        @serr = serr ; @port_d = port_d
        @server_lifepoint_index = 0
        @server_lifepoint_semaphore = Mutex.new
        @y = ::Enumerator::Yielder.new do |msg|
          @serr.puts msg
          @serr.flush  # makes a different if you are tailing the log
          @y
        end
      end

      def run
        ec = load_plugins
        ec ||= parse_parameters
        ec ||= init_front_responder
        ec ||= resolve_context_and_bind_reply_socket
        ec || set_signal_handlers
        ec ||= call_plugin_shorters :on_start
        ec || run_loop
      end

      callbacks = build_mutable_callback_tree_specification
      callbacks << :on_start

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

      callbacks << :on_build_option_parser

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
        ec ||= call_plugin_shorters :on_options_parsed
        ec || parse_arguments
      end
      callbacks << :on_options_parsed

      def parse_options
        @result_code = nil
        @op.parse! @argv
        @result_code
      rescue ::OptionParser::ParseError => e
        @y << "fixture server: #{ e.message }"
        EARLY_EXIT_
      end

      def parse_arguments
        if @argv.length.nonzero?
          @y << "unexpected argument: #{ @argv.first.inspect }"
          GENERAL_ERROR_
        end
      end

      def init_front_responder
        @front_responder = self.class::Responder__.new @y
        call_plugin_shorters :on_front_responder_initted, @front_responder
      end
      callbacks << :on_front_responder_initted

      def set_signal_handlers
        trap 'INT' do
          @y << "(caught interrupt. #{
            }will attempt to shutdown at receive failure..)"
        end
      end

      def report_and_result_in_socket_recv_failure
        ec = super
        ZMQ_INTERRUPT_ERROR__ == ec and d = shutdown_during_interrupt and ec = d
        ec
      end
      ZMQ_INTERRUPT_ERROR__ = 4

      def shutdown_during_interrupt
        @buffer_a.length.nonzero? and report_lost_buffer_during_shutdown
        name = Test_Lib_::Mock_System::Plugin_::Name.from_human 'the server'
        host = plugin_conduit_cls.new( @y, self ).curry name
        yy = host.get_qualified_stderr_line_yielder
        rc = host.shut_down "due to interrupt" do |sd|
          sd.when_did_not do |msg|
            yy << msg
            GENERAL_ERROR_
          end
          sd.when_did yy.method :<<
          sd.info_line @y.method :<<
          sd.info_line_head @serr.method :write
          sd.info_line_tail @serr.method :puts
        end
        rc || SUCCESS_
      end

      def report_lost_buffer_during_shutdown
        @y << "(request starting with '#{ @buffer_a.first }' will not be #{
          }processed due to being interrupted by a shutdown)"
      end

      def run_loop
        @server_lifepoint_index += 1
        @result_code = SUCCESS_
        call_plugin_listeners :on_beginning_of_loop
        begin
          ec = execute_loop_body
          ec and break
        end while is_running
        ec and @result_code = ec
        call_plugin_listeners :on_end_of_loop
        call_plugin_listeners :on_finalize
        @result_code
      end
      callbacks.listeners :on_beginning_of_loop
      callbacks.listeners :on_end_of_loop
      callbacks.listeners :on_finalize

      def execute_loop_body
        ec = recv_strings @buffer_a
        ec or call_plugin_listeners :on_received_request_strings
        ec || process_received_strings
      end
      callbacks.listeners :on_received_request_strings

      def process_received_strings
        if is_server_directive  # #jump-1, #[#018]:#what-are-server-directives
          prcss_server_directive
        else
          prcss_received_strings
        end
      end

      def is_server_directive
        ok = @buffer_a.length.nonzero?
        ok &&= DASH__ != @buffer_a.fetch( 0 ).getbyte( 0 )
        ok && can_and_do_preprocess_server_directive
      end ; DASH__ = '-'.getbyte 0

      def can_and_do_preprocess_server_directive
        slug_s = @buffer_a.fetch( 0 ).gsub ' ', '-'
        i = Constify_map_reduce_slug_[ slug_s ]
        if i and Fixture_Server::Alternate_Responders__.const_defined? i, false
          @responder_const_i = i ; @buffer_a.shift ; true
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

      def prcss_received_strings
        call_plugin_listeners :on_request, @buffer_a
        @buffer_a.length.nonzero? and prcss_received_strings_with_responder
      end
      callbacks.listeners :on_request

      def prcss_received_strings_with_responder
        response = @front_responder.process_strings @buffer_a
        @buffer_a.clear
        s_a = response.flatten_via_flush
        ec = call_plugin_shorters :on_response, s_a
        ec or send_strings s_a
      end
      callbacks << :on_response

      callbacks << :on_shutdown

      Callback_Tree__ = callbacks.flush  # then used by plugin subsystem

      # ~ small private utility methods used everywhere

      def is_running
        SERVER_IS_RUNNING_LIFEPOINT_INDEX_ == @server_lifepoint_index
      end ; SERVER_IS_RUNNING_LIFEPOINT_INDEX_ = 1

      def emit_error_string s  # #hook-out
        @y << s
      end

      # ~ the plugin API touchbacks: exposed channels from plugin to host

      public
      plugin_conduit_class

      class Plugin_Conduit  # ~ plugins can know the port
        def port_d
          up.port_d_for_plugin
        end
      end
      def port_d_for_plugin
        @port_d
      end

      class Plugin_Conduit  # ~ plugins can have a reference to our stderr
        def stderr_reference
          up.stderr_reference_for_plugin
        end
      end
      def stderr_reference_for_plugin  # #hook-out too
        -> { @serr }
      end

      class Plugin_Conduit  # ~ plugins can change the stderr file descriptor
        def swap_stderr fh
          up.swap_stderr_for_plugin fh
        end
      end
      def swap_stderr_for_plugin fh
        orig_x = @serr ; @serr = fh ; orig_x
      end

      class Plugin_Conduit  # ~ give plugins the ability to clear this cache

        def clear_cache_for_manifest_pathname pn
          up.clear_cache_for_mani_pn_from_plugin pn
        end
      end
      def clear_cache_for_mani_pn_from_plugin pn
        @front_responder.clear_cache_for_manifest_pathname pn
      end

      class Plugin_Conduit  # ~ lots of lowlevel access
        def context_and_socket
          up.context_and_socket_for_plugin
        end
        def bfr_a
          up.instance_variable_get :@buffer_a
        end
        def call_every_plugin_shorter *a, &p
          up.send :call_every_plugin_shorter, *a, &p
        end
        def dereference_plugin_symbol_to_conduit i
          up.dereference_plugin_symbol_to_conduit i
        end
        def lifepoint_synchronize &p
          up.lifepoint_synchronize_for_plugin( &p )
        end
        def tentative_result_code
          up.instance_variable_get :@result_code
        end
        def shut_down msg, &p
          Fixture_Server::Shut_Down__.new( self, msg, &p ).attempt_to_shutdown
        end
      end

      def context_and_socket_for_plugin
        [ @context, @socket ]
      end

      def dereference_plugin_symbol_to_conduit i
        @plugin_conduit_h.fetch i
      end

      def lifepoint_synchronize_for_plugin &p
        @server_lifepoint_semaphore.synchronize do
          read_p = -> do
            @server_lifepoint_index
          end
          inc_p = -> do
            @server_lifepoint_index += 1
          end
          cnt = Lifepoint_Controller__.new -> { read_p[] }, -> { inc_p[] }
          r = p[ cnt ]
          read_p = inc_p = -> { } ; r
        end
      end
      class Lifepoint_Controller__
        def initialize a, b
          @a = a ; @b = b
        end
        def lifepoint_index
          @a[]
        end
        def increment_lifepoint_index
          @b[]
        end
      end

      # ~ protected classes used by here and/or by children

      class Response_Agent_
        def initialize y, response
          @response = response ; @y = y ; nil
        end
        def bork s
          @response.add_iambicly_structured_statement :error, s
          GENERAL_ERROR_
        end
      end

      class Shutdown_Message_
        def initialize reason_s
          @message_s_a = [ 'shut it down', 'message', reason_s ]
        end
        attr_reader :message_s_a
      end

      # ~ constants used throughout this node

      module Alternate_Responders__
        Autoloader_[ self, :boxxy ]
      end

      Fixture_Server = self
      GENERAL_ERROR_ = GENERAL_ERROR_
      MANIFEST_PARSE_ERROR_ = 36  # 3 -> m 9 -> p
      PROCEDE_ = SILENT_ = nil ; SUCCESS_ = 0
    end
  end
end
