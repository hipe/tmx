module Skylab::Brazen

  class Models_::Workspace < Brazen_::Model_

    class << self
      def filesystem_walk
        Filesystem_Walk__
      end
    end

    Brazen_::Model_::Entity.call self do

      o :desc, -> y do
        y << "manage workspaces."
      end,

      :after, :status,

      :persist_to, :datastore_git_config,

      :preconditions, EMPTY_A_,

      :flag, :property, :dry_run,

      :flag, :property, :verbose,

      :required, :integer_greater_than_or_equal_to, -1, :property, :max_num_dirs,

      :required, :property, :config_filename,

      :required, :property, :path,

      :property, :prop,

      :property, :app_name,

      :property, :on_event_selectively

    end

    def execute

      if @property_box.has_name :on_event_selectively
        @on_event_selectively = nil  # ok to clobber this one from top client
      end

      via_properties_init_ivars

      @pn = Filesystem_Walk__.with(
        :start_path, @path,
        :max_num_dirs_to_look, @max_num_dirs,
        :prop, @prop,
        :filename, @config_filename,
        :on_event_selectively, @on_event_selectively )
    end

    attr_reader :pn

    def any_result_for_flush_for_init
      self.class::Actors__::Init.with(
        :app_name, @app_name,
        :config_filename, @config_filename,
        :is_dry, @dry_run,
        :path, @path,
        :on_event_selectively, @on_event_selectively )
    end

  public

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

    def to_path
      @pn.to_path
    end

    def to_pathname
      @pn
    end

    def datastore_controller_via_entity _ent
      self
    end

    module Actions

      class Ping < Brazen_::Model_::Action

        def produce_any_result
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

    def provide_action_precondition _id, graph
      self
    end

    def receive_missing_required_properties ev  # covered by [tm], #ugly
      receive_missing_required_properties_softly ev
    end

    class << self

      def merge_workspace_resolution_properties_into_via bx, action  # #note-120

        scn = Scan_[].via_nonsparse_array INNER_OUTER_A__
        while pair = scn.gets
          inner_i, outer_i = pair
          if ! bx[ inner_i ]
            x = action.any_argument_value_at_all outer_i
            x and bx.set inner_i, x
          end
        end

        moda = action.modality_adapter
        if moda
          moda.workspace_resolution_properties do |inner_i_, trueish_x|
            trueish_x or next
            bx[ inner_i_ ] and next
            bx.set inner_i_, trueish_x
          end
        end

        if ! bx[ :config_filename ]
          x = config_filename
          x and bx.set :config_filename, x
        end

        if ! bx[ :max_num_dirs ]
          bx.set :max_num_dirs, 1
        end

        nil
      end

      def config_filename
        self::DEFAULT_WS_CONF_FILENAME__
      end

      def set_workspace_config_filename s
        const_set :DEFAULT_WS_CONF_FILENAME__, s.freeze ; nil
      end
    end

    INNER_OUTER_A__ = [
      [ :config_filename, :config_filename ],
      [ :max_num_dirs, :max_num_dirs ],
      [ :path, :workspace_path ]
    ]

    DEFAULT_WS_CONF_FILENAME__ = 'brazen.conf'.freeze

    class Silo_Controller__ < Brazen_.model.silo_controller

      def provide_collection_controller_precon _id, graph
        workspace_via_rising_action graph.action
      end

      def workspace_via_rising_action action
        @action = action
        ws = via_action_produce_workspace_via_object_argument
        ws || via_action_produce_workspace_via_workspace_silo
      end

      def workspace_via_risen_action action
        action.preconditions.fetch :workspace
      end

      def via_action_produce_workspace_via_object_argument
        @action.argument_box[ :workspace ]  # for internal API calls
      end

      def via_action_produce_workspace_via_workspace_silo

        @verbose = @action.any_argument_value_at_all :verbose

        bx = Box_.new
        @model_class.merge_workspace_resolution_properties_into_via bx, @action

        _oes_p = event_lib.
          produce_handle_event_selectively_through_methods.
            bookends self, :ws_via_action do | * i_a, & ev_p |
          maybe_send_event_via_channel i_a, & ev_p
        end

        @ws = @model_class.edited @kernel, _oes_p do |o|
          o.with_arguments :verbose, @verbose
          o.with_argument_box bx
          o.with :prop, @action.class.properties[ :workspace_path ]
        end

        via_ws_workspace
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

    private

      def via_ws_workspace
        if @ws.error_count.zero?
          _ok = @ws.execute  # result is pn
          _ok and begin
            if @verbose  # #tracking [#069] this will probably go away
            maybe_send_event :info, :verbose, :using_workspace do
              build_neutral_event_with :using_workspace,
                :config_pathname, @ws.pn
            end
            end
            @ws
          end
        else
          UNABLE_
        end
      end
    end

    class Filesystem_Walk__  # re-write a subset of [#st-007] the tree walker

      Actor_[ self,
        :properties,
          :filename,
          :max_num_dirs_to_look,
          :prop,
          :start_path,
          :on_event_selectively ]

      def find_any_nearest_file_pathname  # :+#public-API
        execute
      end

      def execute
        normalize_ivars
        work
      end

    private

      def normalize_ivars
        if SLASH_ != @start_path.getbyte( 0 )
          @start_path = ::File.expand_path @start_path
        end
        @start_pathname = ::Pathname.new @start_path
      end

      def work
        st = ::File::Stat.new @start_path
        if DIRECTORY_FTYPE__ == st.ftype
          fnd_any_nearest_file_pathname_when_start_pathname_exist
        else
          whn_start_directory_is_not_directory st
        end
      rescue ::Errno::ENOENT => e
        whn_start_directory_does_not_exist e
      end
      DIRECTORY_FTYPE__ = 'directory'.freeze

      def whn_start_directory_is_not_directory st
        maybe_send_event :error, :start_directory_is_not_directory do
          build_not_OK_event_with :start_directory_is_not_directory,
            :start_pathname, @start_pathname, :ftype, st.ftype,
              :prop, @prop
        end
      end

      def whn_start_directory_does_not_exist e
        maybe_send_event :error, :start_directory_is_not_directory do
          build_not_OK_event_with :start_directory_does_not_exist,
            :start_pathname, @start_pathname, :exception, e,
              :prop, @prop
        end
      end

      def fnd_any_nearest_file_pathname_when_start_pathname_exist
        count = 0

        continue_searching = if -1 == @max_num_dirs_to_look
          NILADIC_TRUTH_
        else
          -> { count < @max_num_dirs_to_look }
        end
        pn = @start_pathname
        while continue_searching[]
          count += 1
          try = pn.join @filename
          try.exist? and break( found = try )
          pn_ = pn.dirname
          pn_ == pn and break  # we've reached the top - the root path
          pn = pn_
        end
        if found
          whn_found found
        else
          whn_resource_not_found count
        end
      end

      def whn_found found
        ok = Brazen_::Lib_::System[].filesystem.normalization.upstream_IO(
          :only_apply_expectation_that_path_is_file,
          :path, found.to_path,
          :on_event, -> ev do
            maybe_send_event normal_top_channel_via_OK_value ev.ok do
              ev
            end
            UNABLE_
          end )
        ok && found
      end

      def whn_resource_not_found count
        maybe_send_event :error, :resource_not_found do
          bld_resource_not_found_event count
        end
      end

      def bld_resource_not_found_event count
        build_not_OK_event_with :resource_not_found, :filename, @filename,
            :num_dirs_looked, count, :start_pathname, @start_pathname do |y, o|
          if o.num_dirs_looked.zero?
            y << "no directories were searched."
          else
            if 1 < o.num_dirs_looked
              d = o.num_dirs_looked - 1
              x = " or #{ d } dir#{ s d } up"
            end
            y << "#{ ick o.filename } not found in #{ pth o.start_pathname}#{x}"
          end
        end
      end
    end

    Workspace_ = self
  end
end
