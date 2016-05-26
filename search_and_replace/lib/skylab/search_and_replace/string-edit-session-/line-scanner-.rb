module Skylab::SearchAndReplace

  class StringEditSession_

      class Line_Scanner_  # :[#011]:

        # a minimal stream that produces "occurrence" structures, one
        # occurrence for each newline sequence in the file (which for now
        # must be represented as one big string (so this won't scale to
        # large files)).
        #
        # each occurrence
        #
        #   • has the character position (not byte position) of the first
        #     character of the newline sequence in the big string.
        #
        #   • knows the character width of the formal sequence.
        #
        # the subject will recognize any of the three known line termination
        # formats, which we are calling "UNIX", "DOS" and "old mac". if the
        # file employs a variety (eek) of formats, this will be detected and
        # will be "self-optimized" for.
        #
        # if the file is not terminated by a line termination sequence (that
        # is, if the file is zero bytes long or its last character is
        # something other than the end of a line terminating sequence),
        # a special zero-width occurence structure is produced as the last
        # item in the stream so that the number of items produced by the
        # stream is related to the number of "lines" in the file allowing
        # that the last line is not well-formed (by the definition of line
        # as suggested by the unix `wc` utility (more at [#sn-020]) or see
        # `man git-log` near `tformat` & separator vs. terminator semantics).
        # (this is :#decision-A).
        #
        # i.e, we still recognize "separator" semantics even though
        # "terminator" semantics may be more formally correct. note this
        # means that the zero-byte file is seen as having one "line" that
        # has no terminator.
        #
        # NOTE this may change if we decide it is is logically more valuable
        # to produce the empty stream in these cases, but this change would
        # only ever pertain to the zero-byte file. in fact, at the moment it
        # is more logically convenient to have it the way that it is
        # currently, which we provisionally "lock" for ":#spot-3".

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
        # on the plus side, this way we conserve more memory because we
        # don't build (on one of our larger typical jobs, for examle)
        # tens of thousands of new strings whose only purpose is to tell
        # us which newline sequence was used at that line WHEW!!

        def initialize string  # #testpoint

          @_gets = :__first_gets
          @_string = string
        end

        def gets
          send @_gets
        end

        def __first_gets

          s = remove_instance_variable :@_string
          if s.length.zero?
            @_gets = :_done
            Zero_Width_Line_Terminator__.new 0
          else
            @_a = THESE___.dup
            @_scn = Home_.lib_.string_scanner.new s
            @_gets = :__main_gets
            send @_gets
          end
        end

        def __main_gets  # assume nonzero remainder

          @_scn.skip ONE_OR_MORE_NOT_LINE_SEPARATOR_CHARACTERS_RX___

          charpos_d = @_scn.charpos

          if @_scn.eos?
            @_gets = :_done
            Zero_Width_Line_Terminator__.new charpos_d
          else

            cls_d = @_a.index do |cls|
              @_scn.skip cls::RX
            end

            if cls_d.nonzero?
              tmp = @_a.fetch cls_d
              @_a[ cls_d ] = @_a.fetch 0
              @_a[ 0 ] = tmp
            end

            if @_scn.eos?
              @_gets = :_done
            end

            @_a.fetch( 0 ).new charpos_d
          end
        end

        def _done
          NOTHING_
        end

        # ==

        ONE_OR_MORE_NOT_LINE_SEPARATOR_CHARACTERS_RX___ = /[^\r\n]+/

        Line_Terminator__ = ::Class.new

        class UNIX___ < Line_Terminator__

          RX = /\n/
          S__ = "\n".freeze

          def sequence_width
            1
          end
        end

        class DOS___ < Line_Terminator__

          RX = /\r\n/
          S__ = "\r\n".freeze

          def sequence_width
            2
          end
        end

        class Old_Mac___ < Line_Terminator__

          RX = /\r/
          S__ = "\r".freeze

          def sequence_width
            1
          end
        end

        THESE___ =  [ UNIX___, DOS___, Old_Mac___ ]

        class Zero_Width_Line_Terminator__ < Line_Terminator__

          def sequence_width
            0
          end

          def string
            EMPTY_S_
          end
        end

        class Line_Terminator__

          def initialize d
            @charpos = d
          end

          def end_charpos
            @___ ||= @charpos + sequence_width
          end

          attr_reader :charpos

          def string
            self.class.const_get :S__, false
          end

          def is_line_termination_sequence_
            true
          end
        end
      end
  end
end
