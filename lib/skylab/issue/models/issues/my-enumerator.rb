class Skylab::Issue::Models::Issues
  class FunSpy
    def initialize y, &b
      @b = b or raise ArgumentError.new('block required')
      @y = y
    end
    def yield piece
      @b.call(piece)
      @y.yield(piece)
    end
    alias_method :<<, :yield
  end
  class MyEnumerator < ::Enumerator
    # thanks to brian chandler from issue 707
    def each &b
      o = catch(:last_item) do
        super(&b)
        nil
      end
      o and b.call(o)
    end
    def filter &b
      self.class.new do |y|
        each do |*input|
          b.call(y, *input)
        end
      end
    end
    def valid
      filter do |y, item|
        y << item if item.valid?
      end
    end
    def initialize &b
      b or raise ArgumentError.new("block required? (@todo)")
      me = self
      c = ->(y) {
        if me.spy?
          z = me.spy_begin y
          b.call z
          me.spy_end(z)
        else
          b.call y
        end
      }
      super(&c)
    end

    def last_count
      @spy[:counting][:value].call
    end

    attr_accessor :search

    def spy?
      @spy && @spy.any?
    end

    def spy_begin y
      @spy.values.each { |e| e[:begin].call }
      FunSpy.new(y) { |item| spy_yield(item) }
    end

    def spy_end spy
      @spy.values.each { |e| e[:ended].call }
    end

    def spy_yield item
      @spy.values.each { |e| e[:yield].call(item) }
    end

    def with_count!
      (@spy ||= {}).key?(:counting) and fail("figure this out .. (@todo)")
      count = nil
      @spy[:counting] = {
        begin: ->{ count = 0 },
        yield: ->(_){ count += 1 },
        ended: ->{ },
        value: ->{ count }
      }
      self
    end
  end
end

