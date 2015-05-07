module Skylab::System

  class Services___::Patch

  class Models__::Chunk

    attr_reader :left
    attr_reader :right

  private

    def initialize
      @left = Side__.new
      @right = Side__.new
    end


  class Side__

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
      @range = Range__.new
      @lines = []
    end

  class Range__

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

  end  # Range__
  end  # Side__
  end  # Chunk__

  end
end
