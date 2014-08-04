module Skylab::Brazen

  class Models_::Workspace

    Brazen_::Entity::Event::Simple_Listener_Broadcaster___[ self ]

    class << self

      def status verbose, path, max_num_dirs, listener
        new( verbose, path, max_num_dirs, listener ).status
      end

      private :new
    end

    def initialize verbose, path, max_num_dirs, listener
      @be_verbose = verbose
      @listener = listener
      @max_num_dirs_to_look_in = max_num_dirs
      @path = path
      @config_filename = nil
    end

    CONFIG_FILENAME__ = 'brazen.conf'.freeze

    def status
      ok = rslv_any_nearest_config_filename
      ok && self._next_thing_
    end

    def rslv_any_nearest_config_filename
      @any_nearest_config_filename = Walker__.new(
        @path, some_config_filename, @max_num_dirs_to_look_in, self, :walker ).
          find_any_nearest_file_pathname
    end

    def some_config_filename
      @config_filename || CONFIG_FILENAME__
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

    class Walker__  # re-write a subset of [#st-007] the tree walker

      def initialize start_path, filename, any_max_dirs_to_look, listener, chan
        @channel_i = chan
        @filename = filename
        @listener = listener
        @any_max_num_dirs_to_look = any_max_dirs_to_look
        if SLASH_ != start_path.getbyte( 0 )
          start_path = ::File.expand_path start_path
        end
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
            :is_negative, true
      end

      def whn_start_directory_does_not_exist e
        call_listener :start_directory_does_not_exist,
          :start_pathname, @start_pathname, :exception, e,
            :is_negative, true
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
        found || whn_file_not_found( count )
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
        p ||= DEFAULT_MESSAGE_PROC__
        ev = Brazen_::Entity::Event.new x_a, p
        @listener.send :"on_#{ @channel_i }_#{ ev.terminal_channel_i }", ev
      end

      DEFAULT_MESSAGE_PROC__ = -> y, o do
        ( msg = o.terminal_channel_i.to_s ).gsub! UNDERSCORE_, SPACE_
        i = o.first_member
        item_x = o.send i
        if PN_RX__ =~ i.to_s
          item_x = pth item_x
        end
        y << "#{ msg } - #{ item_x }" ; nil
      end

      PN_RX__ = /_pathname\z/

      TOP__ = '/'.freeze
    end
  end
end
