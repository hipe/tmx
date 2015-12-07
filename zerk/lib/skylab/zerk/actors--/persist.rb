module Skylab::Zerk
  # ->
    class Actors__::Persist  # notes stow away in [#001] under the "3" suffix

      Callback_::Actor.call self, :properties,
        :path,
        :children,
        :serr,
        :on_event_selectively

      def execute
        @pair_a = []
        @children.each do |cx|
          pair = cx.to_marshal_pair
          pair or next

          if UNDERSCORE_RX__ =~ pair.name_symbol   # note-023
            pair.name_x = pair.name_symbol.id2name.gsub( UNDERSCORE_, DASH_ ).intern
          end

          @pair_a.push pair
        end
        if @pair_a.length.zero?
          when_no_fields
        else
          when_some_fields
        end
      end

      UNDERSCORE_RX__ = /_/

      def when_no_fields

        Home_.lib_.system.filesystem( :Unlink_File ).with(
          :path, @path,
          :if_exists,
          & @on_event_selectively )
      end

      def when_some_fields
        ok = resolve_downstream_directory
        ok && write
      end

      def resolve_downstream_directory
        if @path.include? ::File::SEPARATOR
          do_resolve_downstream_directory
        else
          ACHIEVED_
        end
      end

      def do_resolve_downstream_directory

        _dirname = ::File.dirname @path

        kn = Home_.lib_.system.filesystem( :Existent_Directory ).with(
          :path, _dirname,
          :create_if_not_exist,
          :max_mkdirs, 1,

        ) do | * i_a, & ev_p |
          # hi.
          @on_event_selectively.call( * i_a, & ev_p )
          UNABLE_
        end

        if kn
          ACHIEVED_
        else
          kn
        end
      end

      def write  # assume any dirname of path exists and is a directory

        io = Home_.lib_.system.filesystem( :Downstream_IO ).against_path(
          @path

        ) do | * i_a, & ev_p |

          ev = ev_p[]
          scan = line_scan_for_event ev
          while line = scan.gets
            @serr.write "#{ line } .."
          end
          ev.ok
        end

        if io
          @down_IO = io
          via_down_IO_write
        else
          UNABLE_
        end
      end

      def line_scan_for_event ev

        _expag = Home_.lib_.brazen::API.expression_agent_instance

        ev.to_stream_of_lines_rendered_under _expag
      end

      def via_down_IO_write
        if @down_IO.size.nonzero?
          @down_IO.truncate 0
        end
        _scan = Callback_::Stream.via_nonsparse_array @pair_a
        ok = Home_.lib_.brazen.cfg.write @down_IO,
          _scan, 'current', 'curried-search-and-replace-agent'
        if ok
          @down_IO.close
          @serr.puts " done."
          ACHIEVED_
        else
          @down_IO.close
          @serr.puts " failed."
          ok
        end
      end
    end
  # -
end
