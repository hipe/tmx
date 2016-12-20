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

      TestSupport_::Define_dangerous_memoizer.call(
        self, :groceries_A_quantity_tree
      ) do
        _nt = build_node_tree_by do |oo|
          oo.add_child_by do |o|
            o.label_string = 'dairy'  # won't see
            o.add_item 'eggs', 1
            o.add_item 'milk', 3
          end
          oo.add_child_by do |o|
            o.add_item 'bread', 1
            o.add_item 'flour', 3
            o.add_item 'corn', 2
          end
          oo.add_item 'yohoo', 2
        end
        _ = quantity_tree_via_node_tree _nt
        _  # #todo
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
