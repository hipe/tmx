module Skylab::Basic

  module Hash

    class Actors__::Determine_hotstrings

      # notes at spec

      Callback_::Actor.call self, :properties,
        :s_a

      def initialize
        @was_occupied = {}
        @is_occupied = {}
        super
      end

      def execute
        @hotstring_a = ::Array.new @s_a.length
        @s_a.each_with_index do |s, d|
          @index = d
          @string = s
          via_index_and_string_create_hotstring
        end
        flush_rest
        @hotstring_a
      end

      def via_index_and_string_create_hotstring
        @ordinal = 1
        last_ordinal = @string.length
        while @ordinal <= last_ordinal
          @candidate_s = @string[ 0, @ordinal ]
          if @was_occupied[ @candidate_s ]
            @ordinal += 1
            @is_occupied[ @candidate_s ] and adjust_other
            next
          end
          start_hotstring
          break
        end
      end

      def start_hotstring
        @was_occupied[ @candidate_s ] = true
        @is_occupied[ @candidate_s ] = @index
        @hotstring_a[ @index ] = Hotstring__.new @candidate_s
        nil
      end

      def adjust_other
        d = @is_occupied[ @candidate_s ]
        @is_occupied[ @candidate_s ] = nil
        other_s = @s_a[ d ]
        if @ordinal > other_s.length
          @hotstring_a[ d ] = nil  # no soup for you
        else
          new_hotstring = other_s[ 0, @ordinal ]
          @was_occupied[ new_hotstring ] = true
          @is_occupied[ new_hotstring ] = d
          @hotstring_a[ d ].hotstring = new_hotstring
        end
        nil
      end

      def flush_rest
        d = @s_a.length
        while d.nonzero?
          d -= 1
          hs = @hotstring_a[ d ]
          hs or next
          hs.rest = @s_a[ d ][ hs.hotstring.length .. -1 ]
        end ; nil
      end

      Hotstring__ = ::Struct.new :hotstring, :rest
    end
  end
end
