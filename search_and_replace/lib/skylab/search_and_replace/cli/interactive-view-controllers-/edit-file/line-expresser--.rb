module Skylab::SearchAndReplace

  module CLI

    class Interactive_View_Controllers_::Edit_File

      class Line_Expresser__

        # event-based expression of lines: style the match of interest

        def initialize y
          @line_yielder = y
        end

        attr_writer(
          :render_static,
          :render_match_when_replacement_not_engaged,
          :render_match_when_replacement_engaged,
        )

        def call st
          # CAUTION - we are messing with state in a long-running session
          begin
            tl = st.gets
            tl or break
            @_this_line_string = ""
            @_atom_stream = Stream_[ tl.a ]
            @_done_with_line = false
            begin
              _ = @_atom_stream.gets
              send _
            end until @_done_with_line
            redo
          end while nil
          NIL_
        end

      private

        def match
          @_is_in_a_match = true
          @_match_d = @_atom_stream.gets
          send @_atom_stream.gets
          NIL_
        end

        def repl
          @_replacement_is_engaged = true
        end

        def orig
          @_replacement_is_engaged = false
        end

        def static
          @_is_in_a_match = false ; nil
        end

        def match_continuing  # #not-covered  (i.e #open [#034])
          @_is_in_a_match = true ; nil
        end

        def static_continuing  # #not-covered  (i.e #open [#034])
          @_is_in_a_match = false ; nil
        end

        def content

          _ = @_atom_stream.gets

          __ = if @_is_in_a_match
            if @_replacement_is_engaged
              @render_match_when_replacement_engaged[ @_match_d, _ ]
            else
              @render_match_when_replacement_not_engaged[ @_match_d, _ ]
            end
          else
            @render_static[ _ ]
          end

          @_this_line_string.concat __

          NIL_
        end

        def LTS_begin
          @_this_line_string.concat @_atom_stream.gets
          NIL_
        end

        def LTS_continuing
          ::Kernel._COVER_ME_code_sketch_README
          # (decide me: you never wrap styling across lines despite etc..)
          @_this_line_string.concat @_atom_stream.gets
          NIL_
        end

        def LTS_end
          @line_yielder << remove_instance_variable( :@_this_line_string )
          @_done_with_line = true
          NIL_
        end

      public

        def concat s
          @_this_line_string.concat s ; nil
        end
      end
    end
  end
end
