module Skylab::GitViz

  module Test_Lib_::Mock_System

    module Plugin_  # read [#031] the plugin narrative

      Host = -> cls do
        cls.extend Host_Module_Methods__
        cls.include Host_Instance_Methods__ ; nil
      end

      module Host_Module_Methods__
        def plugin_conduit_class
          if const_defined? :Plugin_Conduit, false
            self::Plugin_Conduit
          elsif const_defined? :Plugin_Conduit
            const_set :Plugin_Conduit, ::Class.new( self::Plugin_Conduit )
          else
            const_set :Plugin_Conduit, ::Class.new( Plugin_Conduit_ )
          end
        end
      end

      module Host_Instance_Methods__
      private

        def load_plugins
          @plugin_h = {}
          @plugin_listener_matrix =
            self.class.const_get( :Plugin_Listener_Matrix, false ).new
          conduit = plugin_conduit_cls.new @y, self
          box_mod = self.class::Plugins__
          box_mod.dir_pathname.children( false ).each do |pn|
            name = Name_.new pn
            DASH__ == name.getbyte( 0 ) and next
            cond = conduit.curry name
            plugin = box_mod.const_get( name.as_const, false ).new cond
            cond.plugin = plugin
            idx_plugin cond
          end
          init_plugins
        end
        DASH__ = '-'.getbyte 0

        def plugin_conduit_cls
          self.class.plugin_conduit_class
        end

        def idx_plugin cond
          k = cond.name.norm_i ; did = false
          pi_listener_matrix = @plugin_listener_matrix
          cond.plugin.class.instance_methods( false ).each do |m_i|
            ON_RX__ =~ m_i or next
            did ||= true
            ( pi_listener_matrix[ m_i ] ||= [] ) << k
          end
          @plugin_h[ k ] = cond ; nil
        end
        ON_RX__ = /\Aon_/

        def init_plugins
          init_option_parser_by_aggregating_plugin_options
        end

        def init_option_parser_by_aggregating_plugin_options
          @op = GitViz::Lib_::OptionParser[].new
          write_plugin_host_option_parser_options  # :+#hook-out
          rc = PROCEDE_
          emit_to_plugins :on_build_option_parser do |cond|
            op = Plugin_Option_Parser_Proxy_.new( a = [] )
            rc = cond.plugin.on_build_option_parser op
            rc and break
            Plugin_Option_Parser_Playback_.new( @y, @op, cond, a ).playback
          end
          rc or write_plugin_host_option_parser_help_option && nil # :+#hook-out
        end

        def emit_to_plugins m_i, * a, & p  # #storypoint-60
          a.length.nonzero? and p and raise ::ArgumentError
          p ||= -> cond do
            cond.plugin.send m_i, *a
          end
          k_a = @plugin_listener_matrix[ m_i ]
          ec = PROCEDE_
          k_a.each do |k|
            ec = p[ @plugin_h.fetch( k ) ]
            ec and break
          end
          ec
        end

        def emit_to_every_plugin m_i, * a  # #storypoint-75
          y = PROCEDE_
          @plugin_listener_matrix[ m_i ].each do |k|
            conduit = @plugin_h.fetch k
            ec = conduit.plugin.send m_i, * a
            ec or next
            ( y ||= [] ) << [ conduit, ec ]
          end
          y
        end
      end

      class Name_
        def initialize pn
          @pathname = pn
          @as_slug = pn.sub_ext( '' ).to_path.freeze
          @as_const = Constate_[ @as_slug ]
          @as_human = @as_slug.gsub( '-', ' ' ).freeze
          @norm_i = @as_slug.gsub( '-', '_' ).intern
        end
        attr_reader :as_const, :as_human, :as_slug, :norm_i
        def getbyte d
          @as_slug.getbyte d
        end
      end

      Constate_ = -> do  # 'constantize' and 'constantify' are taken
        rx = %r((?:(-)|^)([a-z]))
        -> s do
          s.gsub( rx ) { "#{ '_' if $~[1] }#{ $~[2].upcase }" }.intern
        end
      end.call

      class Plugin_Conduit_  # see [#031]:#understanding-plugin-conduits
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

        def get_qualified_stderr_line_yielder
          y = ::Enumerator::Yielder.new do |msg|
            @stderr_line_yielder << "#{ customized_message_prefix }#{ msg }"
            y
          end
        end

        def get_qualified_serr
          serr = @up_p[].stderr_for_plugin_conduit  # :+#hook-out
          Write_Proxy__.new do |s|
            serr.write "#{ customized_message_prefix }#{ s }" ; nil
          end
        end
        class Write_Proxy__ < ::Proc
          alias_method :write, :call
        end

      private

        def customized_message_prefix
          "  • #{ @name.as_human } "
        end

        def up
          @up_p[]
        end
      end

      class Plugin_Option_Parser_Proxy_
        def initialize a
          @a = a
        end
        def on * a, & p
          @a << [ a, p ] ; nil
        end
      end

      class Plugin_Option_Parser_Playback_
        def initialize y, op, cond, a
          @a = a ; @cond = cond ; @op = op ; @y = y
        end
        def playback
          @a.each do |a, p|
            Transform_Option_.new( @op, @cond, @y, a, p ).transform
          end ; nil
        end
      end

      class Transform_Option_
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
    end
  end
end
