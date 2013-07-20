module Skylab::Snag

  class Models::Node::Enumerator < ::Enumerator

    def initialize &b
      b or raise ::ArgumentError.new 'block is required'
      @spy = nil
      block = -> y do
        if @spy && ! @spy.empty?
          z = spy_begin y
          b[ z ]
          spy_end
        else
          b[ y ]
        end
      end
      super( & block )
    end

    def each &b  # ( thanks to brian chandler from issue 707 )
      o = catch :last_item do
        super(& b)
        nil
      end
      o and b[ o ]
    end

    def filter! p
      self.class.new do |y|
        each do |x|
          p[ y, x ]
        end
      end
    end

    def valid
      filter! -> y, x do
        if x.valid?
          y << x
        end
      end
    end

    attr_accessor :search

    def seen_count
      @spy[:counting].value[ ]
    end

    spy_struct = ::Struct.new :begin, :yield, :ended, :value

    define_method :with_count! do
      @spy ||= { }
      @spy[:counting] and fail "counting spy already present, reset not impl."
      count = nil
      o = spy_struct.new
      o[:begin] = -> { count = 0 }
      o[:yield] = -> _ { count += 1 }
      o[:ended] = -> { }
      o[:value] = -> { count }
      @spy[:counting] = o
      self
    end

  private

    def spy_begin y
      @spy.values.each { |e| e.begin[ ] }
      Spy_.new( y ){ |item| spy_yield item }
    end

    def spy_end
      @spy.values.each { |e| e.ended[ ] }
    end

    def spy_yield item
      @spy.values.each { |e| e.yield[ item ] }
    end
  end

  class Models::Node::Enumerator::Spy_

    def initialize y, &b
      @b = b or raise ::ArgumentError.new 'block required'
      @y = y
    end

    def yield piece
      @b[ piece ]
      @y.yield piece
    end

    alias_method :<<, :yield
  end
end
