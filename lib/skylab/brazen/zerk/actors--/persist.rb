module Skylab::Brazen

  module Zerk

    class Actors__::Persist < Persistence_Actor_

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
          @pair_a.push pair
        end
        if @pair_a.length.zero?
          when_no_fields
        else
          when_some_fields
        end
      end

      def when_no_fields
        Brazen_::Lib_::System[].filesystem.normalization.unlink_file(
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
        _dir = Brazen_::Lib_::System[].filesystem.normalization.existent_directory(
          :path, _dirname,
          :create_if_not_exist,
          :max_mkdirs, 1,
          :on_event, -> ev do
            receive_persistence_error ev
            ev.ok  # propagate 'false' in case this is failure
          end )
        _dir ? ACHEIVED_ : UNABLE_
      end

      def write  # assume any dirname of path exists and is a directory
        @down_IO = Brazen_::Lib_::System[].filesystem.normalization.downstream_IO(
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

      def via_down_IO_write
        if @down_IO.size.nonzero?
          @down_IO.truncate 0
        end
        _scan = Callback_.scan.via_nonsparse_array @pair_a
        ok = Brazen_.cfg.write @down_IO,
          _scan, 'current', 'curried-search-and-replace-agent'
        if ok
          @down_IO.close
          @serr.puts " done."
          ACHEIVED_
        else
          @down_IO.close
          @serr.puts " failed."
          ok
        end
      end
    end
  end
end
