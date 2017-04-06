module Skylab::TanMan

  module Models_::Workspace

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
    #   - no subclassing of other applications' action classes. that was awful.
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
        :default_by, -> _action do
          Config_filename_knownness_[]
        end,

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

        if @_inquiry.file_existed
          __when_file_existed
        else
          __when_file_NOT_existed
        end
      end

      def __when_file_NOT_existed

        # it's hard (impossible?) to make this action fail. failure of our
        # dependency does not our failure make. when we get any error (or
        # other) from the the dependency, we convert it to `info`.

        _listener_.call :info, * @_inquiry.channel[ 1..-1 ] do
          @_inquiry.event
        end

        [ :did_not_exist, @_inquiry.unsanitized_path ]
      end

      def __when_file_existed

        # new in #tombstone-B, emit the thing instead of result the thing

        path = @_inquiry.locked_IO.path

        _listener_.call :info, :expression, :resource_existed do |y|
          y << "resource exists - #{ pth path }"
        end

        @_inquiry.locked_IO.close  # #release-locked-file

        [ :existed, path ]
      end
    end

    class Actions::Init

      # #was-promoted

      def definition ; [

        :branch_description, -> y do
          y << "create the #{ val Config_filename_[] } file"
        end,

        # #was-verbose
        # #was-dry-run

        :required, :property, :config_filename,
        :default_by, -> _action do
          Config_filename_knownness_[]
        end,

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

    # ==
    # ==
  end
end
# #history-C: (can be temporary) rewrite "init" for new arch
# #tombstone-B: rewrote "status" with whole new arch
# #tombstone-A: "ping" used to live here
