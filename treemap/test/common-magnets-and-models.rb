module Skylab::Treemap::TestSupport

  module Common_Magnets_And_Models

    # NOTE also used by [#cm-016]

    def self.[] tcc
      tcc.include self
    end

    # -

      def mondrian_tree_by_mondrian_choices_and_build_node_tree p, p_
        _nt = build_node_tree_by( & p_ )
        _qt = quantity_tree_via_node_tree _nt
        mondrian_tree_via_quantity_tree _qt, & p
      end

      def mondrian_tree_via_quantity_tree qt, & p
        Home_::Magnetics::MondrianTree_via_QuantityTree[ qt, & p ]
      end

      def quantity_tree_via_node_tree nt
        Home_::Magnetics::QuantityTree_via_Node[ nt ]
      end

      def build_node_tree_by & p
        Home_::Models::Node.define( & p )
      end
    # -

    # ==

    # ==
  end
end
