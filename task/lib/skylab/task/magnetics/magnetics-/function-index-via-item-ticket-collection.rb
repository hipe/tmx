class Skylab::Task

  module Magnetics

    class Magnetics_::FunctionIndex_via_ItemTicketCollection < Common_::Actor::Monadic

      # exactly [#010]

      def initialize itc

        @item_ticket_collection = itc

        @_function_indexes_via_product = Common_::Box.new
        @_function_indexes_via_product_h = @_function_indexes_via_product.h_
        @_functions = []
      end

      def execute

        _itc = remove_instance_variable :@item_ticket_collection
        st = _itc.to_function_item_ticket_stream__
        begin
          fit = st.gets
          fit || break
          ___accept_function_item_ticket fit
          redo
        end while nil
        __finish
      end

      def ___accept_function_item_ticket fit

        d = @_functions.length
        fit.accept_function_offset__ d
        @_functions.push fit

        # be able to get to this function via product name
        # per axiom 1, treat each of the products as if it was its own function

        fit.product_term_symbols.each do |sym|
          @_function_indexes_via_product.touch_array_and_push sym, d
        end

        NIL_
      end

      def __finish
        @_functions.freeze
        @_function_indexes_via_product.freeze
        freeze
      end

      # --

      def to_product_symbol_stream__
        @_function_indexes_via_product.to_name_stream
      end

      def get_functions_that_produce__ sym
        a = @_functions
        @_function_indexes_via_product_h.fetch( sym ).map do |d|
          a.fetch d
        end
      end
    end
  end
end
# #history: rewrite from mag-viz "graph" into function index
