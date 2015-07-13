module Skylab::Brazen

  module Zerk

    class Actors__::Retrieve

      Callback_::Actor.call self, :properties,
        :path,
        :children,
        :on_event_selectively

      def execute

        @up_IO = LIB_.system.filesystem( :Upstream_IO ).against_path(
          @path

        ) do | *, & ev_p |

          ev = ev_p[]

          if :errno_enoent == ev.terminal_channel_i
            NOTHING_TO_DO_
          else
            maybe_send_persistence_error ev
            ev.ok
          end
        end

        if @up_IO
          via_IO
        else
          @up_IO
        end
      end

      def via_IO
        doc = Home_.cfg.read @up_IO do |ev|
          @on_event_selectively.call :error do
            ev
          end
          UNABLE_
        end
        doc and begin
          @section = doc.sections.first
          if @section
            via_section
          else
            when_no_sections
          end
        end
      end

      def when_no_sections
        @on_event_selectively.call :info, :no_sections do
          Callback_::Event.inline_with :no_sections,
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
        init_child_name_map
        scn = @assignments.to_stream
        while @ast = scn.gets
          ok = via_ast
          ok or break
        end
        ok
      end

      def init_child_name_map
        # for now we go ahead and hash it all even though lots
        # of nodes here may not be persistable (buttons etc)
        h = {}
        @children.each do |cx|
          h[ cx.name_symbol ] = cx
        end
        @child_via_normal_name_h = h ; nil
      end

      def via_ast
        @name_symbol = @ast.external_normal_name_symbol
        @child = @child_via_normal_name_h[ @name_symbol ]
        if @child
          via_child
        else
          when_no_such_node
        end
      end

      def when_no_such_node
        @on_event_selectively.call :error do
          Callback_::Event.inline_not_OK_with :no_such_node, :name_symbol, @name_symbol
        end
        UNABLE_
      end

      def via_child
        @child.marshal_load @ast.value_x do |ev|
          noun = @child.noun
          _ev_ = ev.with_message_string_mapper -> s, line_index do
            if line_index.zero?
              "couldn't unmarshal #{ noun }: #{ s }"
            else
              s
            end
          end
          maybe_send_persistence_error _ev_
          UNABLE_
        end
      end

      def maybe_send_persistence_error ev
        @on_event_selectively.call :error do
          ev
        end
      end
    end
  end
end
