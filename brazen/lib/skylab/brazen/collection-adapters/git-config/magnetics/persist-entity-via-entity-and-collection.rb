module Skylab::Brazen

  class Collection_Adapters::Git_Config

    class Magnetics::PersistEntity_via_Entity_and_Collection  # 1x

      Attributes_actor_.call( self,
        :downstream_IO,
        :assignment_scan,
        :subsection_name,
        :section_name,
      )

      def execute
        ok = resolve_section
        ok &&= resolve_assignment_lines
        ok && flush
      end

      def resolve_section

        _prs = Mock_Parse__.new -> i, * _, & ev_p do
          if :info != i
            raise ev_p[].to_exception
          end
        end

        _ = Git_Config_::Mutable::Section_or_Subsection__.
          via_literals @subsection_name, @section_name, _prs

        _store :@section, _
      end

      def resolve_assignment_lines
        while ast = @assignment_scan.gets
          @section[ ast.name_symbol ] = ast.value_x
        end
        ACHIEVED_
      end

      def flush
        scn = @section.to_line_stream
        if line = scn.gets
          ok = ACHIEVED_
          @downstream_IO.write line
        end
        while line = scn.gets
          @downstream_IO.write line
        end
        ok
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      Mock_Parse__ = ::Struct.new :handle_event_selectively

      # ==
      # ==
    end
  end
end
