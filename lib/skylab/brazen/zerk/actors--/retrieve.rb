module Skylab::Brazen

  module Zerk

    class Actors__::Retrieve < Persistence_Actor_

      Callback_::Actor.call self, :properties,
        :path,
        :children,
        :on_event_selectively

      def execute
        @up_IO = Brazen_::Lib_::System[].filesystem.normalization.upstream_IO(
          :path, @path,
          :on_event, -> ev do
            if :errno_enoent == ev.terminal_channel_i
              NOTHING_TO_DO_
            else
              write_event_to_serr ev
              ev.ok
            end
          end )
        if @up_IO
          via_IO
        else
          @up_IO
        end
      end

      def via_IO
        _doc = Brazen_.cfg.read @up_IO do |ev|
          write_event_to_serr ev  # or whatever
          UNABLE_
        end
        _doc and begin
          @section = _doc.sections.first
          if @section
            via_section
          else
            when_no_sections
          end
        end
      end

      def when_no_sections
        @on_event_selectively.call :info, :no_sections do
          Brazen_.event.inline_with :no_sections,
              :path, @path, :ok, nil do |y, o |
            y << "no sections found. empty file? - #{ pth o.path }"
          end
        end
        UNABLE_
      end

      def via_section
        @assignments = @section.assignments  # zero asts ok
        via_assignments
      end

      def via_assignments
        scn = @assignments.to_scan
        while @ast = scn.gets
          ok = via_ast
          ok or break
        end
        ok
      end

      def via_ast
        name_i = @ast.normalized_name_i
        @child = @children.detect do |cx|
          name_i == cx.name_i
        end
        if @child
          via_child
        else
          UNABLE_
        end
      end

      def via_child
        @child.marshal_load @ast.value_x do |ev|
          write_event_to_serr ev
          UNABLE_
        end
      end
    end
  end
end
