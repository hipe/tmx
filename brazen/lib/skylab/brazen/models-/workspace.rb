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

      surrounding_path = Home_.lib_.system_lib::Filesystem::Walk.call_via_iambic x_a, & oes_p

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

      if config_
        @config_.description_under expag
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

      cfg = _config( & oes_p )
      cfg and begin
        cfg.persist_entity( * x, ent, & oes_p )
      end
    end

    def entity_via_intrinsic_key id, & oes_p
      cfg = _config( & oes_p )
      cfg and begin
        cfg.entity_via_intrinsic_key id, & oes_p
      end
    end

    def to_entity_stream_via_model cls, & oes_p
      cfg = _config( & oes_p )
      cfg and begin
        cfg.to_entity_stream_via_model cls, & oes_p
      end
    end

    def delete_entity act, ent, & oes_p
      cfg = _config( & oes_p )
      cfg and begin
        cfg.delete_entity act, ent, & oes_p
      end
    end

    # ~ for actions

    def resolve_document_ & oes_p
      _config( & oes_p ) ? ACHIEVED_ : UNABLE_
    end

    attr_reader :config_

    # ~ support

    def _config & p
      send ( @_config ||= :__config_initially ), & p
    end

    def __config_initially & p

      _GitConfig = Git_config__[]

      _path = existent_config_path

      doc = _GitConfig::parse_document_by do |o|
        o.upstream_path = _path
        o.listener = p
      end

      if doc

        _entity_collection =
        _GitConfig::Magnetics::EntityCollection_via_Document.new doc

        @config_ = _entity_collection
        @_config = :__config_subsequently
        send @_config
      else
        cfg
      end
    end

    def __config_subsequently
      @config_
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

      # this started out as "pure glue", but then became *the* implementation
      # of [#028.3] (file-lock-based read or read-write sessions of configs)
      #
      # (this absorbed `Workspace_via_ConfigFileInquiry` #history-B.2)

      def initialize
        @_mutex_for_etc = nil
        super
      end

      def do_this_with_mutable_workspace & p

        remove_instance_variable :@_mutex_for_etc
        @_maybe_write_new_document = :__probably_write_new_document
        @_resolve_document = :__resolve_document_mutable
        @_mutable_not_immutable = true
        @_do_this_with_workspace = p ; nil
      end

      def do_this_with_immutable_workspace & p

        remove_instance_variable :@_mutex_for_etc
        @_maybe_write_new_document = :__no_new_document_to_write
        @_resolve_document = :__resolve_document_immutable
        @_mutable_not_immutable = false
        @_do_this_with_workspace = p ; nil
      end

      def workspace_class_by & p
        @workspace_class_proc = p
      end

      def init_workspace_by & p
        @init_workspace_proc = p
      end

      attr_writer(
        :config_filename,
        :filesystem,
        :is_dry_run,
        :listener,
        :max_num_dirs_to_look,
        :workspace_path,
      )

      def execute
        if __locate_and_open_config_file
          ok = __resolve_document
          ok &&= __yield_workspace
          ok &&= __maybe_write_new_document
          __release_locked_resource
          ok && __release_final_user_result
        else
          __whine_about_how_you_couldnt_locate_and_open_config_file
        end
      end

      # -- E. finish

      def __release_final_user_result
        remove_instance_variable :@__mixed_user_result
      end

      def __release_locked_resource  # :#here2, #release-locked-file

        if @_mutable_not_immutable
          remove_instance_variable( :@writable_locked_IO ).close
        else
          remove_instance_variable( :@read_only_locked_IO ).close
        end

        if @_did_build_workspace
          remove_instance_variable( :@__workspace ).close_workspace_session_PERMANENTLY
        end
        NIL
      end

      # -- D. write document

      def __maybe_write_new_document
        if @_mutable_not_immutable
          __probably_write_new_document
        else
          ACHIEVED_
        end
      end

      def __probably_write_new_document

        is_dry = remove_instance_variable :@is_dry_run
        _path = @mutable_document.document_byte_upstream_reference.path
        st = @mutable_document.to_line_stream

        if is_dry
          io = Home_.lib_.system_lib::IO::DRY_STUB
        else
          io = @writable_locked_IO
          io.rewind
          io.truncate 0  # yikes ..
        end

        bytes = 0
        begin
          line = st.gets
          line || break
          bytes += io.write line
          redo
        end while above

        # (don't close the IO yet, that happens #here2)

        _ev = __build_event_about_how_you_wrote_the_new_document do |o|
          o.bytes = bytes
          o.is_dry = is_dry
          o.path = _path
        end

        @listener.call :info, :success, :collection_resource_committed_changes do
          _ev  # for now, built eagerly
        end

        ACHIEVED_
      end

      def __build_event_about_how_you_wrote_the_new_document

        _Mag = Git_config__[]::Mutable::Magnetics::
          WriteDocument_via_Collection::WroteFileEvent_via_Values

        _ev = _Mag.call_by do |o|
          yield o
          o.verb_lemma_symbol = :update
          # the above is always `update` and never :create because we never
          # both create a workspace and write to it in one invocation.
        end
        _ev  # #hi. #todo
      end

      # -- C. yield workspace

      def __yield_workspace

        cls = @workspace_class_proc.call

        same = -> o do
          remove_instance_variable( :@init_workspace_proc )[ o ]

          o.accept_workspace_path_and_config_filename(
            @workspace_path, @config_filename )
        end

        workspace = if @_mutable_not_immutable

          cls.begin_mutable_workspace_session_by do |o|
            o.accept_mutable_document @mutable_document
            same[ o ]
          end
        else
          cls.begin_immutable_workspace_session_by do |o|
            o.accept_immutable_document @immutable_document
            same[ o ]
          end
        end

        user_x = remove_instance_variable( :@_do_this_with_workspace )[ workspace ]

        @_did_build_workspace = true
        @__workspace = workspace

        if user_x
          @__mixed_user_result = user_x ; ACHIEVED_
        else
          user_x
        end
      end

      # -- B. resolve document

      def __resolve_document
        send @_resolve_document
      end

      def __resolve_document_mutable

        doc = Git_config__[]::Mutable.parse_document_by do |o|
          o.upstream_IO = @writable_locked_IO
          o.listener = @listener
        end

        if doc  # #cov1.5
          @mutable_document = doc ; true
        else  # #cov1.4
          doc
        end
      end

      def __resolve_document_immutable

        doc = Git_config__[].parse_document_by do |o|
          o.upstream_IO = @read_only_locked_IO
          o.listener = @listener
        end

        if doc
          @immutable_document = doc ; true
        else
          doc
        end
      end

      # -- A. locate and open config file

      # using the same underlying mechanics as a "status" inquiry,
      # produce a workspace object IFF the config file is found (lock it);
      # otherwise emit the same *kind* of event (under a different channel).

      def __locate_and_open_config_file

        @_did_build_workspace = false  # (sneak this in here)

        inq = Magnetics::ConfigFileInquiry_via_Request.call_by do |o|
          o.path_head = @workspace_path
          o.need_mutable_not_immutable = @_mutable_not_immutable
          o.max_num_dirs_to_look = @max_num_dirs_to_look
          o.path_tail = @config_filename
          o.filesystem = @filesystem
          o.listener = @listener
        end

        if inq.file_existed

          if @_mutable_not_immutable
            @writable_locked_IO = inq.locked_IO
          else
            @read_only_locked_IO = inq.locked_IO
          end

          # if the search had to go upwards to find the directory, for now
          # we just clobber the argument path here with the "corrected" path

          @workspace_path = inq.surrounding_path
          ACHIEVED_
        else
          @config_file_inquiry = inq
          UNABLE_
        end
      end

      def __whine_about_how_you_couldnt_locate_and_open_config_file
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
            __build_workspace_not_found_event ev_p[]
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

      def __build_workspace_not_found_event ev
        x_a = ev.to_iambic
        x_a[ 0 ] = :workspace_not_found  # was 'resource_not_found'
        x_a.push :invite_to_action, [ :init ]
        build_event_via_iambic_and_message_proc x_a, ev.message_proc
      end

      include Common_::Event::ReceiveAndSendMethods
    end

    # ==

    Git_config__ = Lazy_.call do  # 4x
      Home_::CollectionAdapters::GitConfig
    end

    # ==

    Here_ = self

    # ==
  end
end
# #history-B.2: absorb a magnetic into another magnetic
# #tombstone-B: moved "config file inquiry.." to own file
# :#tombtone-A temporary
