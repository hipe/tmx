module Skylab::BeautySalon

  class Models_::Search_and_Replace

    Preview_Agent_Children__ = ::Module.new

    class Preview_Agent_Children__::Files_Agent < Leaf_Agent_

      def initialize x
        super
        @serr = serr
      end

      def to_body_item_value_string
      end

      def execute
        ok = resolve_values
        ok && work
      end

    private

      def resolve_values
        o = @parent.parent
        @glob_list = o[ :files ].glob_list
        @path_list = o[ :dir ].path_list
        ok = @glob_list && @path_list
        ok && @glob_list.length.nonzero? && @path_list.length.nonzero?

        # since we got to the point of executing this agent at all, the above
        # can be *assumed* to be always true., but we want a last line of
        # defense sanity check# so that we aren't sending nils to the `find`
        # utiltiy. this will fail silently here and shut the whole thing down
        # instead, in cases where they aren't both true-ish.
      end

      def work
        @error_event = nil
        @scan = BS_::Lib_::System[].filesystem.find(
          :filenames, @glob_list,
          :paths, @path_list,
          :on_event_selectively, -> i, *, & ev_p do
            if :info == i
              _ev = ev_p[]
              send_event _ev
            else
              @error_event = ev_p[]
              UNABLE_
            end
          end,
          :as_normal_value, -> command do
            command.to_scan
          end )
        if @scan
          via_scan
        else
          send_event @error_event
        end
      end

      def via_scan
        count = 0
        while line = @scan.gets
          count += 1
          @serr.puts line
        end
        y = @y
        expression_agent.calculate do
          y << "(#{ count } file#{ s count } total)"
        end
        change_agent_to @parent  # necessary, else loop forever
      end
    end
  end
end
