module Skylab::Brazen

  class CLI

    class Redundancy_Filter__
      def initialize
        @last_line = nil
      end
      def [] s
        if @last_line
          when_last_line s
        else
          @last_line = s
          s
        end
      end
    private
      def when_last_line s
        "also #{ s }"
      end
    end
  end
end
