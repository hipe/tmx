module Skylab::Brazen

  class Models_::Workspace

    Brazen_::Entity::Event::Simple_Listener_Broadcaster___[ self ]

    class << self

      def status verbose, path, max_num_dirs, prop, listener
        new( verbose, path, max_num_dirs, prop, listener ).status
      end

      def init verbose, path, prop, listener
        new( verbose, path, nil, prop, listener ).init
      end

      private :new
    end

    def initialize verbose, path, max_num_dirs, prop, listener
      @be_verbose = verbose
      @listener = listener
      @max_num_dirs_to_look_in = max_num_dirs
      @path = path
      @prop = prop
      @config_filename = nil
    end

    CONFIG_FILENAME__ = 'brazen.conf'.freeze

    def status
      ok = rslv_any_nearest_config_filename
      ok && self._next_thing_
    end

    def rslv_any_nearest_config_filename
      @any_nearest_config_filename =
        walker( :channel, :walker ).find_any_nearest_file_pathname
    end

    def on_walker_start_directory_does_not_exist ev
      broadcast_entity_event ev ; nil
    end

    def on_walker_start_directory_is_not_directory ev
      broadcast_entity_event ev ; nil
    end

    def on_walker_file_not_found ev
      broadcast_entity_event ev ; nil
    end

    def on_walker_found_is_not_file ev
      broadcast_entity_event ev ; nil
    end

    def init
      x = walker( :channel, :init, :max_num_dirs, 1 ).
        find_any_nearest_file_pathname
      case x
      when false ;
      when true  ; procede_with_init
      else       ; init_when_file_exists x
      end ; nil
    end

    def init_when_file_exists pn
      entity_event :directory_already_has_config_file, :pathname, pn,
        :is_negative, true, :prop, @prop ; nil
    end

    def on_init_start_directory_does_not_exist ev
      broadcast_entity_event ev ; false
    end

    def on_init_start_directory_is_not_directory ev
      broadcast_entity_event ev ; false
    end

    def on_init_found_is_not_file ev
      broadcast_entity_event ev ; false
    end

    def on_init_file_not_found ev
      @be_verbose and broadcast_entity_event ev
      true
    end

    def walker * x_a
      wlk = Walker__.new @path, some_config_filename,
        @max_num_dirs_to_look_in, @prop, self, :walker
      wlk.process_iambic_fully x_a
      wlk
    end

    def some_config_filename
      @config_filename || CONFIG_FILENAME__
    end

    class Walker__  # re-write a subset of [#st-007] the tree walker

      def initialize start_path, filename, any_max_dirs_to_look,
                     prop, listener, chan

        @channel = chan
        @filename = filename
        @listener = listener
        @any_max_num_dirs_to_look = any_max_dirs_to_look
        if SLASH_ != start_path.getbyte( 0 )
          start_path = ::File.expand_path start_path
        end
        @prop = prop
        @start_path = start_path
        @start_pathname = ::Pathname.new start_path
      end

      def find_any_nearest_file_pathname
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
        call_listener :start_directory_is_not_directory,
          :start_pathname, @start_pathname, :ftype, st.ftype,
            :is_negative, true, :prop, @prop
      end

      def whn_start_directory_does_not_exist e
        call_listener :start_directory_does_not_exist,
          :start_pathname, @start_pathname, :exception, e,
            :is_negative, true, :prop, @prop
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
        call_listener :found_is_not_file, :ftype, st.ftype,
            :is_negative, true, :pathname, found do |y, o|
          y << "is #{ o.ftype }, must be file - #{ pth o.pathname }"
        end
      end

      def whn_file_not_found count
        call_listener :file_not_found, :filename, @filename,
            :num_dirs_looked, count, :start_pathname, @start_pathname,
              :is_negative, true do |y, o|
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

    private

      def call_listener * x_a, & p
        p ||= Brazen_::Entity::Event::Inferred_Message.to_proc
        ev = Brazen_::Entity::Event.new x_a, p
        @listener.send :"on_#{ @channel }_#{ ev.terminal_channel_i }", ev
      end

      Brazen_::Entity[ self, :properties, :max_num_dirs, :channel ]

      public :process_iambic_fully

    end
  end
end
