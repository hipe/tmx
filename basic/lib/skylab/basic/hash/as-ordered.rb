module Skylab::Basic

  class Hash::As_Ordered

    # it acts sort of like a hash, but one that internally tracks the
    # order of every `aset` call (add or update) for dark hacks
    #
    # so it acts like a hash, but it memoizes the order of `aset` keys:
    #
    #     h = { }
    #     op = Home_::Hash::As_Ordered.new h
    #
    #     op[ :foo ] = :bar
    #     op[ :bing ] = :baz
    #     op[ :foo ] = :biff
    #     op[ :boffo ] = :bingo
    #
    #     h.keys       # => [ :foo, :bing, :boffo ]
    #     op.aset_k_a  # => [ :foo, :bing, :foo, :boffo ]
    #
    # happy dark hacking

    def initialize down_h
      @aset_k_a = [ ]
      @down_h = down_h
    end

    attr_reader :aset_k_a

    def key? x
      @down_h.key? x
    end

    def [] k
      @down_h[ k ]
    end

    def []= k, x
      @aset_k_a << k
      @down_h[ k ] = x
    end
  end
end
