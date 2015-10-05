module Skylab::Callback

  class Stream

    class As_Mutable_Box

      # we would just subclass box were it not for the fact that box has a
      # subtly different interface than what we want with good reason: for
      # e.g box has `to_value_stream` but because a stream is merely items
      # and not pairs of names and values the word "value" confuses things
      # too much with other uses of the word elsewhere. also it's probably
      # for the better that we don't expose a box interface whole-hog, and
      # rather that we just bring box-like methods in piecemeal as we need
      # them.  #todo :+[#sl-134] this may have changed -- we may now use
      # plain old box this purpose .. maybe do away with this node ..

      class << self
        def via_flushable_stream__ st, method
          bx = new [], {}
          x = st.gets
          while x
            bx.add x.send( method ), x
            x = st.gets
          end
          bx
        end
      end  # >>

      def initialize a, h
        @a = a ; @h = h
      end

      def initialize_copy _
        @a = @a.dup ; @h = @h.dup
      end

      def to_mutable_box_like_proxy
        self
      end

      def to_new_mutable_box_like_proxy
        Stream_::As_Mutable_Box.new @a.dup, @h.dup
      end

      def has_name k
        @h.key? k
      end

      def [] k
        @h[ k ]
      end

      def at_position d
        @h.fetch @a.fetch d
      end

      def to_fetch_proc
        @h.method :fetch
      end

      def fetch k, & p
        @h.fetch k, & p
      end

      def get_names
        @a.dup
      end

      def to_a
        @a.map( & @h.method( :fetch ) )
      end

      def each_value
        @a.each do | sym |
          yield @h.fetch sym
        end ; nil
      end

      def each_pair
        @a.each do | sym |
          yield sym, @h.fetch( sym )
        end ; nil
      end

      # ~ (

      def map_reduce_by & x_p
        to_value_stream.map_reduce_by( & x_p )
      end

      def reduce_by & x_p
        to_value_stream.reduce_by( & x_p )
      end

      # ~ )

      def to_value_stream
        Home_::Stream.via_times @a.length do | d |  # we could make this accomodate growable boxes during iteration if we needed to
          @h.fetch @a.fetch d
        end
      end

      # ~ mutators

      def add_to_front sym, x
        _add_at_position 0, sym, x
      end

      def add sym, x
        _add_at_position @a.length, sym, x
      end

      def _add_at_position d, sym, x
        had = true
        @h.fetch sym do
          @a[ d, 0 ] = [ sym ]
          @h[ sym ] = x
          had = nil
        end
        had and raise ::KeyError, "won't clobber existing '#{ sym }'"
      end

      def touch sym, & p
        @h.fetch sym do
          @a.push sym
          @h[ sym ] = p[]
        end
      end

      def replace i, x
        x_ = @h.fetch i
        @h[ i ] = x
        x_
      end

      def replace_by i, & p
        @h[ i ] = p.call @h.fetch i
        nil
      end

      def remove sym
        @a[ @a.index( sym ), 1 ] = EMPTY_A_
        @h.delete sym
      end

      def a_
        @a
      end
    end
  end
end
