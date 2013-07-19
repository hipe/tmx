module Skylab::CovTree

  class API::Actions::Cov

    class Treeer_

      MetaHell::Funcy[ self ]

      MetaHell::FUN.fields[ self, :hub_a, :arg_pn, :card_p ]

      def execute
        @hub_a.length.nonzero? or fail "sanity"
        begin
          r = uber_tree = get_uber_tree or break
          trav = Porcelain::Tree::Traversal.new
          trav.traverse uber_tree do |card|
            card.prefix = trav.prefix card
            @card_p[ card ]
          end
          r = true
        end while nil
        r
      end

    private

      def get_uber_tree
        case @hub_a.length
        when 0 ; fail "sanity"
        when 1
          @hub_a.first.get_tree_combined
        else
          get_merged_uber_tree
        end
      end

      def get_merged_uber_tree
        tt = @hub_a.map( & :get_tree_combined )
        a = @arg_pn.to_s.split SEP_
        need = a.first
        tt.each do |t|
          t.last_isomorphic_key == need or t.append_isomorphic_key need
        end
        uber_t = tt.shift
        begin
          t = tt.shift
          uber_t.destructive_merge t,
            :key_proc, CovTree::Models::Hub::KEY_PROC_
        end while tt.length.nonzero?
        uber_t
      end
    end
  end
end
