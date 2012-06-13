require_relative 'friendly'

module Skylab::Issue
  Friendly = Models::Issues::Friendly
  class Models::Issues::FunSpy
    extend Friendly
    def initialize y, &b
      @b = b
      @id = self.class.next_id
      $stderr.puts "MADE #{me}"
      @y = y
    end
    def yield piece
      @b.call(piece)
      @y.yield(piece)
    end
    alias_method :<<, :yield
  end
  class Models::Issues::MyEnumerator < ::Enumerator
    # thanks to brian chandler from issue 707
    extend Friendly
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
    def initialize &b
      b or fail("@todo: when does this happen?")
      me = self
      c = ->(y) {
        if me.spy?
          z = nil
          z = Models::Issues::FunSpy.new(y) { |item| me.spy_yield(item, z) }
          me.spy_begin(z)
          b.call z
          me.spy_end(z)
        else
          b.call y
        end
      }
      super(&c)
    end

    attr_accessor :search

    def spy?
      true
    end

    def spy_begin spy
      $stderr.puts "#{me} got spy_begin from #{spy.me}"
    end

    def spy_end spy
      $stderr.puts "#{me} got spy_end from #{spy.me}"
    end

    def spy_yield item, spy
      $stderr.puts "#{me} got spy_end from #{spy.me}"
    end

    def while_counting
      $stderr.puts "THE ENUM who wants to count is: -->#{me}<--"
      self
    end

    def yield_notify item, spy
      $stderr.puts "OMG AWESOME: I AM #{me} and he is ->#{spy.me}<- with item: #{item.class}#{item.object_id}"
    end
  end
end

