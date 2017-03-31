module Skylab::TanMan

  class Models_::Workspace < Common_::SimpleModel

    # check out this crazy strategy here:
    #
    #   - this node (the actions under it) were originally architected as
    #     (effectively) subclassing those under the [br] stub application
    #
    #   - we temporarily divorce that connection and rewrite the actions
    #     here to be "modern"
    #
    #   - we can then fold the new work here (somehow) back up to the
    #     mentor, either by abstracting or duplicating as appropriate.
    #
    # new design objectives in this version:
    #
    #   - no subclassing of other applications' action classed. that was awful.
    #
    #   - try to use te "toolkit" mentality of keeping things light here.

    # (as class starts #here1)

    Actions = ::Module.new

    class Actions::Status

      # #was-promoted

      def definition ; [

        :branch_description, -> y do
          y << "show the status of the config director{y|ies} active at the path"
        end,

        :property, :config_filename,
        :default, CONFIG_FILENAME__,

        :required, :property, :path,
      ] end

      def initialize
        extend Home_::Model_::CommonActionMethods
        init_action_ yield
      end

      def execute

        rsx = _invocation_resources_

        @_inquiry = Home_.lib_.brazen_NOUVEAU::Models::Workspace::Magnetics::ConfigFileInquiry_via_Request.call_by do |o|
          o.path_head = @path
          o.path_tail = @config_filename
          o.yes_can_expand_path  # #masking
          o.filesystem = rsx.filesystem
          o.listener = rsx.listener
        end

        if @_inquiry.file_exists
          __when_file_exists
        else
          __when_file_NOT_exists
        end
      end

      def __when_file_NOT_exists

        # it's hard (impossible?) to make this action fail. failure of our
        # dependency does not our failure make. when we get any error (or
        # other) from the the dependency, we convert it to `info`.

        _listener_.call :info, * @_inquiry.channel[ 1..-1 ] do
          @_inquiry.event
        end

        [ :did_not_exist, @_inquiry.unsanitized_path ]
      end

      def __when_file_exists

        # new in #tombstone-B, emit the thing instead of result the thing

        path = @_inquiry.locked_IO.path

        _listener_.call :info, :expression, :resource_existed do |y|
          y << "resource exists - #{ pth path }"
        end

        @_inquiry.locked_IO.close  # or whatever

        [ :existed, path ]
      end
    end

    class Actions::Init

      # #was-promoted

      def definition ; [

        :branch_description, -> y do
          y << "create the #{ val CONFIG_FILENAME__ } file"
        end,

        # #was-verbose
        # #was-dry-run

        :required, :property, :config_filename,
        :default, CONFIG_FILENAME__,

        :required, :property, :path,
        :description, -> y do
          y << "the directory to init"
        end,

      ] ; end

      def initialize
        extend Home_::Model_::CommonActionMethods
        init_action_ yield
      end

      def execute

        _app_name_string = Home_.name_function.as_human

        _ = Home_.lib_.brazen_NOUVEAU::Models::Workspace::Magnetics

        _ignored = _::InitWorkspace_via_PathHead_and_PathTail.via(
          :is_dry, false,
          :surrounding_path, @path,
          :config_filename, @config_filename,
          :prop, :path,
          :app_name_string, _app_name_string,
          & _listener_
        )

        # success is covered, failure is not. either way,
        # result does not indicate success or failure here (for now).

        NIL
      end
    end

    # - :#here1

      def initialize
        yield self
        @_with_config = :__with_config_initially
      end

      attr_writer(
        :config_filename,
        :locked_IO,
        :surrounding_path,
      )

      def mutate_and_persist_by

        WRITE_REWRITE___.call_by do |o|
          yield o
          o.document_by = method :__with_mutable_config_document
        end
      end

      def __with_mutable_config_document listener
        __with_config listener do |cfg|
          cfg.with_mutable_document listener do |doc|
            yield doc
          end
        end
      end

      def __with_config listener, & do_this
        send @_with_config, listener, & do_this
      end

      def __with_config_initially listener, & do_this

        # NOTE git config interface is a bit annoying, but we try to sidestep for now

        _GitConfig = Home_.lib_.brazen_NOUVEAU::CollectionAdapters::GitConfig

        doc = _GitConfig.read @locked_IO, & listener

        if doc
          # #cov1.5

          # (that guy is supposed to close the file once it reads it)

          remove_instance_variable :@locked_IO

          @_with_config = :_COVER_ME__easy_but_cover_this__

          yield _GitConfig.new doc, TEMPORARY_STAND_IN_FOR_KERNEL___, & listener
        else
          # #cov1.4
          @_with_config = :_COVER_ME__easy_but_cover_this__
          doc
        end
      end
    # -

    # ==

    class WRITE_REWRITE___ < Common_::MagneticBySimpleModel

      # la la

      def initialize
        yield self
      end

      def mutate_document_by & p
        @mutate_document_by = p
      end

      attr_writer(
        :document_by,
        :is_dry_run,
        :filesystem,
        :listener,
      )

      def execute

        @_is_dry = remove_instance_variable :@is_dry_run  # gotcha

        @document_by.call @listener do |doc|
          @_document = doc
          ok = __mutate_document
          ok &&= __persist
          ok && __emit
          ok && @_bytes
        end
      end

      def __emit

        _Mag = Home_.lib_.brazen_NOUVEAU::CollectionAdapters::
          GitConfig::Mutable::Magnetics::WroteFileEvent_via_Values

        @listener.call :info, :success, :collection_resource_committed_changes do

          _Mag.call_by do |o|
            o.bytes = @_bytes
            o.is_dry = @_is_dry
            o.path = @_path
            o.verb_symbol = :create  # ..
          end
        end
        NIL
      end

      def __persist

        doc = remove_instance_variable :@_document

        @_path = doc.byte_upstream_reference.path
        st = doc.to_line_stream

        io = if @_is_dry
          Home_.lib_.system_lib::IO.dry_stub_instance
        else
          @filesystem.open @_path, ::File::WRONLY
        end

        bytes = 0
        begin
          line = st.gets
          line || break
          bytes += io.write line
          redo
        end while above

        io.close
        @_bytes = bytes ; ACHIEVED_
      end

      def __mutate_document

        _ok = remove_instance_variable( :@mutate_document_by )[ @_document ]
        _ok  # hi. #todo
      end
    end

    # ==

    # ==

    module TEMPORARY_STAND_IN_FOR_KERNEL___ ; class << self
      def do_debug
        false
      end
    end ; end

    # ==

    CONFIG_FILENAME__ = ::File.join 'tan-man-workspace', 'config.ini'

    # ==
    # ==
  end
end
# #history-C: (can be temporary) rewrite "init" for new arch
# #tombstone-B: rewrote "status" with whole new arch
# #tombstone-A: "ping" used to live here
