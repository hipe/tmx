module Skylab::Callback

  class Stream

    class Polymorphic___  # :+[#cb-046]

      # etc.

      def initialize up
        @x = up.gets
        @up = up
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
          fail
        end
      end
    end
  end
end
