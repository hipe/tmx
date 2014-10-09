module Skylab::Headless

  class Text::Patch::Models::Chunk

    attr_reader :left
    attr_reader :right

  private

    def initialize
      @left = Side.new
      @right = Side.new
    end
  end

  class Text::Patch::Models::Chunk::Side

    def << line
      @range.inc!
      @lines << line
      nil
    end

    def length
      @range.end - @range.begin + 1
    end

    def line_count
      @lines.length
    end

    def lines
      @lines.dup
    end

    attr_reader :range

  private

    def initialize
      @range = Range.new
      @lines = []
    end
  end

  class Text::Patch::Models::Chunk::Side::Range

    attr_reader :begin

    def begin= int
      @begin = int
      @end = int - 1
    end

    attr_reader :end

    def inc!
      @end += 1
    end

  private
    def initialize
      @begin = nil
      @end = nil
    end
  end
end
