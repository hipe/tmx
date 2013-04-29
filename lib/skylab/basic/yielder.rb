module Skylab::Basic

  module Yielder

  end

  class Yielder::Counting < ::Enumerator::Yielder

    # do what ::Enumerator::Yielder does but maintain an internal count of
    # how many times either `<<` or `yield` was called.

    def initialize
      super
      @count = 0
    end

    attr_reader :count  # after above

    i_a = %i| yield << |
    i_a_ = ancestors[ 1 ].public_instance_methods( false )

    i_a != i_a_ and fail "greetings from the past - please update me to #{
      }accomodate these new Yielder methods - #{ ( i_a_ - i_a ).inspect }"

    # LOOK we write the below literally just for whatever, readability,
    # but be careful! the below show parallel i_a above

    def yield( * )
      @count += 1
      super
    end

    def <<( * )
      @count += 1
      super
    end
  end
end
