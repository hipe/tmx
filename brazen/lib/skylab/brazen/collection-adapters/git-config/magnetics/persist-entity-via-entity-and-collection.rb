module Skylab::Brazen

  class CollectionAdapters::GitConfig

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

        _prs = MockParse__.new -> sym, * _, & ev_p do
          if :info != sym
            raise ev_p[].to_exception
          end
        end

        _ = Here_::Mutable::Section_or_Subsection__.
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
        st = @section.to_line_stream
        line = st.gets
        if line
          d = @downstream_IO.write line
          begin
            line = st.gets
            line || break
            d += @downstream_IO.write( line )
            redo
          end while above
          d
        end
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      MockParse__ = ::Struct.new :handle_event_selectively

      # ==
      # ==
    end
  end
end
