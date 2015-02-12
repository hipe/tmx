module Skylab::Brazen

  class Models_::Workspace < Brazen_::Model_  # see [#055]

    edit_entity_class(

      :desc, -> y do
        y << "manage workspaces."
      end,

      :after, :status,

      :preconditions, EMPTY_A_,

      :required, :property, :config_filename,

      :required, :property, :surrounding_path )

    def members
      [ :existent_surrounding_path ]
    end

    # ~ custom exposures

    class << self

      def common_properties  # [tm]
        COMMON_PROPERTIES_
      end

      def default_config_filename
        self::WS_CONF_FILENAME__
      end

      def set_workspace_config_filename x
        const_set :WS_CONF_FILENAME__, x
        nil
      end
    end

    WS_CONF_FILENAME__ = 'brazen.conf'.freeze

    # ~~ init

    def init_workspace * x_a, & oes_p  # any result

      bx = @property_box
      x_a.unshift(
        :surrounding_path, bx.fetch( :surrounding_path ),
        :config_filename, bx.fetch( :config_filename ) )

      Workspace_::Actors__::Init.call_via_iambic x_a, & oes_p
    end

    # ~~ find nearest

    def existent_config_path
      path = existent_surrounding_path
      path and ::File.join( path, @property_box.fetch( :config_filename ) )
    end

    def existent_surrounding_path
      if @_surrounding_path_exists
        @property_box.fetch :surrounding_path
      end
    end

    def resolve_nearest_existent_surrounding_path max_num_dirs, * x_a, & oes_p

      oes_p or raise ::ArgumentError  # just because we always do anyway

      max_num_dirs ||= -1  # see #note-040 "why we do this here"
      x_a.unshift :max_num_dirs_to_look, max_num_dirs
      bx = @property_box
      x_a.push :start_path, bx.fetch( :surrounding_path ),
        :filename, bx.fetch( :config_filename )

      surrounding_path = LIB_.system.filesystem.walk.call_via_iambic x_a, & oes_p

      if surrounding_path
        @property_box.replace :surrounding_path, surrounding_path
        @_surrounding_path_exists = true
        ACHIEVED_
      else
        @_surrounding_path_exists = false
        UNABLE_
      end
    end

    # ~ #hook-outs and #hook-ins

    def description_under expag

      if document_
        @document_.description_under expag
      else
        path = @property_box[ :surrounding_path ]
        if path
          expag.calculate do
            pth path
          end
        else
          self.class.name_function.as_human
        end
      end
    end

    # ~~ c r u d

    def receive_persist_entity act, ent, & oes_p
      doc = _document( & oes_p )
      doc and begin
        doc.receive_persist_entity act, ent, & oes_p
      end
    end

    def entity_via_intrinsic_key id, & oes_p
      doc = _document( & oes_p )
      doc and begin
        doc.entity_via_intrinsic_key id, & oes_p
      end
    end

    def entity_stream_via_model cls, & oes_p
      doc = _document( & oes_p )
      doc and begin
        doc.entity_stream_via_model cls, & oes_p
      end
    end

    def receive_delete_entity act, ent, & oes_p
      doc = _document( & oes_p )
      doc and begin
        doc.receive_delete_entity act, ent, & oes_p
      end
    end

    # ~ for actions

    def resolve_document_ & oes_p
      _document( & oes_p ) ? ACHIEVED_ : UNABLE_
    end

    attr_reader :document_

    # ~ support

    def _document & oes_p
      @___did_attempt_to_resolve_document ||= begin

        @document_ = Brazen_::Data_Stores_::Git_Config.via_path_and_kernel(
          existent_config_path, @kernel, & oes_p )

        true
      end
      @document_
    end

    # ~ for actions

    COMMON_PROPERTIES_ = make_common_properties do | sess |

      sess.edit_entity_class(

        :default_proc, -> action do
          action.kernel_.model_class( :Workspace ).default_config_filename
        end,
        :property, :config_filename,

        :description, -> y do
          if @current_property.has_primitive_default
            _ = " (default: #{ ick @current_property.primitive_default_value })"
          end
          y << "max num dirs to look for workspace in#{ _ }"
        end,
        :non_negative_integer,
        :default, 1,
        :property, :max_num_dirs,

        :required, :property, :workspace_path
      )
    end

    # ~ some actions stowed away here

    module Actions

      class Ping < Brazen_::Model_::Action

        def produce_result
          maybe_send_event :payload, :ping do
            build_OK_event_with :ping do |y, o|
              y << "hello from #{ app_name }"
            end
          end
          :_hello_from_brazen_
        end
      end

      Autoloader_[ self, :boxxy ]
    end

    # ~ the custom stack

    class Silo_Daemon < Silo_Daemon

      # ~ custom exposures

      def workspace_via_trio_box box, & oes_p
        WS_via_trio_box___.new( box, @model_class, @kernel, & oes_p ).execute
      end

      # ~ hook-outs / hook-ins

      def precondition_for action, id, box, & oes_p
        WS_via_trio_box___.
          new( action.to_trio_box_proxy, @model_class, @kernel, & oes_p ).execute
      end

      def any_mutated_formals_for_depender_action_formals x
        bx = x.to_mutable_box_like_proxy
        st = COMMON_PROPERTIES_.to_stream
        begin
          prp = st.gets
          prp or break
          k = prp.name_symbol
          bx.has_name k and redo
          bx.add k, prp
          redo
        end while nil
        bx
      end
    end

    class WS_via_trio_box___

      def initialize bx, mc, k, & oes_p
        @bx = bx
        @kernel = k
        @model_class = mc
        @on_event_selectively = oes_p

        @oes_p = Callback_::Event.
          produce_handle_event_selectively_through_methods.
            bookends self, :Workspace_via_trio_boX do | * i_a, & ev_p |
          maybe_send_event_via_channel i_a, & ev_p
        end
      end

      def execute

        @ws = @model_class.edit_entity @kernel, @oes_p do |o|
          o.edit_with(
            :config_filename, @bx.fetch( :config_filename ).value_x,
            :surrounding_path, @bx.fetch( :workspace_path ).value_x )
        end

        @ws and __via_workspace_produce_existent_workspace_via_trio_box @bx
      end

      def __via_workspace_produce_existent_workspace_via_trio_box bx

        _did_find = @ws.resolve_nearest_existent_surrounding_path(
          bx.fetch( :max_num_dirs ).value_x,
          :prop, bx.fetch( :workspace_path ).property,
          & @oes_p )

        _did_find and begin

          trio = bx[ :verbose ]
          if trio and trio.value_x  # #tracking :+[#069] verbose manually
            maybe_send_event :info, :verbose, :using_workspace do
              build_neutral_event_with :using_workspace,
                :config_path, @ws.existent_config_path
            end
          end

          @ws
        end
      end

      def on_Workspace_via_trio_boX_resource_not_found_via_channel i_a, & ev_p
        maybe_send_event_via_channel i_a do
          bld_workspace_not_found_event ev_p[]
        end
      end

      def bld_workspace_not_found_event ev
        x_a = ev.to_iambic
        x_a[ 0 ] = :workspace_not_found  # was 'resource_not_found'
        x_a.push :invite_to_action, [ :init ]
        build_event_via_iambic_and_message_proc x_a, ev.message_proc
      end

      Callback_::Event.selective_builder_sender_receiver self
    end

    Workspace_ = self
  end
end
