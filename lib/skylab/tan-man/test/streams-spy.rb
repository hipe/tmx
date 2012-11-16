module Skylab::TanMan::TestSupport

  TiteColor = ::Skylab::Porcelain::TiteColor

  class StreamsSpy < ::Array
    attr_accessor :debug
    alias_method :debug?, :debug
    def debug!
      @debug = true
      self
    end
    def for name
      @streams[name]
    end

  protected
    def initialize
      @debug = false
      @streams = ::Hash.new do |h, k|
        h[k] = StreamSpy.new(self, k, ->() { debug? } )
      end
    end
    attr_reader :streams
  end

  class StreamSpy

    def puts string
      res = buffer.puts(string)
      line = buffer.string.dup
      buffer.rewind
      buffer.truncate(0)
      unstyled = TiteColor.unstylize_if_stylized line
      if debug_f.call
        $stderr.puts("dbg:#{name}:puts:#{string}#{'(line was colored)' if unstyled}")
      end
      stack.push Line.new(name, unstyled || line)
      res
    end

    def write string
      if debug_f.call
        $stderr.write("dbg:#{name}:write:-->#{string}<--")
      end
      buffer.write(string)
    end

  protected
    def initialize stack, name, debug_f
      @buffer = ::StringIO.new
      @debug_f = debug_f
      @name = name
      @stack = stack
    end

    attr_reader :buffer

    attr_reader :debug_f

    attr_reader :name

    attr_reader :stack

  # --*--

    class Line < ::Struct.new :name, :string ; end
  end
end
