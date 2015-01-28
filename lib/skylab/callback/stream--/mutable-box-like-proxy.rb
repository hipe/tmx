module Skylab::Callback

  class Stream__

    class Mutable_Box_Like_Proxy

      # we would just subclass box were it not for the fact that box has a
      # subtly different interface than what we want with good reason: for
      # e.g box has `to_value_stream` but because a stream is merely items
      # and not pairs of names and values the word "value" confuses things
      # too much with other uses of the word elsewhere. also it's probably
      # for the better that we don't expose a box interface whole-hog, and
      # rather that we just bring box-like methods in piecemeal as we need
      # them.

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
        Mutable_Box_Like_Proxy.new @a.dup, @h.dup
      end

      def get_names
        @a.dup
      end

      def to_stream
        Callback_.stream.via_times @a.length do | d |  # we could make this accomodate growable boxes during iteration if we needed to
          @h.fetch @a.fetch d
        end
      end

      def to_fetch_proc
        @h.method :fetch
      end

      def has_name k
        @h.key? k
      end

      def [] k
        @h[ k ]
      end

      def fetch k, & p
        @h.fetch k, & p
      end

      # ~ mutators

      def add sym, x
        had = true
        @h.fetch sym do
          @a.push sym
          @h[ sym ] = x
          had = nil
        end
        had and raise ::KeyError, "won't clobber existing '#{ sym }'"
      end

      def replace_by i, & p
        @h[ i ] = p.call @h.fetch i
        nil
      end

      def remove sym
        @a[ @a.index( sym ), 1 ] = EMPTY_A_
        @h.delete sym
      end
    end
  end
end
