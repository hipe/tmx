module Skylab::SubTree

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
        @item_to_metakey_to_key = nil
      end

      attr_reader :count

      def keys  # not ordered
        @key_to_item.keys
      end

      #  ~ items retrievers ~

      def fetch_first_item
        fetch_item_at_index 0
      end

      def fetch_item_at_index idx
        @item_h.fetch @order_a.fetch( idx )
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

      def get_stream_p
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

      def is_item_under_key item_id, key_x
        (( item_id_ = @key_to_item[ key_x ] )) && item_id_ == item_id
      end

      #  ~ mutators ~

      def add item_x
        item_id = @count += 1
        @item_h[ item_id ] = item_x
        @order_a << item_id
        item_id
      end

      def prepend_key_to_item key_x, item_id
        a = _add_key_to_item_and_get_list key_x, item_id
        a.unshift key_x
        nil
      end

      def append_key_to_item key_x, item_id
        a = _add_key_to_item_and_get_list key_x, item_id
        a << key_x
        nil
      end

      def add_metakeyed_key_to_item metakey_x, key_x, item_id
        check_item_metakey_collision item_id, metakey_x
        @item_to_metakey_to_key[ item_id ][ metakey_x ] = key_x
        append_key_to_item key_x, item_id
        nil
      end

      def add_metakeys_and_key_to_item metakey_a, key_x, item_id
        append_key_to_item key_x, item_id
        metakey_a.each do |metakey_x|
          check_item_metakey_collision item_id, metakey_x
          @item_to_metakey_to_key[ item_id ][ metakey_x ] = key_x
        end
        nil
      end

      def merge_metakeys_and_add_key_to_item metakey_a, key_x, item_id
        append_key_to_item key_x, item_id
        mk_to_k = item_to_metakey_to_key[ item_id ]
        metakey_a.each do |metakey_x|
          if (( kx = mk_to_k[ metakey_x ] ))
            fail "what: #{ kx } <-> #{ key_x } (#{ metakey_x.inspect })"
          else
            mk_to_k[ metakey_x ] = key_x
          end
        end
        nil
      end

      def add_metakey_to_existing_key_of_item metakey_x, key_x, item_id
        check_item_metakey_collision item_id, metakey_x
        check_that_item_is_under_key item_id, key_x
        @item_to_metakey_to_key[ item_id ][ metakey_x ] = key_x
        nil
      end

      def merge_metakeys_to_existing_key_of_item metakey_a, key_x, item_id
        check_that_item_is_under_key item_id, key_x
        mk_to_k = item_to_metakey_to_key[ item_id ]
        metakey_a.each do |metakey_x|
          if (( kx = mk_to_k[ metakey_x ] ))
            kx == key_x or fail "merge collision - #{ kx }, #{ key_x }"
          else
            mk_to_k[ metakey_x ] = key_x
          end
        end
        nil
      end

      def _of_interest
        Of_Interest_[ @order_a, @key_to_item, @item_to_keys, @item_to_metakey_to_key ]
      end

      Of_Interest_ = ::Struct.new :order_a, :key_to_item, :item_to_keys, :item_to_metakey_to_key

      def with_metakey_fetch_node_key mk_x, node_id, &blk
        item_to_metakey_to_key[ node_id ].fetch( mk_x, &blk )
      end

    private

      def check_that_item_is_under_key item_id, key_x
        @key_to_item[ key_x ] == item_id or fail "no it is not."
      end

      def check_item_metakey_collision item_id, metakey_x
        item_to_metakey_to_key[ item_id ].key? metakey_x and
          fail "metakey collision - #{ metakey_x }"
      end

      def item_to_metakey_to_key
        @item_to_metakey_to_key ||= ::Hash.new { |h, node_id| h[node_id] = { } }
      end

    public

      class Keyset_
        def initialize key_a, mkey_h
          @key_a, @mkey_h = key_a, mkey_h
        end
        attr_reader :key_a, :mkey_h
        def _any_multikeys_for key_x
          if @mkey_h
            @mkey_rev ||= begin
              mks = @mkey_h.keys.sort   # eew
              rev_h = ::Hash.new { |h, k| h[ k ] = [ ] }
              mks.each do |k|
                kx = @mkey_h[ k ]
                rev_h[ kx ] << k
              end
              rev_h
            end
            @mkey_rev.fetch key_x do end
          end
        end
      end

      def merge_keyset_to_item keys, item_id
        if keys.key_a  # empty keysets are legit, they appen
          exist_a = ( @item_to_keys[ item_id ] ||= [ ] )
          delta_a = keys.key_a - exist_a
          delta_a.each do |key_x|
            merge_key_to_item keys._any_multikeys_for( key_x ), key_x, item_id
          end
        end
        nil
      end

      def merge_key_to_item mkey_a, key_x, item_id
        if (( item_id_ = @key_to_item[ key_x ] ))
          if item_id_ == item_id
            mkey_a and
              merge_metakeys_to_existing_key_of_item mkey_a, key_x, item_id
            # ok.
          else
            fail "wat do"
          end
        elsif mkey_a
          merge_metakeys_and_add_key_to_item mkey_a, key_x, item_id
        else
          @item_h[ item_id ] or fail "huh?"
          append_key_to_item key_x, item_id
        end
        nil
      end
      private :merge_key_to_item

      def delete_item_and_release_keyset_for item_id  # item may have no keys
        oi = @order_a.index item_id
        it = @item_h[ item_id ]
        oi && it && @count.nonzero? or fail "sanity"
        @order_a[ oi ] = nil ; @order_a.compact!
        @item_h.delete item_id
        if (( ks = @item_to_keys[ item_id ] ))
          ia = ks.map { |k| @key_to_item[ k ] }
          ia.uniq.length == 1 && ia.first == item_id or fail "sanity"
          @item_to_keys.delete item_id
          ks.each { |k| @key_to_item.delete k }
        end
        @count -= 1
        mkey_h = ( item_to_metakey_to_key.delete( item_id ) if
          @item_to_metakey_to_key )
        Keyset_.new ks, mkey_h
      end

      def ownership_transplant_notify new_owner
        @order_a.each do |item_id|
          item = @item_h.fetch( item_id )
          item.multibox_ownership_transfer_notify new_owner
        end
        nil
      end

    private

      def _add_key_to_item_and_get_list key_x, item_id
        @item_h.key?( item_id ) or raise ::KeyError, "no item \"#{ item_id }\""
        @key_to_item.key? key_x and raise ::KeyError,
          say_collision( key_x, item_id )
        @key_to_item[ key_x ] = item_id
        @item_to_keys[ item_id ] ||= [ ]  # IS RESULT
      end

      def say_collision key_x, item_id
        "cannot associate key '#{ key_x }' to item with item_id #{ item_id }#{
          }, that key is already associated with item with item_id #{
          }#{ @key_to_item[ key_x ] }"
      end
    end
  end
end
