module Skylab::Brazen

  module Entity

    class Compound_Iambic_Scanner__ < Iambic_Scanner

      def initialize x_a_a
        @current_index_offset = 0
        @d_ = 0 ; @x_a_a = x_a_a ; @x_a_a_length = @x_a_a.length
        while_current_row_is_zero_length_advance
      end

      def current_index
        if @d
          @current_index_offset + @d  # i.e super
        else
          @current_index_offset
        end
      end

      def unparsed_exists
        @d_ != @x_a_a_length
      end

      def advance_one
        @d += 1  # i.e super
        if @x_a_length == @d
          @d_ += 1
          @current_index_offset += @x_a_length
          while_current_row_is_zero_length_advance
        end
      end

    private

      def while_current_row_is_zero_length_advance
        while @d_ != @x_a_a_length
          row = @x_a_a.fetch @d_
          if row.length.nonzero?
            @d = 0 ; @x_a = row ; @x_a_length = row.length
            did_find = true
            break
          end
          @d_ += 1
        end
        if ! did_find
          @d = @x_a = @x_a_length = nil
        end
      end
    end
  end
end
