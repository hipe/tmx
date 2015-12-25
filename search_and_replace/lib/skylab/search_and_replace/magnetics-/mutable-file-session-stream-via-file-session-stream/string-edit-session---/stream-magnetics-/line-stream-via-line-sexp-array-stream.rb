module Skylab::SearchAndReplace

  module Magnetics_::Mutable_File_Session_Stream_via_File_Session_Stream

    class String_Edit_Session___

      class Stream_Magnetics_::Line_stream_via_line_sexp_array_stream < Callback_::Actor::Monadic

        # the upstream's each item is an array of sexp nodes representing
        # *one* would-be output line with replacements applied. here we
        # simply convert those would-be lines to real lines with no styling,
        # suitable to be the actual lines in the changed file.

        def initialize st
          @_x_st = st
        end

        def execute
          remove_instance_variable( :@_x_st ).map_by do | x |
            x.reduce "" do | m, x_ |
              m << x_.fetch( 1 )
            end
          end
        end
      end
    end
  end
end
