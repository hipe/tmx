module Skylab::Brazen

  class Models_::Workspace < Home_::Model  # see [#055]

    edit_entity_class(

      :branch_description, -> y do
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

      _ok = Here_::Magnetics::InitWorkspace_via_PathHead_and_PathTail.
        call_via_iambic x_a, & oes_p

      _store :@_surrounding_path_exists, _ok
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

      surrounding_path = LIB_.system_lib::Filesystem::Walk.call_via_iambic x_a, & oes_p

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

    def persist_entity( x=nil, ent, & oes_p )

      doc = _document( & oes_p )
      doc and begin
        doc.persist_entity( * x, ent, & oes_p )
      end
    end

    def entity_via_intrinsic_key id, & oes_p
      doc = _document( & oes_p )
      doc and begin
        doc.entity_via_intrinsic_key id, & oes_p
      end
    end

    def to_entity_stream_via_model cls, & oes_p
      doc = _document( & oes_p )
      doc and begin
        doc.to_entity_stream_via_model cls, & oes_p
      end
    end

    def delete_entity act, ent, & oes_p
      doc = _document( & oes_p )
      doc and begin
        doc.delete_entity act, ent, & oes_p
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

        @document_ = Home_::CollectionAdapters::GitConfig.via_path_and_kernel(
          existent_config_path, @kernel, & oes_p )

        true
      end
      @document_
    end

    define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

    # ~ for actions

    COMMON_PROPERTIES_ = make_common_properties do | sess |

      sess.edit_common_properties_module(

        :default_proc, -> action do
          action.kernel.unbound( :Workspace ).default_config_filename
        end,
        :property, :config_filename,

        :description, -> y do

          prp = action_reflection.front_properties.fetch :man_num_dirs

          if prp.has_primitive_default
            _ = " (default: #{ ick prp.primitive_default_value })"
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

      class Ping < Home_::Action

        def produce_result
          maybe_send_event :payload, :ping do
            build_OK_event_with :ping do |y, o|
              y << "hello from #{ app_name_string }"
            end
          end
          :_hello_from_brazen_
        end
      end

      Autoloader_[ self, :boxxy ]
    end

    # ~ the custom stack

    class Silo_Daemon < Home_::Silo::Daemon

      # ~ custom exposures

      def workspace_via_qualified_knownness_box box, & oes_p
        WS_via_qualified_knownness_box___.new( box, @silo_module, @kernel, & oes_p ).execute
      end

      # ~ hook-outs / hook-ins

      def precondition_for action, id, box, & oes_p

        _bx = action.to_qualified_knownness_box_proxy

        WS_via_qualified_knownness_box___.new( _bx, @silo_module, @kernel, & oes_p ).execute
      end

      def any_mutated_formals_for_depender_action_formals x

        bx = x.to_mutable_box_like_proxy
        st = COMMON_PROPERTIES_.to_value_stream

        begin
          prp = st.gets
          prp or break
          k = prp.name_symbol
          bx.has_key k and redo
          bx.add k, prp
          redo
        end while nil
        bx
      end
    end

    # ==

    module Magnetics
      Autoloader_[ self ]
    end

    class Magnetics::Workspace_via_Request < Common_::MagneticBySimpleModel  # #stowaway
      # pure glue.

      attr_writer(
        :config_filename,
        :filesystem,
        :listener,
        :max_num_dirs_to_look,
        :workspace_class_by,
        :workspace_path,
      )

      def execute

        _inq = Magnetics::ConfigFileInquiry_via_Request.call_by do |o|
          o.path_head = @workspace_path
          o.max_num_dirs_to_look = @max_num_dirs_to_look
          o.path_tail = @config_filename
          o.filesystem = @filesystem
          o.listener = @listener
        end

        Magnetics::Workspace_via_ConfigFileInquiry.call_by do |o|
          o.config_file_inquiry = _inq
          o.workspace_class_by = @workspace_class_by
          o.listener = @listener
        end
      end
    end

    # ==

    class Magnetics::Workspace_via_ConfigFileInquiry < Common_::MagneticBySimpleModel  # #stowaway

      # using the same underlying mechanics as a "status" inquiry,
      # produce a workspace object IFF the config file is found (lock it);
      # otherwise emit the same *kind* of event (under a different channel).

      attr_writer(
        :config_file_inquiry,
        :listener,
        :workspace_class_by,
      )

      def execute
        if @config_file_inquiry.file_exists
          __yay
        else
          __sad
        end
      end

      def __yay
        inq = remove_instance_variable :@config_file_inquiry
        _cls = @workspace_class_by.call
        _cls.define do |o|
          o.locked_IO = inq.locked_IO
          o.surrounding_path = inq.surrounding_path
          o.config_filename = inq.path_tail
        end
      end

      def __sad
        @listener.call( * @config_file_inquiry.channel ) do
          @config_file_inquiry.event
        end
        UNABLE_
      end
    end

    # ==

    class WS_via_qualified_knownness_box___

      # NOTE: DEPRECATED: use the excellent new magnetics (above this line
      # and as nephews to this file node) instad of this for all new work
      # (since #tombstone-B) - this will be phased out when [br] weens off [br] (sic).

      def initialize bx, sm, k, & oes_p

        @bx = bx
        @kernel = k
        @silo_module = sm
        @on_event_selectively = oes_p

        _ = Common_::Event.produce_handle_event_selectively_through_methods

        @oes_p = _.bookends self, :Workspace_via_qualified_knownness_boX do | * i_a, & ev_p |
          maybe_send_event_via_channel i_a, & ev_p
        end
      end

      def execute

        qkn = @bx.fetch :workspace_path
        if qkn.is_known_known
          ws_path = qkn.value_x
        end

        if ws_path
          __execute_via_workspace_path ws_path
        else

          @on_event_selectively.call :error, :missing_required_properties do

            _prp = Home_.lib_.basic::MinimalProperty.via_variegated_symbol(
              :workspace_path )

            self._COVER_ME__easy_just_refactor__
            # just do Yadda.with :reasons, [_prp]. see #tombstone-A if you must

            Home_.lib_.fields::Events::Missing.for_attribute _prp
          end

          UNABLE_
        end
      end

      def __execute_via_workspace_path ws_path

        @ws = @silo_module.edit_entity @kernel, @oes_p do |o|
          o.edit_with(
            :config_filename, @bx.fetch( :config_filename ).value_x,
            :surrounding_path, @bx.fetch( :workspace_path ).value_x )
        end

        @ws and __via_workspace_produce_existent_workspace_via_qualified_knownness_box @bx
      end

      def __via_workspace_produce_existent_workspace_via_qualified_knownness_box bx

        _did_find = @ws.resolve_nearest_existent_surrounding_path(
          bx.fetch( :max_num_dirs ).value_x,
          :prop, bx.fetch( :workspace_path ).association,
          & @oes_p )

        _did_find and begin

          q = bx[ :verbose ]

          if q && q.is_known_known && q.value_x  # #tracking :+[#069] verbose manually

            maybe_send_event :info, :verbose, :using_workspace do

              Common_::Event.inline_neutral_with(
                :using_workspace,
                :config_path, @ws.existent_config_path
              )
            end
          end

          @ws
        end
      end

      def on_Workspace_via_qualified_knownness_boX_resource_not_found_via_channel i_a, & ev_p

        pair = @bx[ :just_looking ]

        if pair && pair.value_x
          __when_just_looking i_a, & ev_p
        else
          maybe_send_event_via_channel i_a do
            bld_workspace_not_found_event ev_p[]
          end
        end
      end

      def __when_just_looking i_a, & ev_p
        maybe_send_event :info, * i_a[ 1 .. -1 ] do
          ev = ev_p[]
          x_a = ev.to_iambic
          x_a[ 0 ] = :workspace_not_found
          if :ok == x_a[ -2 ]
            x_a[ -1 ] = true
          end
          build_event_via_iambic_and_message_proc x_a, ev.message_proc
        end
        nil
      end

      def bld_workspace_not_found_event ev
        x_a = ev.to_iambic
        x_a[ 0 ] = :workspace_not_found  # was 'resource_not_found'
        x_a.push :invite_to_action, [ :init ]
        build_event_via_iambic_and_message_proc x_a, ev.message_proc
      end

      include Common_::Event::ReceiveAndSendMethods
    end

    # ==
    # ==

    Here_ = self

    # ==
  end
end
# #tombstone-B: moved "config file inquiry.." to own file
# :#tombtone-A temporary
