module Skylab::TanMan

  class Models_::Workspace

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

        @_idiom = Home_.lib_.brazen_NOUVEAU::Toolkit::ConfigFileInquiry.define do |o|
          o.path_head = @path
          o.path_tail = @config_filename
          o.yes_can_expand_path  # #masking
          o.invocation_resources = @_invocation_resources_
        end

        if @_idiom.file_exists
          __when_file_exists
        else
          __when_file_NOT_exists
        end
      end

      def __when_file_NOT_exists

        # it's hard (impossible?) to make this action fail. failure of our
        # dependency does not our failure make. when we get any error (or
        # other) from the the dependency, we convert it to `info`.

        _listener_.call :info, * @_idiom.channel[ 1..-1 ] do
          @_idiom.event
        end

        [ :did_not_exist, @_idiom.unsanitized_path ]
      end

      def __when_file_exists

        # new in #tombstone-B, emit the thing instead of result the thing

        path = @_idiom.locked_IO.path

        _listener_.call :info, :expression, :resource_exists do |y|
          y << "resource exists - #{ pth path }"
        end

        @_idiom.locked_IO.close  # or whatever

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

    # ==

    CONFIG_FILENAME__ = ::File.join 'tan-man-workspace', 'config.ini'

    # ==
    # ==
  end
end
# #history-C: (can be temporary) rewrite "init" for new arch
# #tombstone-B: rewrote "status" with whole new arch
# #tombstone-A: "ping" used to live here
