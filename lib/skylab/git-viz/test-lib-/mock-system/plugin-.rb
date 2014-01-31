module Skylab::GitViz

  module Test_Lib_::Mock_System

    module Plugin_  # read [#031] the plugin narrative

      Host = -> cls do
        cls.extend Host_Module_Methods__
        cls.include Host_Instance_Methods__ ; nil
      end

      module Host_Module_Methods__

        define_method :build_mutable_callback_tree_specification,
          GitViz::Lib_::Callback_Tree::Methods::
            Build_mutable_callback_tree_specification

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
          @plugin_conduit_h = {}
          init_plugin_listener_matrix_if_necessary
          conduit = plugin_conduit_cls.new @y, self
          box_mod = rslv_some_plugin_box_mod
          box_mod.constants.each do |const_i|
            name = Name.from_const const_i
            WHITE_SLUG_RX__ =~ name.as_slug or next
            cond = conduit.curry name
            plugin = box_mod.const_get( name.as_const, false ).new cond
            cond.plugin = plugin
            idx_plugin cond
          end
          init_plugins
        end ; WHITE_SLUG_RX__ = /\A[a-z]/

        def init_plugin_listener_matrix_if_necessary
          @callbacks ||= bld_plugin_listener_matrix
        end

        def bld_plugin_listener_matrix
          self.class.const_get( :Callback_Tree__, false ).new
        end

        def plugin_conduit_cls
          self.class.plugin_conduit_class
        end

        def rslv_some_plugin_box_mod
          if self.class.const_defined? PLUGIN_BOX__, false
            self.class.const_get PLUGIN_BOX__, false
          else
            vivify_autoloading_plugin_box
          end
        end ; PLUGIN_BOX__ = :Plugins__

        def vivify_autoloading_plugin_box
          mod = self.class.const_set PLUGIN_BOX__, ::Module.new
          GitViz::Autoloader_[ mod, :boxxy ]
          mod
        end

        def idx_plugin cond
          k = cond.name.norm_i ; did = false
          callbacks = @callbacks
          cond.plugin.class.instance_methods( false ).each do |m_i|
            ON_RX__ =~ m_i or next
            did ||= true
            callbacks.add_callback_reference m_i, k
          end
          @plugin_conduit_h[ k ] = cond ; nil
        end
        ON_RX__ = /\Aon_/

        def init_plugins
          init_option_parser_by_aggregating_plugin_options
        end

        def init_option_parser_by_aggregating_plugin_options
          @op = GitViz::Lib_::OptionParser[].new
          write_plugin_host_option_parser_options  # :+#hook-out
          call_plugin_listeners :on_build_option_parser do |plugin_i|
            cond = @plugin_conduit_h.fetch plugin_i
            op = Plugin_Option_Parser_Proxy_.new( a = [] )
            cond.plugin.on_build_option_parser op
            Plugin_Option_Parser_Playback_.new( @y, @op, cond, a ).playback
          end
          write_plugin_host_option_parser_help_option  # :+#hook-out
          PROCEDE__
        end

        # read #storypoint-50 intro to "callback tree" event handling patterns

        def call_plugin_listeners m_i, * a, & p
          p = nrmlz_callback_map_args m_i, a, p
          @callbacks.call_listeners_with_map m_i, p
        end

        def call_plugin_shorters m_i, * a, & p  # #storypoint-60
          p = nrmlz_callback_map_args m_i, a, p
          @callbacks.call_shorters_with_map m_i, p
        end

        def attempt_with_plugins m_i, * a, & p  # #storypoint-65
          p = nrmlz_callback_map_args m_i, a, p
          @callbacks.call_attempters_with_map m_i, p
        end

        def nrmlz_callback_map_args m_i, a, p
          a.length.nonzero? and p and raise ::ArgumentError
          p || -> plugin_i do
            @plugin_conduit_h.fetch( plugin_i ).plugin.send m_i, * a
          end
        end

        def call_every_plugin_shorter m_i, * a  # #storypoint-75
          @callbacks.aggregate_any_shorts_with_map m_i, -> plugin_i do
            @plugin_conduit_h.fetch( plugin_i ).plugin.send m_i, * a
          end
        end

        PROCEDE__ = nil
      end

      class Name
        class << self
          def from_const const_i
            allocate_with :initialize_with_const_i, const_i
          end
          def from_human human_s
            allocate_with :initialize_with_human, human_s
          end
          def from_local_pathname pn
            allocate_with :initialize_with_local_pathname, pn
          end
          private :new
        private
          def allocate_with method_i, x
            new = allocate
            new.send method_i, x
            new
          end
        end
      private
        def initialize_with_const_i const_i
          @as_const = const_i
          @norm_i = const_i.to_s.downcase.intern
          init_slug ; init_human ; freeze
        end
        def initialize_with_human human_s
          @as_human = human_s.freeze
          @as_slug = human_s.gsub( ' ', '-' ).freeze
          init_norm ; init_const ; freeze
        end
        def initialize_with_local_pathname pn
          @as_slug = pn.sub_ext( '' ).to_path.freeze
          init_const ; init_human ; init_norm ; freeze
        end
        def init_const
          @as_const = Constify_map_reduce_slug_[ @as_slug ]
        end
        def init_norm
          @norm_i = @as_slug.gsub( '-', '_' ).intern
        end
        def init_human
          @as_human = @as_slug.gsub( '-', ' ' ).freeze
        end
        def init_slug
          @as_slug = @norm_i.to_s.gsub( '_', '-' ).freeze
        end
      public
        attr_reader :as_const, :as_human, :as_slug, :norm_i
      end

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
          y = ::Enumerator::Yielder.new do |msg_s|
            msg = Qualifiable_Message_String__.new msg_s
            msg.graphic_prefix = graphic_prefix
            msg.agent_prefix = agent_prefix
            @stderr_line_yielder << "#{ msg }"
            y
          end
        end

        def get_qualified_serr
          serr_p = @up_p[].stderr_reference_for_plugin  # :+#hook-out
          Write_Proxy__.new do |s|
            msg = Qualifiable_Message_String__.new s
            msg.graphic_prefix = graphic_prefix
            msg.agent_prefix = agent_prefix
            io = serr_p[]
            r = io.write "#{ msg }"
            io.flush
            r
          end
        end
        class Write_Proxy__ < ::Proc
          alias_method :write, :call
        end

      private

        def graphic_prefix
          self.class::GRAPHIC_PREFIX__
        end ; GRAPHIC_PREFIX__ = '  • '.freeze

        def agent_prefix
          "#{ @name.as_human } "
        end

        def up
          @up_p[]
        end
      end

      Qualifiable_Message_String__ = ::Struct.
          new :graphic_prefix, :open, :agent_prefix, :body, :close
      class Qualifiable_Message_String__
        def initialize msg
          if (( md = PAREN_EXPLODER_RX__.match msg ))
            super nil, md[1], nil, md[2], md[3]
          else
            super nil, nil, nil, msg
          end
        end
        PAREN_EXPLODER_RX__ = /\A(\()(.+)(\)?)\z/
        def to_s
          to_a.join
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
