module Skylab::Callback

  module Scanner

    class << self

      def build_each_pairable_via_pairs_stream_proc & p  # #todo covered by [sg]
        Build_each_pairable_via_pairs_scanner_proc__.new( & p )
      end
    end

    class Build_each_pairable_via_pairs_scanner_proc__

      def initialize & p
        @scn_p = p
      end

      def each_pair
        if block_given?
          scn = @scn_p.call
          while a = scn.gets
            yield( * a )
          end ; nil
        else
          to_enum :each_pair
        end
      end
    end

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
