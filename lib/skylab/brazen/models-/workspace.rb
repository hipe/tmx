module Skylab::Brazen

  class Models_::Workspace < Brazen_::Model_

    class << self
      def build_collections kernel
        Collections__.new kernel
      end

      def filesystem_walk
        Filesystem_Walk__
      end
    end

    Model__ = Brazen_::Model_

    Model__::Entity[ self, -> do
      o :desc, -> y do
        y << "manage workspaces."
      end

      o :after, :status

      o :persist_to, :git_config
    end ]

    Actor_[ self,
      :properties, :client, :channel, :dry_run, :listener,
      :max_num_dirs, :path, :prop, :verbose ]

    Entity_[]::Event::Cascading_Prefixing_Sender[ self ]

    def initialize kernel  # rewrite actor's
      @kernel = kernel
    end

    attr_reader :kernel  # used in unmarshalling for now

  private def init_via_iambic_for_action x_a
      @channel = :workspace
      @config_filename = nil
      @max_num_dirs = nil
      process_iambic_fully x_a
    end

    CONFIG_FILENAME__ = 'brazen.conf'.freeze

    def status a
      init_via_iambic_for_action a
      pn = rslv_any_nearest_config_filename
      pn and status_when_OK pn
    end

    def rslv_any_nearest_config_filename
      @any_nearest_config_filename =
        filesystem_walk( :channel, :walker ).find_any_nearest_file_pathname
    end

    def to_path
      @any_nearest_config_filename.to_path
    end

    def receive_walker_start_directory_does_not_exist ev
      send_event_structure ev ; nil
    end

    def receive_walker_start_directory_is_not_directory ev
      send_event_structure ev ; nil
    end

    def receive_walker_file_not_found ev
      send_event_structure ev ; nil
    end

    def receive_walker_found_is_not_file ev
      send_event_structure ev ; nil
    end

    def status_when_OK pn
      @kernel.models.workspaces.register_instance self, pn
      send_event_with :resource_exists, :pn, pn, :ok, true,
        :is_completion, true
    end

    def edit a
      init_via_iambic_for_action a
      @init_method = nil
      pn = filesystem_walk( :channel, :init, :any_max_num_dirs_to_look, 1 ).
        find_any_nearest_file_pathname
      if pn
        init_when_file_exists pn
      elsif @init_method
        send @init_method
      end
    end

    def procede_with_init
      self.class::Actors__::Init.with(
        :app_name, @client.app_name,
        :channel, @channel,
        :config_filename, @config_filename || CONFIG_FILENAME__,
        :is_dry, @dry_run,
        :listener, @listener,
        :path, @path
      ).init
    end

    def init_when_file_exists pn
      send_event_with :directory_already_has_config_file, :pathname, pn,
        :ok, false, :prop, @prop
      nil
    end

    def receive_init_start_directory_does_not_exist ev
      send_event_structure ev ; nil
    end

    def receive_init_start_directory_is_not_directory ev
      send_event_structure ev ;  nil
    end

    def receive_init_found_is_not_file ev
      send_event_structure ev ; nil
    end

    def receive_init_file_not_found ev
      if @verbose
        _ev = ev.dup_with :ok, ACHEIVED_
        send_event_structure _ev
      end
      @init_method = :procede_with_init ; nil
    end

    def filesystem_walk * x_a
      x_a_ = [ :start_path, @path, :filename, some_config_filename,
        :any_max_num_dirs_to_look, @max_num_dirs, :prop, @prop,
        :listener, self, :channel, :walker ]
      x_a_.concat x_a
      Filesystem_Walk__.with_iambic x_a_
    end

    def some_config_filename
      @config_filename || CONFIG_FILENAME__
    end

    module Actions
      Autoloader_[ self, :boxxy ]
    end

    class Filesystem_Walk__  # re-write a subset of [#st-007] the tree walker

      Actor_[ self,
        :properties,
          :channel,
          :filename,
          :listener,
          :any_max_num_dirs_to_look,
          :prop,
          :start_path ]

      Entity_[]::Event::Cascading_Prefixing_Sender[ self ]

      class << self
        def with * x_a
          with_iambic x_a
        end
        def with_iambic x_a
          new do init_via_iambic x_a end
        end
        private :new
      end

      def initialize & p
        instance_exec( & p )
        freeze
      end

    private

      def init_via_iambic x_a
        process_iambic_fully x_a
        if SLASH_ != @start_path.getbyte( 0 )
          @start_path = ::File.expand_path @start_path
        end
        @start_pathname = ::Pathname.new @start_path
      end

    public def find_any_nearest_file_pathname
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
        send_event_with :start_directory_is_not_directory,
          :start_pathname, @start_pathname, :ftype, st.ftype,
            :ok, false, :prop, @prop
      end

      def whn_start_directory_does_not_exist e
        send_event_with :start_directory_does_not_exist,
          :start_pathname, @start_pathname, :exception, e,
            :ok, false, :prop, @prop
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
          whn_file_not_found count
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
        send_event_with :found_is_not_file, :ftype, st.ftype,
            :ok, false, :pathname, found do |y, o|
          y << "is #{ o.ftype }, must be file - #{ pth o.pathname }"
        end
      end

      def whn_file_not_found count
        send_event_with :file_not_found, :filename, @filename,
            :num_dirs_looked, count, :start_pathname, @start_pathname,
              :ok, false do |y, o|
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

      def listener
        @listener
      end
    end

    def persist_entity ent
      my_datastore.persist_entity_in_collection ent, self
    end

    def retrieve_entity_via_name_and_class id_x, cls, no_p
      @error_count = 0
      my_datastore.retrieve_entity_via_name_class_collection id_x, cls, self, no_p
    end

    def delete_entity_via_action action
      @error_count = 0
      my_datastore.delete_entity_via_action_and_collection action, self
    end

    def my_datastore
      @mds ||= @kernel.datastores[ self.class.persist_to ]
    end

    class Collections__
      def initialize kernel
        @singleton = nil
        @kernel = kernel
      end
      def name_i
        :workspace
      end
      def register_instance ws, _pn
        @singleton and raise "already have a singleton"
        @singleton = ws ; nil
      end
      def instance
        @singleton
      end
    end
  end
end
