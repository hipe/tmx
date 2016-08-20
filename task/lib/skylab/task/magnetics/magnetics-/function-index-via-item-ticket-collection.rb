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
        self  # not freezing self because #here
      end

      # --

      def to_product_symbol_stream__
        @_function_indexes_via_product.to_name_stream
      end

      def get_functions_that_produce_ sym
        d_a = @_function_indexes_via_product[ sym ]
        if d_a
          d_a.map do |d|
            @_functions.fetch d
          end
        else
          NOTHING_
        end
      end

      def read_function_item_ticket_via_const__ const
        @_functions.fetch const_h_.fetch const
      end

      def proc_for_read_function_item_ticket_via_const__
        h = const_h_
        a = @_functions
        -> const do
          a.fetch h.fetch const
        end
      end

      def const_h_
        ( @___foffset_via_const ||= ___index_consts )  # #here
      end

      def ___index_consts
        h = {}
        a = @_functions
        d = a.length
        while d.nonzero?
          d -= 1
          h[ a.fetch( d ).const ] = d
        end
        h
      end
    end
  end
end
# #history: rewrite from mag-viz "graph" into function index
