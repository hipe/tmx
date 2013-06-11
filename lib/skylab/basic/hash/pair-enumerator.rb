module Skylab::Basic

  class Hash::Pair_Enumerator < Basic::List::Scanner::For::Array

    # usage:
    #
    # a `Hash::Pair_Enumerator` must be constructed with an array with an even
    # number of arguments. failure to do so will result in immediate
    # argument error raisal:
    #
    #     Basic::Hash::Pair_Enumerator.new( [ :a, :b, :c ] ) # => ArgumentError: odd number of arguments..
    #
    # so do it right, and you can iterate over those elements using
    # `each_pair` as if it were a hash:
    #
    #     ea = Basic::Hash::Pair_Enumerator.new [ :a, :b, :c, :d ]
    #     ::Hash[ ea.each_pair.to_a ] # => { a: :b, c: :d }
    #
    # that is all.

    def initialize a
      ( a.length % 2 ).zero? or raise ::ArgumentError, "odd number #{
        }of arguments for Hash-like"
      super
    end

    def each_pair &blk
      ea = ::Enumerator.new do |y|
        while ! eos?
          y.yield fetchs, fetchs
        end
      end
      blk ? ea.each( & blk ) : ea
    end
  end
end
