module Skylab::TanMan

  class StackMagnetics_::Graph_via_ItemStream < Common_::Actor::Monadic

    def initialize st
      @__item_stream = st
    end

    def execute
      st = remove_instance_variable :@__item_stream
      gr = Graph___.new
      begin
        item = st.gets
        item || break

        sym = item.item_symbol

        gr.add_item_by do |o|
          o.item_symbol = sym
          o.item_label = item.item_label
          if item.is_first
            o.add_attribute 'style', 'filled'
            o.add_attribute 'color', 'grey'
          end
        end

        a = item.dependency_symbols
        if a
          a.each do |sym_|
            gr.add_association_via sym, sym_
          end
        end
        redo
      end while above
      gr
    end

    # ==

    class Graph___

      def initialize
        @_associations = []
        @_items = []
      end

      def add_item_by
        item = Item___.new
        yield item
        @_items.push item
        NIL
      end

      def add_association_via sym, sym_
        @_associations.push Association___.new( sym, sym_ )
        NIL
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

      def initialize
        @attribute_pairs = nil
      end

      def add_attribute s, s_
        ( @attribute_pairs ||= [] ).push [ s, s_ ] ; nil
      end

      attr_accessor(
        :attribute_pairs,
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
