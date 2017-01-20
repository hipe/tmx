class Skylab::Task

  class Eventpoint

    class LineStream_for_Dotfile_via_Graph < Common_::MagneticBySimpleModel

      # intentional feature island, to get feet wet

      # [#ba-021] (`invert`)

      attr_writer(
        :be_inverted,
        :graph,
      )

      # -

        def execute
          @_line = :__first_line
          Common_.stream do
            send @_line
          end.map_by do |s|
            "#{ s }#{ NEWLINE_ }"
          end
        end

        def __first_line
          @_line = :__first_body_line
          "digraph {"
        end

        def __first_body_line
          if @be_inverted
            @_scn = Common_::Scanner.via_array @graph.sources_via_destination.keys
            if @_scn.no_unparsed_exists
              _last_line
            else
              @_main = :__inverted_main
              _do @_main
            end
          else
            @_scn = Common_::Scanner.via_array @graph.nodes_box.a_
            @_main = :__forwards_main
            _do @_main
          end
        end

        def __inverted_main
          @_sym = @_scn.gets_one
          @_sub_scn = Common_::Scanner.via_array(
            @graph.sources_via_destination.fetch( @_sym ) )
          if @_scn.no_unparsed_exists
            @_main = :_last_line
          end
          _do :_details
        end

        def __forwards_main
          begin
            if @_scn.no_unparsed_exists
              x = _last_line
              break
            end
            @_sym = @_scn.gets_one
            a = @graph.nodes_box.fetch( @_sym ).can_transition_to
            a || redo  # island nodes don't get represented
            @_sub_scn = Common_::Scanner.via_array a
            x = _do :_details
            break
          end while above
          x
        end

        def _details  # assume
          sym = @_sub_scn.gets_one
          if @_sub_scn.no_unparsed_exists
            @_line = @_main
          end
          "  #{ @_sym } -> #{ sym }"
        end

        def _last_line
          @_line = :_done
          "}"
        end

        def _do m
          @_line = m
          send m
        end

        def _done
          NOTHING_
        end

      # -
    end
  end
end
# #history: abstracted (with great liberties taken) from sibling corefile
