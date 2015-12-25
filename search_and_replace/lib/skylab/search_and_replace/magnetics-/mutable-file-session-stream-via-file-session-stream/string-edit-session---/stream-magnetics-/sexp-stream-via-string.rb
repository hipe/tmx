module Skylab::SearchAndReplace

  module Magnetics_::Mutable_File_Session_Stream_via_File_Session_Stream

    class String_Edit_Session___

      class Stream_Magnetics_::Sexp_Stream_via_String

        # using only the upstream newlines as a determiner, convert any
        # arbitrary string into a stream of [#012] sexp nodes.
        # (this will need to change to close #open [#011].)

        class << self
          def [] sym, s
            o = new
            o.pos = 0
            o.end = s.length
            o.string = s
            o.sexp_symbol_for_context_strings = sym
            o.execute
          end
        end  # >>

        attr_writer(
          :end,
          :pos,
          :string,
          :sexp_symbol_for_context_strings,
        )

        def execute

          scn = Here_::Line_Scanner_.new @string
          scn.pos = @pos
          end_d = @end
          sym = @sexp_symbol_for_context_strings

          if -1 == end_d
            end_d = @string.length
          end

          main = p = -> do

            orig_d = scn.pos
            d = scn.next_newline_before end_d

            if d  # if there is a newline, it's a two-step trick:
              p = -> do
                p = main
                NEWLINE_SEXP_
              end
              _no_newlines_ = @string[ orig_d ... d ]
              [ sym, _no_newlines_ ]

            elsif end_d == scn.pos  # we reached the end of the span
              p = EMPTY_P_
              NOTHING_

            else  # no trailing newline and some content. is last item.
              p = EMPTY_P_
              _no_newlines_ = @string[ scn.pos ... end_d ]
              [ sym, _no_newlines_ ]
            end
          end

          Callback_.stream do
            p[]
          end
        end
      end
    end
  end
end
