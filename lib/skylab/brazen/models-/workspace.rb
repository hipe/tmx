module Skylab::Brazen

  class Models_::Workspace < Brazen_::Model_  # see [#055]

    edit_entity_class(

      :desc, -> y do
        y << "manage workspaces."
      end,

      :after, :status,

      :persist_to, :datastore_git_config,

      :preconditions, EMPTY_A_,

      :required, :property, :config_filename,

      :required, :property, :surrounding_path )

    def members
      [ :datastore, :existent_surrounding_path ]
    end

    # ~ custom exposures

    class << self

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
      if @datastore_resolved_OK
        @datastore.description_under expag
      elsif @pn
        pn = @pn
        expag.calculate do
          pth pn
        end
      else
        self.class.name_function.as_human
      end
    end

    def datastore_controller_via_entity _ent
      self
    end

    def provide_action_precondition _id, graph
      self
    end

    def __NO__receive_missing_required_properties ev  # covered by [tm], #ugly
      receive_missing_required_properties_softly ev
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

    class Silo__ < Brazen_.model.silo_class

      def model_class
        Workspace_
      end

      def any_mutated_formals_for_depender_action_formals x
        bx = x.to_mutable_box_like_proxy
        st = COMMON_PROPERTIES_.to_stream
        prp = st.gets
        begin
          bx.add prp.name_symbol, prp
          prp = st.gets
        end while prp
        bx
      end
    end

    class Silo_Controller__ < Brazen_.model.silo_controller_class

      def provide_collection_controller_precon _id, graph
        __workspace_via_rising_action graph.action
      end

      def __workspace_via_rising_action action
        @action = action
        ws = __via_action_produce_workspace_via_object_argument
        ws || __via_action_produce_workspace_via_workspace_silo
      end

      def __via_action_produce_workspace_via_object_argument
        @action.argument_box[ :workspace ]  # for internal API calls
      end

      def __via_action_produce_workspace_via_workspace_silo

        @oes_p = event_lib.
          produce_handle_event_selectively_through_methods.
            bookends self, :ws_via_action do | * i_a, & ev_p |
          maybe_send_event_via_channel i_a, & ev_p
        end

        @ws = @model_class.edit_entity @kernel, @oes_p do |o|
          o.preconditions @preconditions
          bx = @action.argument_box
          o.edit_with(
            :config_filename, bx.fetch( :config_filename ),
            :surrounding_path, bx.fetch( :workspace_path ) )
        end

        @ws and __existent_workspace_via_workspace
      end

      def __existent_workspace_via_workspace

        _did_find = @ws.resolve_nearest_existent_surrounding_path(
          @action.argument_value( :max_num_dirs ),
          :prop, @action.formal_property_via_symbol( :workspace_path ),
          & @oes_p )

        _did_find and begin

          if @action.any_argument_value_at_all( :verbose )  # #tracking :+[#069] verbose manually
            maybe_send_event :info, :verbose, :using_workspace do
              build_neutral_event_with :using_workspace,
                :config_path, @ws.existent_config_path
            end
          end

          @ws
        end
      end

      def on_ws_via_action_resource_not_found_via_channel i_a, & ev_p
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
    end

    Workspace_ = self
  end
end
