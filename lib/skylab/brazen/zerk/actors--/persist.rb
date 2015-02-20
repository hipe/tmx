module Skylab::Brazen

  module Zerk

    class Actors__::Persist  # notes stow away in [#062] under the "3" suffix

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
            pair.name_symbol = pair.name_symbol.id2name.gsub( UNDERSCORE_, DASH_ ).intern
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
        LIB_.system.filesystem.normalization.unlink_file(
          :path, @path,
          :if_exists,
          :on_event_selectively, @on_event_selectively )
      end

      def when_some_fields
        ok = resolve_downstream_directory
        ok && write
      end

      def resolve_downstream_directory
        if @path.include? ::File::SEPARATOR
          do_resolve_downstream_directory
        else
          PROCEDE_
        end
      end

      def do_resolve_downstream_directory

        _dirname = ::File.dirname @path

        _valid_arg = LIB_.system.filesystem.normalization.existent_directory(
          :path, _dirname,
          :create_if_not_exist,
          :max_mkdirs, 1 ) do | * i_a, & ev_p |
            @on_event_selectively.call( * i_a, & ev_p )
            UNABLE_
          end

        _valid_arg ? ACHIEVED_ : UNABLE_
      end

      def write  # assume any dirname of path exists and is a directory
        @down_IO = LIB_.system.filesystem.normalization.downstream_IO(
          :path, @path,
          :on_event, -> ev do
            scan = line_scan_for_event ev
            while line = scan.gets
              @serr.write "#{ line } .."
            end
            ev.ok
          end )
        if @down_IO
          via_down_IO_write
        else
          UNABLE_
        end
      end

      def line_scan_for_event ev
        ev.to_stream_of_lines_rendered_under Brazen_::API.expression_agent_instance
      end

      def via_down_IO_write
        if @down_IO.size.nonzero?
          @down_IO.truncate 0
        end
        _scan = Callback_::Stream.via_nonsparse_array @pair_a
        ok = Brazen_.cfg.write @down_IO,
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
  end
end
