module Skylab::TanMan

  class StackMagnetics_::Graph_via_ItemStream < Common_::Actor::Monadic

    def initialize st
      @_graph = Graph___.new
    end

    def execute
      ok = true
      ok && @_graph
    end

    # ==

    class Graph___

      def initialize
        a = []
        a.push Association___.new( :A_node, :B_node )
        a.push Association___.new( :C_node, :B_node )
        @_associations = a
        a = []
        a.push Item___.new( :A_node, "the A node" )
        a.push Item___.new( :B_node, "the B node" )
        a.push Item___.new( :C_node, "the C node" )
        @_items = a
      end

      def to_association_stream
        Common_::Stream.via_nonsparse_array @_associations
      end

      def to_item_stream
        Common_::Stream.via_nonsparse_array @_items
      end
    end

    # ==

    class Item___

      def initialize sym, s
        @item_label = s
        @item_symbol = sym
      end

      attr_reader(
        :item_label,
        :item_symbol,
      )
    end

    # ==

    class Association___

      def initialize fr_sym, to_sym
        @from_symbol = fr_sym
        @to_symbol = to_sym
      end

      attr_reader(
        :from_symbol,
        :to_symbol,
      )
    end
  end
end
