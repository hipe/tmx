module Skylab::Brazen

  class Models_::Workspace < Brazen_::Model_

    class << self
      def filesystem_walk
        Filesystem_Walk__
      end
    end

    Brazen_::Model_::Entity[ self, -> do

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

      :property, :channel  # #todo

    end ]

    def execute

      via_properties_init_ivars

      _event_receiver = if @channel
        _Event.receiver.channeled.full @channel, @event_receiver
      else
        @event_receiver
      end

      @pn = Filesystem_Walk__.with :start_path, @path,
        :max_num_dirs_to_look, @max_num_dirs,
        :prop, @prop,
        :filename, @config_filename,
        :event_receiver, _event_receiver
    end

    attr_reader :pn

    def any_result_for_flush_for_init
      self.class::Actors__::Init.with(
        :app_name, @app_name,
        :config_filename, @config_filename,
        :is_dry, @dry_run,
        :event_receiver, @event_receiver,
        :path, @path
      )
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
          _ev = build_OK_event_with :ping do |y, o|
            y << "hello from #{ app_name }"
          end
          send_event _ev
          :_hello_from_brazen_
        end
      end

      Autoloader_[ self, :boxxy ]
    end

    def provide_action_precondition _id, graph
      self
    end

    def receive_missing_required_properties ev
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
        _evr = _Event.receiver.channeled.full.cascading :ws_via_action, self
        @ws = @model_class.edited _evr, @kernel do |o|
          o.with_arguments :verbose, @verbose
          o.with_argument_box bx
          o.with :prop, @action.class.properties[ :workspace_path ]
        end
        via_ws_workspace
      end

      def receive_ws_via_action_missing_required_properties ev
       msg_p = ev.message_proc
       _ev = ev.dup_with do |y, o|
          instance_exec y_=[], o, & msg_p
          y << "cannot resolve workspace because workspace is #{ y_ * SPACE_ }"
        end
        receive_event _ev
      end

      def receive_ws_via_action_config_parse_error ev
        _ev_ = ev.dup_with do |y, o|
          Workspace_::Actors__::Render_parse_error[ y, o, self ]
        end
        receive_event _ev_
      end

      def receive_ws_via_action_resource_not_found ev
        x_a = ev.to_iambic
        x_a[ 0 ] = :workspace_not_found  # was 'resource_not_found'
        x_a.push :invite_to_action, [ :init ]
        _ev_ = build_event_via_iambic_and_message_proc x_a, ev.message_proc
        send_event _ev_
        UNABLE_
      end

      def receive_ws_via_action_resource_exists ev
        ev.instance_variable_set :@ok, true  # meh  "the file already exists"
        # if @event_receiver.any_argument_value :verbose
        receive_event ev
        # end ; nil
      end

      def receive_ws_via_action_event ev  # because '.cascading'
        receive_event ev
      end

    private

      def via_ws_workspace
        if @ws.error_count.zero?
          _ok = @ws.execute  # result is pn
          _ok and begin
            if @verbose
              send_neutral_event_with :using_workspace, :config_pathname, @ws.pn
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
          :event_receiver ]

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
        send_not_OK_event_with :start_directory_is_not_directory,
          :start_pathname, @start_pathname, :ftype, st.ftype,
            :prop, @prop
      end

      def whn_start_directory_does_not_exist e
        send_not_OK_event_with :start_directory_does_not_exist,
          :start_pathname, @start_pathname, :exception, e,
            :prop, @prop
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
          TOP__ == pn.instance_variable_get( :@path ) and break
          pn = pn.dirname
        end
        if found
          whn_found found
        else
          whn_resource_not_found count
        end
      end
      TOP__ = '/'.freeze

      def whn_found found
        st = found.stat  # there is risk
        if FILE_FTYPE__ == st.ftype
          found
        else
          whn_found_is_not_file st, found
        end
      end
      FILE_FTYPE__ = 'file'.freeze

      def whn_found_is_not_file st, found
        send_not_OK_event_with :found_is_not_file, :ftype, st.ftype,
            :pathname, found do |y, o|
          y << "is #{ o.ftype }, must be file - #{ pth o.pathname }"
        end
      end

      def whn_resource_not_found count
        _ev = build_not_OK_event_with :resource_not_found, :filename, @filename,
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
        send_event _ev
      end
    end

    Workspace_ = self
  end
end
