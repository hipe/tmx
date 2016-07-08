class Skylab::Task

  module Magnetics

    class Models_::Function_ItemTicket

      class << self
        alias_method :via_prerequisites_and_products__, :new
        undef_method :new
      end  # >>

      def initialize pre, pro
        @prerequisite_term_symbols = pre
        @product_term_symbols = pro
      end

      def accept_function_offset__ d
        @function_offset = d
      end

      def is_monadic
        1 == @prerequisite_term_symbols.length
      end

      def has_one_product
        1 == @product_term_symbols.length
      end

      def to_prerequisite_term_symbol_stream_
        Common_::Stream.via_nonsparse_array @prerequisite_term_symbols
      end

      def const
        @___const ||= Const[ @product_term_symbols, @prerequisite_term_symbols ]
      end

      p = Here_.upcase_const_string_via_snake_case_symbol_

      and_ = '_and_'
      via = '_via_'

      andify = -> buff, sym_a do
        buff << p[ sym_a.fetch( 0 ) ]
        d = 0
        last = sym_a.length - 1
        while d < last
          buff << and_ << p[ sym_a.fetch( d += 1 ) ]
        end
      end

      Const = -> product_term_symbols, prerequisite_term_symbols do
        buffer = ""
        andify[ buffer, product_term_symbols ]
        buffer << via
        andify[ buffer, prerequisite_term_symbols ]
        buffer.intern
      end

      attr_reader(
        :function_offset,
        :prerequisite_term_symbols,
        :product_term_symbols,
      )

      def category_symbol
        :function
      end
    end
  end
end
