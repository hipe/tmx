module Skylab::Basic

  module Hash

    class Hotstrings  # :[#055]

      # notes at spec.

      class << self
        def _call x=nil, y
          new( x, y ).execute
        end
        alias_method :[], :_call
        private :new
      end  # >>

      def initialize blk, s_a
        @_black = blk || MONADIC_EMPTINESS_
        @is_occupied = {}
        @s_a = s_a
        @was_occupied = {}
      end

      def execute
        if @s_a.respond_to? :gets
          __when_stream
        else
          __when_array
        end
        __finish
      end

      def __when_stream
        @hotstring_a = []
        st = remove_instance_variable :@s_a
        @index = -1
        @s_a = []
        begin
          @string = st.gets
          @string or break
          @index += 1
          @s_a[ @index ] = @string
          via_index_and_string_create_hotstring
          redo
        end while nil
        NIL_
      end

      def __when_array
        @hotstring_a = ::Array.new @s_a.length
        @s_a.each_with_index do |s, d|
          @index = d
          @string = s
          via_index_and_string_create_hotstring
        end
        NIL_
      end

      def via_index_and_string_create_hotstring

        @ordinal = 1
        last_ordinal = @string.length

        while @ordinal <= last_ordinal

          @candidate_s = @string[ 0, @ordinal ]

          if @_black[ @candidate_s ]
            @ordinal += 1
            next
          end

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
        NIL_
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
        NIL_
      end

      def __finish
        d = @s_a.length
        while d.nonzero?
          d -= 1
          hs = @hotstring_a[ d ]
          hs or next
          hs.rest = @s_a[ d ][ hs.hotstring.length .. -1 ]
        end
        @hotstring_a
      end

      Hotstring__ = ::Struct.new :hotstring, :rest
    end
  end
end
