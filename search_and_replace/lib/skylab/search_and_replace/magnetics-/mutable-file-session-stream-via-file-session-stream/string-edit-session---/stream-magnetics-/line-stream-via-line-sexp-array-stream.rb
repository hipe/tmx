self._MIGHT_CHOP  # #todo

module Skylab::SearchAndReplace

  module Magnetics_::Mutable_File_Session_Stream_via_File_Session_Stream

    class String_Edit_Session___

      module Stream_Magnetics_::Line_stream_via_line_sexp_array_stream

        # the upstream's each item is an array of sexp nodes representing
        # *one* would-be output line with replacements applied. here we
        # simply convert those would-be lines to real lines with no styling,
        # suitable to be the actual lines in the changed file.

        class << self

          def _call st
            st.map_by( & Line_via_line_sexp_array___ )
          end

          alias_method :[], :_call
          alias_method :call, :_call
        end  # >>

          Line_via_line_sexp_array___ = -> x do

            x.reduce "" do | m, x_ |

              if :zero_width == x_.fetch( 0 )
                m
              else
                m << x_.fetch( 1 )
              end
            end
          end

      end
    end
  end
end
