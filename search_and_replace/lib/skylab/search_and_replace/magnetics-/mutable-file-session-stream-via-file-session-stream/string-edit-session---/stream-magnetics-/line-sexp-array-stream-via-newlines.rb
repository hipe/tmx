module Skylab::SearchAndReplace

  module Magnetics_::Mutable_File_Session_Stream_via_File_Session_Stream

    class String_Edit_Session___

      class Stream_Magnetics_::Line_Sexp_Array_Stream_via_Newlines

        # (main argument is an array of indexes into newline sequences.)
        # this is near to #open [#011] steamrolling newlines and may need to evolve.

        class << self
          def [] a, d, s
            o = new
            o.newlines = a
            o.pos = d
            o.string = s
            o.execute
          end
        end  # >>

        def initialize
          @newline_stream = nil
          @sexp_symbol_for_context_strings = nil
        end

        attr_writer(
          :newline_stream,
          :newlines,
          :pos,
          :sexp_symbol_for_context_strings,
          :string,
        )

        def execute

          sym = @sexp_symbol_for_context_strings
          if ! sym
            sym = :orig_str
          end

          st = @newline_stream
          if ! st
            st = Callback_::Stream.via_nonsparse_array @newlines
          end

          str = @string

          last_newline = @pos - 1

          st.map_by do | d |
            pos = last_newline + 1
            last_newline = d
            [ [ sym, str[ pos ... d ] ], NEWLINE_SEXP_ ]
          end
        end
      end
    end
  end
end
