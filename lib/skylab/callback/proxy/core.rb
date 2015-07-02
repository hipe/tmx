module Skylab::Callback

  module Proxy

    class << self

      def common i, & p
        COMMON__.fetch( i ).call p
      end

      def functional * a, & p
        Proxy_::Functional__.call_via_arglist a, & p
      end

      def inline * a, & p
        Proxy_::Inline__.call_via_arglist a, & p
      end

      def members  # :+[#br-061]
        [ :common, :functional, :inline, :nice, :tee ]
      end

      def nice * a, & p
        Proxy_::Functional__::Nice__.call_via_arglist a, & p
      end

      def tee * a, & p
        Proxy_::Tee__.call_via_arglist a, & p
      end
    end

    Try_convert_iambic_to_pairs_scan_ = -> x_a do
      if 1 == x_a.length
        Home_.lib_.hash_lib.pairs_scan x_a.first
      else
        Home_.lib_.list_lib.pairs_scan_via_even_iambic x_a
      end
    end

    COMMON__ = {
      :<< => -> p do
        ::Enumerator::Yielder.new( & p )
      end
    }

    Proxy_ = self
  end
end
