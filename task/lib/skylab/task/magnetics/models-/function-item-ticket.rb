class Skylab::Task

  module Magnetics

    class Models_::Function_ItemTicket

      class << self
        alias_method :via_prerequisites_and_products__, :new
        undef_method :new
      end  # >>

      def initialize pre, pro
        @precondition_term_symbols = pre
        @product_term_symbols = pro
      end

      def accept_function_offset__ d
        @function_offset = d
      end

      def is_monadic
        1 == @precondition_term_symbols.length
      end

      def has_one_product
        1 == @product_term_symbols.length
      end

      def to_precondition_term_symbol_stream_
        Common_::Stream.via_nonsparse_array @precondition_term_symbols
      end

      attr_reader(
        :function_offset,
        :precondition_term_symbols,
        :product_term_symbols,
      )

      def category_symbol
        :function
      end
    end
  end
end
