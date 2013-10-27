module Skylab::Basic

  class Rotating_Buffer

    # it's just like tivo
    # like so
    #
    #     rotbuf = Basic::Rotating_Buffer.new 4
    #     rotbuf << :a << :b << :c << :d << :e
    #     rotbuf[ 2 ] # =>  :d
    #     rotbuf[ -1 ] # =>  :e
    #     rotbuf[ -4 ] # =>  :b
    #     rotbuf[ -5 ] # =>  nil
    #     rotbuf[ 0, 4 ] # =>  %i( b c d e )
    #     rotbuf[ -2 .. -1 ] # =>  %i( d e )
    #     rotbuf[ -10 .. -1 ] # =>  nil
    #     rotbuf[ 2, 22 ] # =>  %i( d e )

    # and when you are
    # under buffer
    #
    #     rotbuf = Basic::Rotating_Buffer.new 5
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

    # 'to_a' works on
    # short buffers
    #
    #     r = Basic::Rotating_Buffer.new 3
    #     r << :a << :b
    #     r.to_a  # => %i( a b )

    # 'to_a' works on
    # cycled buffers
    #
    #     r = Basic::Rotating_Buffer.new 3
    #     r << :a << :b << :c << :d
    #     r.to_a  # => %i( b c d )
    #

    def to_a
      self[ - @virtual_buffer_length .. -1 ]
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
        ::Fixnum === l or type_error l, :Integer
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
      ::Fixnum === s or type_error s, :Integer
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
  end
end
