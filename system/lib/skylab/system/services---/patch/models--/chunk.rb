module Skylab::System

  class Services___::Patch

  class Models__::Chunk

    attr_reader :left
    attr_reader :right

    def initialize
      @left = Side__.new
      @right = Side__.new
    end

    def to_line_stream

      lf = @left.length.nonzero?
      rt = @right.length.nonzero?

      _left_range_s = Range_to_string___[ @left.range ]
      _right_range_s = Range_to_string___[ @right.range ]

      _action_char = if lf
        if rt
          CHANGE___
        else
          DELETE___
        end
      elsif rt
        ADD___
      else
        self._NEVER
      end

      _line = "#{ _left_range_s }#{ _action_char }#{ _right_range_s }\n"

      a = [ _line ]

      @left.lines.each do | s |
        s = Add_newline_if_necessary__[ s ]
        a.push "< #{ s }"
      end

      if lf && rt
        a.push SEPARATOR_LINE___
      end

      @right.lines.each do | s |
        s = Add_newline_if_necessary__[ s ]
        a.push "> #{ s }"
      end

      Callback_::Stream.via_nonsparse_array a
    end

    etc_rx = /\r?\n\z/
    Add_newline_if_necessary__ = -> s do
      if etc_rx =~ s
        s
      else
        "#{ s }#{ NEWLINE_ }"
      end
    end

    ADD___ = 'a'
    CHANGE___ = 'c'
    DELETE___ = 'd'
    SEPARATOR_LINE___ = "---\n"

    Range_to_string___ = -> r do

      case r.begin <=> r.end
      when 0  ; "#{ r.begin }"
      when -1 ; "#{ r.begin },#{ r.end }"
      else    ; "#{ r.end }"
      end
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
      @range = Range___.new
      @lines = []
    end
  end

  class Range___

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
  end
end
