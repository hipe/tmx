module Skylab::SearchAndReplace

  module Magnetics_::Mutable_File_Session_Stream_via_File_Session_Stream

    class String_Edit_Session___

      class Match_Scanner___

        # each next match

        def initialize s, rx
          @_charpos = 0
          @_gets = :__gets_match_occurrence
          @_last = s.length
          @_rx = rx
          @_string = s
        end

        def gets
          send @_gets
        end

        def __gets_match_occurrence

          md = @_rx.match @_string, @_charpos
          if md
            cp = md.offset( 0 ).last
            if @_last == cp
              @_gets = :_nothing
            elsif @_charpos == cp
              @_charpos += 1  # covered - zero-width match. (else inf. loop)
            else
              @_charpos = cp
            end
            Match_Occurrence___.new md
          else
            @_gets = :_nothing
            NOTHING_
          end
        end

        def _nothing
          NOTHING_
        end

        # ==

        class Match_Occurrence___

          def initialize md
            @charpos, @end_charpos = md.offset 0
            @WHOLE_MATCH_STRING = md[ 0 ]
          end

          def contains_fully eg_newline
            if @charpos <= eg_newline.charpos
              @end_charpos >= eg_newline.end_charpos
            end
          end

          attr_reader(
            :charpos,
            :end_charpos,
          )
        end
      end
    end
  end
end
