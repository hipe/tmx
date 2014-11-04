module Skylab::SubTree

  class API::Actions::Cov

    class Actors__::Produce_uber_tree

      Callback_::Actor.call self, :properties,
        :hub_a, :path, :on_event

      def execute
        ok = normalize
        ok && work
      end

    private

      def normalize
        @hub_a.length.nonzero?
      end

      def work
        ok = resolve_uber_tree
        ok && via_uber_tree_send_cards
      end

      def resolve_uber_tree
        @uber_tree = produce_uber_tree
        @uber_tree ? PROCEDE_ : UNABLE_
      end

      def via_uber_tree_send_cards
        trav = SubTree_::Tree::Traversal.new
        trav.traverse @uber_tree do |node|
          node.prefix = trav.prefix node
          @on_event[ Tree_Line_Card__[ node ] ]
        end
        @on_event[ Done_with_Tree[] ]
        ACHIEVED_
      end

      Tree_Line_Card__ = Data_Event_.new :card

      Done_with_Tree = Data_Event_.new

      def produce_uber_tree  # assume hub_a length nonzero
        if 1 == @hub_a.length
          @hub_a.first.build_combined_tree
        else
          produce_merged_uber_tree
        end
      end

      def produce_merged_uber_tree  # assume hub_a length greater than one
        self._COVER_ME  #  # #open [#011] - - cover this
        tt = @hub_a.map do |x|
          x.build_combined_tree
        end
        a = @path.split SEP_
        need = a.first
        tt.each do |t|
          if need != t.last_isomorphic_key
            t.append_isomorphic_key need
          end
        end
        uber_t = tt.first
        1.up_to( tt.length - 1 ) do |d|  #  # #open [#012] - change this to ..
          t = tt.fetch d
          uber_t.destructive_merge t,
            :key_proc, KEY_PROC__
        end
        uber_t
      end

      KEY_PROC__ = SubTree_::Models::Hub::KEY_PROC
    end
  end
end
# :+#tombstone underwent a refactor exemplary of :+[#bs-015] begin/end hax
