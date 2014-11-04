module Skylab::Brazen

  class Data_Stores_::Git_Config

    class Actors__::Write

      Callback_::Actor.call self, :properties,

        :downstream_IO,
        :assignment_scan,
        :subsection_name,
        :section_name

      def execute
        ok = resolve_section
        ok &&= resolve_assignment_lines
        ok && flush
      end

      def resolve_section
        _prs = Mock_Parse__.new -> i, * _, & p do
          if :info != i
            raise ev_p[].to_exception
          end
        end
        @section = Git_Config_::Mutable::Section_or_Subsection__.
          via_literals @subsection_name, @section_name, _prs
        @section ? PROCEDE_ : UNABLE_
      end

      def resolve_assignment_lines
        while ast = @assignment_scan.gets
          @section[ ast.name_i ] = ast.value_x
        end
        DONE_
      end

      def flush
        scn = @section.get_line_scanner
        if line = scn.gets
          ok = PROCEDE_
          @downstream_IO.write line
        end
        while line = scn.gets
          @downstream_IO.write line
        end
        ok
      end

      Mock_Parse__ = ::Struct.new :on_event_selectively
    end
  end
end
