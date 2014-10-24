module Skylab::Basic

  class Hash::Order_Proxy

    # a proxy around a hash that tracks in order every key of every `aset` call
    # for dark hacks
    #
    #     h = { }
    #     op = Subject_[].new h
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
