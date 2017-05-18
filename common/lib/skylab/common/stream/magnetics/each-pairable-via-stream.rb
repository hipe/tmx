module Skylab::Common

  module Scanner

    class << self

      def build_each_pairable_via_pair_stream_by & p  # #todo covered by [sg]
        Each_Pairable_via_Pair_Stream_By___.new( & p )
      end
    end

    class Each_Pairable_via_Pair_Stream_By___

      def initialize & p
        @__p = p
      end

      def each_pair

        if block_given?

          st = @__p.call

          while pair = st.gets
            yield pair.name_symbol, pair.value
          end

          NIL_
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
