module Skylab::Basic

  class Rotating_Buffer  # :[#027].

    def self.[] d
      1 == d ? A_Buffer_Of_One__.new : new( d )
    end

    # construct a rotating buffer with a positive integer indicating the
    # size of the buffer (in terms of number of items). then use `<<`
    # to load items on it progressively, whenever.
    #
    #     rotbuf = Home_::Rotating_Buffer.new 4
    #     rotbuf << :a << :b << :c << :d << :e
    #
    # we have a buffer 4 items "wide" with 5 items having been loaded into
    # it. this means that the first of those five items is no longer
    # stored. for any rotating buffer of size N, we can always imagine that
    # there is an array holding the *last* N items that have been added to
    # the buffer.
    #
    # you can use `[]` to randomly access the items of this imaginary array
    # with most of the familiar idioms of platform arrays.
    #
    # you can send a positive integer thru `[]` to the the item that is
    # at that offset in the imaginary array:
    #
    #     rotbuf[ 2 ]  # =>  :d
    #
    # (there are 4 items in the buffer, the last four are [ :b, :c, :d, :e ],
    #  the item at offset 2 in that imaginary array is `:d`.)
    #
    # you can access items with reference to their offset from the *end* of
    # the imaginary array:
    #
    #     rotbuf[ -1 ] # =>  :e
    #     rotbuf[ -4 ] # =>  :b
    #
    # going off the "left end" of the imaginary array gets you:
    #
    #     rotbuf[ -5 ] # =>  nil
    #
    # on that topic, going off the "right end" of the imaginary array:
    #
    #     rotbuf[ 4 ]  # => nil
    #
    # a range expressed as offset and size:
    #
    #     rotbuf[ 0, 4 ] # =>  %i( b c d e )
    #
    # a range expressed as a range object referencing the end:
    #
    #     rotbuf[ -2 .. -1 ] # =>  %i( d e )
    #
    # going off the left end with a range object gets you:
    #
    #     rotbuf[ -10 .. -1 ] # =>  nil
    #
    # going off the right end with a range like this, however:
    #
    #     rotbuf[ 2, 22 ] # =>  %i( d e )

    # if you haven't yet reached the size limit of your buffer,
    # accessing the last N items will work:
    #
    #     rotbuf = Home_::Rotating_Buffer.new 5
    #     rotbuf << :a << :b << :c
    #     rotbuf[ -3 .. -1 ]  # => %i( a b c )

    def initialize size
      1 < size or self.sanity
      @not_full = true ; @virtual_buffer_length = 0
      @last = size - 1 ; @d = -1 ; @len  = size
      @a = ::Array.new size
    end

    def length
      @len
    end

    attr_reader :virtual_buffer_length

    # you can use `to_a` on a rotating buffer
    # it works on not-yet-cycles buffers:
    #
    #     r = Home_::Rotating_Buffer.new 3
    #     r << :a << :b
    #     r.to_a  # => %i( a b )
    #
    #
    # on a buffer that has cycled, it gives you the last N items:
    #
    #     r = Home_::Rotating_Buffer.new 3
    #     r << :a << :b << :c << :d
    #     r.to_a  # => %i( b c d )

    def to_a
      if @virtual_buffer_length.zero?
        []  # #todo this is inelegant. cover the case
      else
        self[ - @virtual_buffer_length .. -1 ]
      end
    end

    def << x
      if @not_full
        if @len == (( @virtual_buffer_length += 1 ))
          @not_full = false
        end
      end
      if @last == @d
        @a[ @d = 0 ] = x
      else
        @a[ @d += 1 ] = x
      end ; self
    end

    def [] r, l=nil
      is_valid, is_mono, start, length = norm r, l
      if is_valid
        resolve_aref is_mono, start, length
      end
    end

  private

    def resolve_aref is_mono, start, length
      # @d points to the most recently written element. slide that over
      # by the virual buffer length and it points to the virtual first el.
      d = @d - @virtual_buffer_length + 1
      0 > d and d+= @len
        # if it slid off the edge it means we have wrapped. slide it
        # over by length to correct it. now it points to
        # the oldest (i.e first-like) element in the buffer
      d += start
        # slide it over by the requested offset to point to the target
      -1 < d or fail 'sanity'
      d > @last and d -= @len
        # if *this* fell off the right side, we want to wrap again
      if is_mono
        @a[ d ]
      else
        resolve_slice d, length
      end
    end

    def resolve_slice d, length
      if length > @virtual_buffer_length
        length = @virtual_buffer_length  # compress it like ::Array does
      end
      # the target (virtual) slice will be composed of a real RIGHT-hand
      # slice of the buffer plus maybe a real LEFT-hand side.
      if d + length > @len
        # if the cursor plus the target length is longer than the real
        # buffer, we need to wrap around. the right length should be
        right_len = @len - d  # the remainder of the real buffer.
        # the left side real index will always be zero and the left
        # side length is whatever we didn't cover in the right
        left_len = length - right_len
      else
        right_len = length
      end
      right_a = @a[ d, right_len ]
      if left_len
        [ * right_a, * @a[ 0, left_len ] ]
      else
        right_a
      end
    end

    def norm r, l
      if l
        normalize_pair r, l
      elsif ::Range === r
        normalize_range r
      else
        normalize_single r
      end
    end

    def normalize_pair s, l
      if 0 > l then false else
        ::Integer === l or type_error l, :Integer
        s_ = normalize_to_virtual_index s
        if s_
          max_len = @virtual_buffer_length - s_
          l > max_len and l = max_len  # cap it like ::Array does
          [ true, false, s_, l ]
        end
      end
    end

    def normalize_range r
      s = normalize_to_virtual_index r.begin
      e = normalize_to_virtual_index r.end
      if ! ( s && e ) then false else
        l = e - s + 1
        if 0 > l then false else
          [ true, false, s, l ]
        end
      end
    end

    def normalize_single s
      ::Integer === s or type_error s, :Integer
      s_ = normalize_to_virtual_index s
      [ s_, true, s_ ]
    end

    def normalize_to_virtual_index s
      if s < 0
        if -s > @virtual_buffer_length
          false
        else
          @virtual_buffer_length + s
        end
      elsif s >= @virtual_buffer_length
        false
      else
        s
      end
    end

    def type_error x, s
      raise ::TypeError, "no implicit conversion #{
        }of #{ x.class } into #{ s }"
    end

    class A_Buffer_Of_One__  # #experimental

      def initialize

        @to_a_p = -> do ::Array.new 0 end

        @virtual_buffer_length = 0

        @set_p = -> x do

          @virtual_buffer_length = 1

          @to_a_p = -> do [ x ] end

          @set_p = -> x_ do
            x = x_ ; nil
          end ; nil
        end
      end

      def << x
        @set_p[ x ] ; self
      end

      def to_a
        @to_a_p[]
      end

      attr_reader(
        :virtual_buffer_length,
      )

      alias_method :length, :virtual_buffer_length
    end
  end
end
