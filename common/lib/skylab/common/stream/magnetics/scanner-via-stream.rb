module Skylab::Common

  class Stream

    class Magnetics::Scanner_via_Stream < MonadicMagneticAndModel  # #[#co-069]

      # etc.

      def initialize up
        @x = up.gets
        @up = up
      end

      def flush_remaining_to_array
        a = []
        begin
          if no_unparsed_exists
            break
          end
          a.push head_as_is
          advance_one
          redo
        end while nil
        a
      end

      def no_unparsed_exists
        ! @x
      end

      def unparsed_exists
        @x
      end

      def gets_one
        if @x
          x = @x
          @x = @up.gets
          x
        else
          raise ::IndexError, _say
        end
      end

      def head_as_is
        if @x
          @x
        else
          raise ::IndexError, _say
        end
      end

      def advance_one
        if @x
          @x = @up.gets
          NIL_
        else
          raise ::IndexError, _say
        end
      end

      def _say
        "polymorphic stream of one item has already been consumed."
      end
    end
  end
end
