module Skylab::GitViz

  x = $VERBOSE ; $VERBOSE = nil ; GitViz::Lib_::ZMQ[] ; $VERBOSE = x

  module Test_Lib_::Mock_System

    class Fixtures # read [#018]:#introduction-to-the-middle-end

      def initialize serr, port_d, argv
        @argv = argv
        @buffer_a = []
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

      def init_responder
        @responder = GitViz::Test_Lib_::Mock_System::Manifest::Responder.
          new @y
        emit_to_plugins :on_responder_initted, @responder
      end

      def resolve_context
        @context = ::ZMQ::Context.new 1 ; nil
      end

      def resolve_and_bind_socket
        @socket = @context.socket ::ZMQ::REP
        @socket.bind "tcp://*:#{ @port_d }" ; nil
      end

      def trap_interrupt
        trap "INT" do
          @y << "received shutdown signal."
          shutdown_if_necessary
        end ; nil
      end

      def shutdown_if_necessary
        @is_shutting_down ||= begin ; yes = true end
        if yes
          shutdown
        else
          @y << "(shutdown already in progress)" ; nil
        end
      end

      def shutdown
        @y << "shutting down plugins.."
        shutdown_every_plugin
        @serr.write "shutting down server .."
        @is_running = false  # do this before below so no receive failure
        @socket.close
        @context.terminate
        @y << " done." ; nil
      end

      def run_loop
        @is_running = true ; @result_code = SUCCESS_
        @y << "fixture server listening on port #{ @port_d }"
        begin
          ec = exec_loop_body
          ec and break
        end while @is_running
        ec and @result_code = ec
        @result_code
      end

      def exec_loop_body
        ec = recv_strings
        @is_running and ec || process_received_strings
      end

      def recv_strings
        d = @socket.recv_strings @buffer_a
        @is_running and 0 > d and when_recv_failure
      end

      def when_recv_failure
        d = ::ZMQ::Util.errno
        _s = ::LibZMQ.zmq_strerror( d ).read_string
        @y << "receive failure: #{ _s }"
        shutdown_if_necessary
        d
      end

      def process_received_strings
        response = @responder.process_strings @buffer_a
        @buffer_a.clear
        s_a = response.flatten_via_flush
        ec = emit_to_plugins :on_response, s_a
        ec or send_strings s_a
      end

      def send_strings s_a
        d = @socket.send_strings s_a
        0 > d and when_send_failure
      end

      def when_send_failure
        d = ::ZMQ::Util.errno
        _s = ::LibZMQ.zmq_strerror( d ).read_string
        @y << "send failure: #{ _s }" ; d
      end

      # ~ plugins

      def load_plugins
        @listener_matrix_h = {} ; @plugin_h = {}
        conduit = Plugin_Conduit__.new @y, self
        box_mod = self.class::Plugins__
        box_mod.dir_pathname.children( false ).each do |pn|
          name = Name__.new pn
          DASH__ == name.getbyte( 0 ) and next
          cond = conduit.curry name
          plugin = box_mod.const_get( name.as_const, false ).new cond
          cond.plugin = plugin
          index_plugin cond
        end
        init_plugins
      end
    public
      def clear_cache_for_mani_pn_from_conduit pn
        @responder.clear_cache_for_manifest_pathname pn
      end
      def serr_for_conduit
        @serr
      end
      def shutdown_requested_by_plugin_conduit cond
        @y << "received shutdown signal from #{ cond.name.as_human }.."
        shutdown_if_necessary ; nil
      end
    private

      def index_plugin cond
        k = cond.name.norm_i ; did = false
        cond.plugin.class.instance_methods( false ).each do |m_i|
          ON_RX__ =~ m_i or next
          did ||= true
          @listener_matrix_h.fetch( m_i ) do
            @listener_matrix_h[ m_i ] = []
          end << k
        end
        @plugin_h[ k ] = cond ; nil
      end
      ON_RX__ = /\Aon_/

      def init_plugins
        @op = GitViz::Lib_::OptionParser[].new
        write_server_options
        rc = PROCEDE_
        emit_to_plugins :on_build_option_parser do |cond|
          op = Plugin_Option_Parser_Proxy_.new( a = [] )
          rc = cond.plugin.on_build_option_parser op
          rc and break
          Plugin_Option_Parser_Playback__.new( @y, @op, cond, a ).playback
        end
        rc || write_op_help
      end
      DASH__ = '-'.getbyte 0

      def write_server_options
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

      def write_op_help
        @op.on '--help', "this screen." do
          @y << "usage: #{ ::File.basename $PROGRAM_NAME  } [opts]"
          @y << "description: fixture server. listens on port #{ @port_d }"
          @y << "options:"
          @op.summarize @y
          @result_code = SUCCESS_
        end ; nil
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

      def parse_arguments
        if @argv.length.nonzero?
          @y << "unexpected argument: #{ argv.first.inspect }"
          GENERAL_ERROR_
        end
      end

      def notify_plugins_of_start
        emit_to_plugins :on_start
      end

      def shutdown_every_plugin
        a = emit_to_every_plugin :on_shutdown
        a and when_some_plugins_have_issues_shutting_down
      end

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

      def emit_to_plugins m_i, * a, & p
        a.length.nonzero? and p and raise ::ArgumentError
        p ||= -> cond do
          cond.plugin.send m_i, *a
        end
        k_a = @listener_matrix_h[ m_i ]
        ec = PROCEDE_
        k_a.each do |k|
          conduit = @plugin_h.fetch k
          ec = p[ conduit ]
          ec and break
        end
        ec
      end

      def emit_to_every_plugin m_i, * a
        y = PROCEDE_
        @listener_matrix_h[ m_i ].each do |k|
          conduit = @plugin_h.fetch k
          ec = conduit.plugin.send m_i, * a
          ec or next
          ( y ||= [] ) << [ conduit, ec ]
        end
        y
      end

      class Plugin_Option_Parser_Proxy_
        def initialize a
          @a = a
        end
        def on * a, & p
          @a << [ a, p ] ; nil
        end
      end
      class Plugin_Option_Parser_Playback__
        def initialize y, op, cond, a
          @a = a ; @cond = cond ; @op = op ; @y = y
        end
        def playback
          @a.each do |a, p|
            Transform_Option__.new( @op, @cond, @y, a, p ).transform
          end ; nil
        end
      end
      class Transform_Option__
        def initialize op, cond, y, a, p
          @a = a ; @cond = cond ; @op = op ; @p = p ; @y = y
        end
        def transform
          (( @md = RX__.match @a.first )) ? matched : not_matched ; nil
        end
        RX__ = /\A--[-a-zA-Z0-9]+(?=\z|[= ])/
        def not_matched
          @y << "(bad option name, skipping - #{ @a.first }" ; nil
        end
        def matched
          _new_name = "#{ @md[0] }-for-#{ @cond.name.as_slug }"
          @a[ 0 ] = "#{ _new_name }#{ @md.post_match }"
          @op.on( * @a, & @p )
        end
      end

      Listener_Set__ = ::Struct.
        new :on_build_option_parser,
          :on_options_parsed,
          :on_start,
          :on_response,
          :on_shutdown

      class Plugin_Conduit__
        def initialize y, real
          @up_p = -> { real }
          @stderr_line_yielder = y
        end
        attr_accessor :plugin
        attr_reader :stderr_line_yielder
        def curry name
          otr = dup
          otr.initialize_curry name
          otr
        end
        def initialize_copy otr
          @stderr_line_yielder = otr.stderr_line_yielder
        end
        def initialize_curry name
          @name = name
        end
        attr_reader :name

        def get_qualified_serr
          serr = @up_p[].serr_for_conduit
          Write_Proxy__.new do |s|
            serr.write "#{ customized_message_prefix }#{ s }" ; nil
          end
        end
        class Write_Proxy__ < ::Proc
          alias_method :write, :call
        end

        def get_qualified_stderr_line_yielder
          y = ::Enumerator::Yielder.new do |msg|
            @stderr_line_yielder << "#{ customized_message_prefix }#{ msg }"
            y
          end ; y
        end

        def customized_message_prefix
          "  • #{ @name.as_human } "
        end

        def clear_cache_for_manifest_pathname pn
          @up_p[].clear_cache_for_mani_pn_from_conduit pn
        end

        def shutdown
          @up_p[].shutdown_requested_by_plugin_conduit self
        end
      end

      class Name__
        def initialize pn
          @pathname = pn
          @as_slug = pn.sub_ext( '' ).to_path.freeze
          @as_const = Constate__[ @as_slug ]
          @as_human = @as_slug.gsub( '-', ' ' ).freeze
          @norm_i = @as_slug.gsub( '-', '_' ).intern
        end
        attr_reader :as_const, :as_human, :as_slug, :norm_i
        def getbyte d
          @as_slug.getbyte d
        end
      end
      Constate__ = -> do  # 'constantize' and 'constantify' are taken
        rx = %r((?:(-)|^)([a-z]))
        -> s do
          s.gsub( rx ) { "#{ '_' if $~[1] }#{ $~[2].upcase }" }.intern
        end
      end.call

      EARLY_EXIT_ = 33
      GENERAL_ERROR_ = 3 ; PROCEDE_ = nil ; SUCCESS_ = 0
    end
  end
end
