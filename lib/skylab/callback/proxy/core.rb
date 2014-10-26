module Skylab::Callback

  module Proxy

    class << self

      def functional * a, & p
        Proxy_::Functional__.via_arglist a, & p
      end

      def inline * a, & p
        Proxy_::Inline__.via_arglist a, & p
      end

      def members  # :+[#br-061]
        [ :functional, :inline, :nice, :tee ]
      end

      def nice * a, & p
        Proxy_::Functional__::Nice__.via_arglist a, & p
      end

      def tee * a, & p
        Proxy_::Tee__.via_arglist a, & p
      end
    end

    Try_convert_iambic_to_pairs_scan_ = -> x_a do
      if 1 == x_a.length
        Callback_::Lib_::Hash_lib[].pairs_scan x_a.first
      else
        Callback_::Lib_::List_lib[].pairs_scan_via_even_iambic x_a
      end
    end

    Proxy_ = self
  end
end
