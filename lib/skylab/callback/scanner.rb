module Skylab::Callback

  module Scanner

    class Puts_Wrapper

      def initialize scn
        @queue = []
        @scn = scn
      end

      def peek
        if @queue.length.zero?
          x = @scn.gets
          x and @queue.push x
        end
        @queue.first
      end

      def advance_one
        gets ; nil
      end

      def gets
        if @queue.length.zero?
          @scn.gets
        else
          @queue.shift
        end
      end

      def puts x
        @queue.push x ; nil
      end
    end
  end
end
