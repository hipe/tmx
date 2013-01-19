module Skylab::Headless
  class Services::Patch::Models::Chunk

    attr_reader :left
    attr_reader :right

  protected

    def initialize
      @left = Side.new
      @right = Side.new
    end
  end

  class Services::Patch::Models::Chunk::Side

    def << line
      @range.inc!
      @lines << line
      nil
    end

    def any?
      ! empty?
    end

    def empty?
      # for fun we do this the risky when we could just ..
      -1 == ( @range.end - @range.begin )
    end

    def line_count
      @lines.length
    end

    def lines
      @lines.dup
    end

    attr_reader :range

  protected

    def initialize
      @range = Range.new
      @lines = []
    end
  end

  class Services::Patch::Models::Chunk::Side::Range

    attr_reader :begin

    def begin= int
      @begin = int
      @end = int - 1
    end

    attr_reader :end

    def inc!
      @end += 1
    end

  protected
    def initialize
      @begin = nil
      @end = nil
    end
  end
end
