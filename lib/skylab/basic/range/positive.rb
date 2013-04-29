module Skylab::Basic

  class Range::Positive

    def initialize one, two
      one < 1 and raise "no: #{ one }"
      two < 1 and INFINITY != two and raise "no: #{ two }"
      @begin, @end = one, two
      freeze
    end

    attr_reader :begin, :end

    def describe
      "#{ @begin }-#{ INFINITY == @end ? 'INFINITY' : @end }"
    end

    # life is easer

    INFINITY = -1

    UNBOUNDED = new 1, INFINITY

  end
end
