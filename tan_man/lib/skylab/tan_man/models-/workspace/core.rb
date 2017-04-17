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

    # :#here1

    class << self
      alias_method :begin_immutable_workspace_session_by, :new
      alias_method :begin_mutable_workspace_session_by, :begin_immutable_workspace_session_by
      undef_method :new
    end  # >>

    # -
      def initialize
        @_mutex = nil
        yield self
        # can't freeze because #here2
      end

      def HELLO_MY_OWN_WORKSPACE
        NIL  # maybe invocation resources
      end

      def accept_mutable_document doc
        remove_instance_variable :@_mutex
        @_close = :__close_mutable
        @__mutable_document = :_mutable_document
        @mutable_document = doc ; nil
      end

      def accept_immutable_document doc
        remove_instance_variable :@_mutex
        @_close = :__close_immutable
        @__immutable_document = :_immutable_document
        @immutable_document = doc ; nil
      end

      def mutable_document
        send @__mutable_document
      end

      def _mutable_document
        @mutable_document
      end

      def immutable_document
        send @__immutable_document
      end

      def _immutable_document
        @immutable_document
      end

      def accept_workspace_path_and_config_filename ws, cfn
        @workspace_path = ws ; @config_filename = cfn ; nil
      end

      def write_digraph_asset_path_ abs_path, name_symbol, & listener

        # ASSUME path is absolute

        # ("digraph" is the sort of catch-all default section..)

        # (this will probably only ever be used for two fields but meh.)

        normal_path = __normalize_asset_path abs_path, & listener
        if normal_path

          _sect = @mutable_document.sections.touch_section "digraph"

          _ok = _sect.assign normal_path, name_symbol, & listener
            # (this form gets you no emission:) _sect[ :path ] = path

          _ok && normal_path
        else
          normal_path
        end
      end

      # -- asset path & related
      #
      # as it is working out, the most frequent (if not exclusive) use of
      # the config file seems to be for storing & retreiving paths to other
      # files. (the umbrella term for these other files is "asset files".)
      #
      # some of these asset files will have paths that are very near (e.g
      # sibling to) the path to the config file itself. for such cases it
      # "feels wrong" to refer to the asset with a long absolute path when
      # a short, relative path would suffice.
      #
      # this, then, raises the question obliquely which should be answered
      # explicitly, as a point of policy: for those filesystem paths in the
      # config file that are relative, what exactly are they relative to?
      # the "asset directory" is the formal answer to this question.
      #
      # it (again) "feels wrong" to let an "asset directory" be "a thing"
      # unless it's also a directory that we "own". this is why an asset
      # directory has as a prerequisite the "config filename" being at
      # least (and for now exactly) two components long: the tail component
      # is the config filename, and the dirname of it is what we'll use here
      # as the "asset directory".
      #
      # sadly, since the config filename is something that can be set by
      # invocation parameters, this arrangement is something we have to be
      # prepared to fail softly for (maybe) if the config filename doesn't
      # follow this convention.

      def __normalize_asset_path abs_path, & p  # :#here2

        @_normalize_asset_path ||= :__normalize_asset_path_initially
        send @_normalize_asset_path, p, abs_path
      end

      def __normalize_asset_path_initially p, abs_path

        asset_dir = _asset_dir p
        if asset_dir

          @__relative_via_absolute = Home_.lib_.basic::Pathname::Localizer[ asset_dir ]
          send ( @_normalize_asset_path = :__normalize_asset_path_normally ), p, abs_path
        else
          @_normalize_asset_path = :_FAILED
          asset_dir
        end
      end

      def __normalize_asset_path_normally _p, abs_path

        rel_path = @__relative_via_absolute.call abs_path do
          NOTHING_  # hi.
        end
        if rel_path
          rel_path
        else
          abs_path
        end
      end

      def _asset_dir listener
        send ( @_asset_dir ||= :__asset_dir_initially ), listener
      end

      def __asset_dir_initially listener

        cfn = @config_filename

        d = Home_.lib_.basic::String.count_occurrences_in_string_of_string(
          cfn, ::File::SEPARATOR )

        if 1 == d
          @__asset_dir = ::File.join @workspace_path, ::File.dirname( cfn )
          send ( @_asset_dir = :__asset_dir_subsequently ), listener
        else
          self._COVER_ME__this_algorithm_assumes_a_config_filename_of_this_particular_depth__
        end
      end

      def __asset_dir_subsequently _
        @__asset_dir
      end

      # --

      def close_workspace_session_PERMANENTLY  # [br]

        # called after any mutable config document have been written and
        # after the document filehandle (read-only or read-write alike) has
        # been closed (and hence its lock released). it is CRUCIAL for
        # [#br-028.3] data consistency that we don't attempt any more writes
        # OR reads after this point (not only from the filesystem, but from
        # the parsed document structure ("config") as well).
        #
        # following [#sli-129.4] SRP we should then not be using this object
        # at all after this point.
        send @_close
      end

      def __close_mutable
        remove_instance_variable :@mutable_document
        remove_instance_variable :@__mutable_document ; nil
      end

      def __close_immutable
        remove_instance_variable :@immutable_document
        remove_instance_variable :@__immutable_document ; nil
      end

    # -

    # ==
    # ==
  end
end
# #history-C: (can be temporary) rewrite "init" for new arch
# #tombstone-B: rewrote "status" with whole new arch
# #tombstone-A: "ping" used to live here
