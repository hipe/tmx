module Skylab::SearchAndReplace

  module Magnetics_::Mutable_File_Session_Stream_via_File_Session_Stream

    class String_Edit_Session___

      class Line_Scanner_

        def initialize string  # #testpoint
          @_scn = Home_.lib_.string_scanner.new string
        end

        def gets

          @_scn.skip ONE_OR_MORE_NOT_LINE_SEPARATOR_CHARACTERS_RX___

          # the strscan idiom is fundamentally different than the regex idiom
          # in this manner: strscan will never produce a matchdata; it only
          # ever gives you matched strings or offsets (byte or character).
          #
          # as such, some things that are easy in regex make a bit more noise
          # in strscan: either you match the same string sequence against the
          # same regex twice (once for `StringScanner.scan` and a second time
          # as plain old `Regexp.match` to get a matchdata yuck!), -OR- you
          # write it out "longhand" as we do here.
          #
          # on the plus side, this way we conserve memory better because we
          # (on one of our larger refactors, for example) we aren't building
          # tens of thousands of new strings whose only purpose is to tell
          # us which newline sequence was used at that line WHEW!!

          # (per the above last `skip`, you are either at eos or head of etc)

          d = @_scn.charpos

          _d = @_scn.skip UNIX_NEWLINE_RX___

          if _d

            Unix_Line_Terminator___.new d

          elsif @_scn.eos?

            # (for now this method is "optimized" for unix format, and
            # counter-optimized for others..)

            NOTHING_

          else
            _d = @_scn.skip WINDOWS_NEWLINE_RX___
            if _d
              Windows_Line_Terminator___.new d
            else
              _d = @_scn.skip OLD_MAC_NEWLINE_RX___
              if _d
                Old_Mac_Line_Terminator___.new d
              else
                self._COVER_ME_no_trailing_newline
              end
            end
          end
        end

        # ==

        ONE_OR_MORE_NOT_LINE_SEPARATOR_CHARACTERS_RX___ = /[^\r\n]+/
        UNIX_NEWLINE_RX___ = /\n/
        WINDOWS_NEWLINE_RX___ = /\r\n/
        OLD_MAC_NEWLINE_RX___ = /\r/

        Line_Terminator__ = ::Class.new

        class Unix_Line_Terminator___ < Line_Terminator__

          def sequence_width
            1
          end
        end

        class Windows_Line_Terminator___ < Line_Terminator__

          def sequence_width
            2
          end
        end

        class Old_Mac_Line_Terminator___ < Line_Terminator__

          def sequence_width
            1
          end
        end

        # Zero_Width_Line_Terminator___ < Line_Terminator__ ..

        class Line_Terminator__

          def initialize d
            @charpos = d
          end

          def end_charpos
            @___ ||= @charpos + sequence_width
          end

          attr_reader :charpos
        end
      end
    end
  end
end
