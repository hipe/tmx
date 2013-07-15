module Skylab::Porcelain

  module Tree

    class Box_Multi_

      # ( about the name: it's an associative collection whose both keys and
      # values are ordered. when the values are ordered, in skylab parlance
      # we call that a "box". a `multi-map` or `multi-hash` is one that
      # associates many values with one key. this is the opposite - it can
      # associate one value with many keys - hence we swap the order around
      # - it is not a "multi-box" but a "box-multi". sorry. )

      def initialize
        @count = 0
        @item_h = { }
        @order_a = [ ]
        @key_to_item = { }
        @item_to_keys = { }
      end

      attr_reader :count

      def keys  # not ordered
        @key_to_item.keys
      end

      #  ~ items retrievers ~

      def fetch_first_item
        @item_h.fetch @order_a.fetch( 0 )
      end

      def [] k_x                  # retrieve an item by (one of its) keys
        if (( item_id = @key_to_item[ k_x ] ))
          @item_h[ item_id ]
        end
      end

      def get_enumerator          # for each item in order
        ::Enumerator.new do |y|
          @order_a.each do |item_id|
            y << @item_h.fetch( item_id )
          end
          nil
        end
      end

      def get_scanner_p
        hot = true ; idx = 0
        -> do
          if hot
            if idx < @order_a.length
              r = @item_h.fetch @order_a.fetch( idx )
              idx += 1
            else
              hot = false
            end
            r
          end
        end
      end

      def any_only_item           # only item iff count is one item
        if 1 == @count
          @item_h.fetch @order_a.fetch( 0 )
        end
      end

      def fetch_only_item
        @item_h.fetch fetch_only_item_id
      end

      def fetch_only_item_id
        1 == @count or raise ::KeyError, "expected 1, had #{ @count } items"
        @order_a.fetch 0
      end

      def fetch_item_by_id item_id
        @item_h.fetch item_id
      end

      #  ~ services about one item, given its item_id ~

      def count_keys_for item_id
        (( a = @item_to_keys[ item_id ] )) ? a.length : 0
      end

      def fetch_first_key_for item_id
        @item_to_keys.fetch( item_id ).fetch 0
      end

      def fetch_last_key_for item_id
        @item_to_keys.fetch( item_id ).fetch( -1 )
      end

      def fetch_keys_for item_id
        @item_to_keys.fetch( item_id ).dup
      end

      def _fetch_key_a item_id
        @item_to_keys.fetch( item_id )
      end

      #  ~ mutators ~

      def add item_x
        item_id = @count += 1
        @item_h[ item_id ] = item_x
        @order_a << item_id
        item_id
      end

      def delete_and_release_keys_with_item_id item_id
        oi = @order_a.index item_id
        it = @item_h[ item_id ]
        ks = @item_to_keys[ item_id ]
        ia = ks.map { |k| @key_to_item[ k ] }
        oi && it && @count.nonzero? or fail "sanity"
        ia.uniq.length == 1 && ia.first == item_id or fail "sanity"
        @order_a[ oi ] = nil ; @order_a.compact!
        @item_h.delete item_id
        ks = @item_to_keys.delete item_id
        ks.each { |k| @key_to_item.delete k }
        @count -= 1
        ks
      end

      def prepend_key_to_item key_x, item_id
        get_item_keys( item_id, key_x ).unshift key_x
        nil
      end

      def append_key_to_item key_x, item_id
        get_item_keys( item_id, key_x ) << key_x
        nil
      end

      def merge_keys_to_item key_a, item_id
        a = ( @item_to_keys[ item_id ] ||= [ ] )
        a.concat( key_a - a )
        nil
      end

      def delete_by_item_id item_id
        idx = @order_a.index( item_id ) or raise ::KeyError, "- #{ item_id }"
        @order_a[ idx ] = nil ; @order_a.compact!
        @count -= 1
        @item_h.delete item_id
        ks = @item_to_keys.delete item_id
        ks.each do |k|
          @key_to_item.delete k
        end
        ks
      end

    private

      def get_item_keys item_id, key_x
        @item_h.key?( item_id ) or raise ::KeyError, "no item \"#{ item_id }\""
        @key_to_item.key? key_x and raise ::KeyError, "occupied \"#{ key_x }\""
        @key_to_item[ key_x ] = item_id
        @item_to_keys[ item_id ] ||= [ ]
      end
    end
  end
end
