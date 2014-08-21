module Skylab::Brazen

  class Models_::Workspace < Brazen_::Model_

    class << self

      def filesystem_walk
        Filesystem_Walk__
      end

      def status x_a
        new( x_a ).status
      end

      def init x_a
        new( x_a ).init
      end

      private :new
    end

    Brazen_::Model_::Actor[ self,
      :properties, :client, :dry_run, :listener,
      :max_num_dirs, :path, :prop, :verbose ]

    Brazen_::Entity::Event::Cascading_Prefixing_Sender[ self ]

    def initialize x_a
      @config_filename = nil
      @prefix = :workspace
      @max_num_dirs = nil
      process_iambic_fully x_a
    end

    CONFIG_FILENAME__ = 'brazen.conf'.freeze

    def status
      ok = rslv_any_nearest_config_filename
      ok && self._next_thing_
    end

    def rslv_any_nearest_config_filename
      @any_nearest_config_filename =
        filesystem_walk( :channel, :walker ).find_any_nearest_file_pathname
    end

    def on_walker_start_directory_does_not_exist ev
      send_event_structure ev ; nil
    end

    def on_walker_start_directory_is_not_directory ev
      send_event_structure ev ; nil
    end

    def on_walker_file_not_found ev
      send_event_structure ev ; nil
    end

    def on_walker_found_is_not_file ev
      send_event_structure ev ; nil
    end

    def init
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
        :config_filename, @config_filename || CONFIG_FILENAME__,
        :is_dry, @dry_run,
        :listener, @listener,
        :path, @path
      ).init
    end

    def init_when_file_exists pn
      send_event :directory_already_has_config_file, :pathname, pn,
        :is_positive, false, :prop, @prop
      nil
    end

    def on_init_start_directory_does_not_exist ev
      send_event_structure ev ; nil
    end

    def on_init_start_directory_is_not_directory ev
      send_event_structure ev ;  nil
    end

    def on_init_found_is_not_file ev
      send_event_structure ev ; nil
    end

    def on_init_file_not_found ev
      if @verbose
        _ev = ev.dup_with :is_positive, true
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

      Brazen_::Model_::Actor[ self,
        :properties,
          :channel,
          :filename,
          :listener,
          :any_max_num_dirs_to_look,
          :prop,
          :start_path ]

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
        send_event :start_directory_is_not_directory,
          :start_pathname, @start_pathname, :ftype, st.ftype,
            :is_positive, false, :prop, @prop
      end

      def whn_start_directory_does_not_exist e
        send_event :start_directory_does_not_exist,
          :start_pathname, @start_pathname, :exception, e,
            :is_positive, false, :prop, @prop
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
        send_event :found_is_not_file, :ftype, st.ftype,
            :is_positive, false, :pathname, found do |y, o|
          y << "is #{ o.ftype }, must be file - #{ pth o.pathname }"
        end
      end

      def whn_file_not_found count
        send_event :file_not_found, :filename, @filename,
            :num_dirs_looked, count, :start_pathname, @start_pathname,
              :is_positive, false do |y, o|
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

      def send_event * x_a, & p
        p ||= Brazen_::Entity::Event::Inferred_Message.to_proc
        ev = Brazen_::Entity::Event.inline_via_x_a_and_p x_a, p
        m_i = :"on_#{ @channel }_#{ ev.terminal_channel_i }"
        if @listener.respond_to? m_i
          @listener.send m_i, ev
        else
          @listener.send :"on_#{ @channel }_event", ev
        end
      end
    end
  end
end
