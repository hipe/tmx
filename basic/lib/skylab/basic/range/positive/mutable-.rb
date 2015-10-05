module Skylab::Basic

  class Range::Positive::Mutable_ < Range::Positive  # api private

    def initialize beg, nd
      @begin, @end = beg, nd
      # don't super, avoid freeze. be careful!
    end

    attr_accessor :begin, :end

    def include? fixnum
      if @begin <= fixnum
        if Range::Positive::INFINITY == @end
          true
        else
          @end >= fixnum
        end
      end
    end
  end

  class Range::Positive::Mutable_::OneWay < Range::Positive::Mutable_

    def initialize
      reset
    end

    def reset
      @begin, @end = nil
    end

    def begin= x
      @begin and raise "won't clobber begin"
      @begin = x
    end

    def end= x
      @end and raise "won't clobber end"
      @end = x
    end

    def flush
      r = if @begin
        Range::Positive.new @begin, ( @end || @begin )  # ours not ruby's!
      end
      reset
      r
    end
  end
end
