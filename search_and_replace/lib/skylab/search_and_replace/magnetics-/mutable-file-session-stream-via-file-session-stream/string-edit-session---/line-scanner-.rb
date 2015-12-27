module Skylab::SearchAndReplace

  module Magnetics_::Mutable_File_Session_Stream_via_File_Session_Stream

    class String_Edit_Session___

      class Line_Scanner_

        # our ad-hoc hand-made parsing scanner that sits at one level higher
        # than platform string scanner, with self-explanatory ad-hoc parsing
        # methods.
        # this is near to #open [#011] the issue with newline steamrolling.

        def initialize string
          @_scn = Home_.lib_.string_scanner.new string
        end

        def pos= d
          @_scn.pos = d
        end

        def eos?
          @_scn.eos?
        end

        def pos
          @_scn.pos
        end

        def string
          @_scn.string
        end

        def advance_to_greatest_index_of_newline_less_than limit_d

          x = nil

          newline_d = nil
          accept = -> do
            x = [ newline_d ]
            accept = -> do
              x.push newline_d ; nil
            end
            NIL_
          end

          begin
            newline_d = next_newline_before limit_d
            if newline_d
              accept[]
              redo
            end
            break
          end while nil
          x
        end

        def next_newline_before limit_d

          orig_d = @_scn.pos
          newline_d = next_newline
          if newline_d
            if newline_d < limit_d
              newline_d
            else
              @_scn.pos = orig_d
              NOTHING_
            end
          end
        end

        def advance_to_lowest_index_of_newline_GTE floor_d

          orig_d = @_scn.pos
          @_scn.pos = floor_d
          d = next_newline
          if d
            self._K
            d
          else
            @_scn.pos = orig_d
            NOTHING_
          end
        end

        def next_newline
          _yes = @_scn.skip_until NEWLINE_RX__
          if _yes
            @_scn.pos - 1
          end
        end

        def string_length
          @_scn.string.length
        end

        attr_reader :_scn  # shh

        NEWLINE_RX__ = /\n/
        STOP_PARSING_ = nil
      end
    end
  end
end
