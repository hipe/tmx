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

      :property, :max_num_dirs,

      :property, :app_name,

      :property, :prop,

      :property, :path,

      :property, :channel

    end ]

    CONFIG_FILENAME__ = 'brazen.conf'.freeze

    def initialize _
      super
      @config_filename = @verbose = nil
    end

    def execute
      via_properties_init_ivars

      _event_receiver = if @channel
        _Event.receiver.channeled.full @channel, @event_receiver
      else
        @event_receiver
      end

      @pn = Filesystem_Walk__.with :start_path, @path,
        :any_max_num_dirs_to_look, @max_num_dirs,
        :prop, @prop,
        :filename, some_config_filename,
        :event_receiver, _event_receiver
    end

    attr_reader :pn

    def any_result_for_flush_for_init
      self.class::Actors__::Init.with(
        :app_name, @app_name,
        :config_filename, some_config_filename,
        :is_dry, @dry_run,
        :event_receiver, @event_receiver,
        :path, @path
      )
    end

  private

    def some_config_filename
      @config_filename || CONFIG_FILENAME__
    end

  public

    def to_path
      @pn.to_path
    end

    def provide_action_precondition _id, _g
      self
    end

    module Actions
      Autoloader_[ self, :boxxy ]
    end

    class Silo_Controller__ < Brazen_.model.silo_controller

      def provide_collection_controller_precon _identifier, graph
        action = @event_receiver
        @verbose = if action.class.properties.has_name :verbose
          action.any_argument_value :verbose
        end
        s = action.start_path_for_workspace_search_when_precondition
        d = action.max_num_dirs_to_search_when_precondition
        _er = _Event.receiver.channeled.full.cascading :silo_controller_as_precondition, self
        ws = Workspace_.edited _er, @kernel do |o|
          o.with_arguments :verbose, @verbose
          o.with :path, s, :max_num_dirs, d
        end
        if ws.error_count.zero?
          pn = ws.execute
          pn and @ws = ws and via_ws_produce_any_ws_as_precon
        end
      end

      def receive_silo_controller_as_precondition_config_parse_error ev
        _ev_ = ev.dup_with do |y, o|
          Workspace_::Actors__::Render_parse_error[ y, o, self ]
        end
        receive_event _ev_
      end

      def receive_silo_controller_as_precondition_resource_not_found ev
        x_a = ev.to_iambic
        x_a[ 0 ] = :workspace_not_found  # was 'resource_not_found'
        x_a.push :invite_to_action, [ :init ]
        ev_ = build_event_via_iambic x_a
        send_event ev_
        UNABLE_
      end

      def receive_silo_controller_as_precondition_resource_exists ev
        ev.instance_variable_set :@ok, true  # meh  "the file already exists"
        # if @event_receiver.any_argument_value :verbose
        receive_event ev
        # end ; nil
      end

      def receive_silo_controller_as_precondition_event ev  # because '.cascading'
        receive_event ev
      end

    private

      def via_ws_produce_any_ws_as_precon
        if @verbose and
          send_neutral_event_with :using_workspace, :config_pathname, @ws.pn
        end
        @ws
      end
    end

    class Filesystem_Walk__  # re-write a subset of [#st-007] the tree walker

      Actor_[ self,
        :properties,
          :filename,
          :any_max_num_dirs_to_look,
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
        continue_searching = if @any_max_num_dirs_to_look
          -> { count < @any_max_num_dirs_to_look }
        else
          NILADIC_TRUTH_
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
