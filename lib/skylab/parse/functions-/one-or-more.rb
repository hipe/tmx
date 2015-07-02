module Skylab::Parse

  # ->

    Functions_::One_Or_More = Home_::Function_::Contiguous_Function_Success_Range.new 1, -1 do

      # ~ #hook-ins for adjunct facets

      def express_all_segments_into_under y, expag

        y << '('
        @f.express_all_segments_into_under y, expag
        y << ')+'

        nil
      end
    end
    # <-
end
