module Skylab::SearchAndReplace

  module Magnetics_::Mutable_File_Session_Stream_via_File_Session_Stream

    class String_Edit_Session___

      class Stream_Magnetics_::Line_Sexp_Array_Stream_via_Newlines

        # (main argument is an array of indexes into newline sequences.)
        # this is near to #open [#011] steamrolling newlines and may need to evolve.

        class << self
          def [] a, d, s
            o = new
            o.indexes = a
            o.pos = d
            o.string = s
            o.sexp_symbol_for_context_strings = :orig_str
            o.execute
          end
        end  # >>

        attr_writer(
          :indexes,
          :pos,
          :sexp_symbol_for_context_strings,
          :string,
        )

        def execute

          s = @string ; sym = @sexp_symbol_for_context_strings

          _ = Callback_::Stream.via_nonsparse_array @indexes

          last_newline = @pos - 1

          _.map_by do | d |
            pos = last_newline + 1
            last_newline = d
            [ [ sym, s[ pos ... d ] ], NEWLINE_SEXP_ ]
          end
        end
      end
    end
  end
end
