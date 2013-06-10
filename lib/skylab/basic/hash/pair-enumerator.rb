module Skylab::Basic

  class Hash::Pair_Enumerator < Basic::List::Scanner::For::Array

    def initialize a
      ( a.length % 2 ).zero? or raise ::ArgumentError, "odd number #{
        }of arguments for Hash-like"
      super
    end

    def each_pair &blk
      ea = ::Enumerator.new do |y|
        while ! @eos[]
          y.yield @fetchs[], @fetchs[]
        end
      end
      blk ? ea.each( & blk ) : ea
    end
  end
end
