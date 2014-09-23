module Skylab::TanMan

  class Models_::Meaning

  class Flyweight__

    def initialize
      @indexed = @scn = nil
    end

    attr_reader :start_pos, :end_pos
    attr_reader :next_line_start_pos

    def initialize_copy _otr_
      @scn = @scn.dup
      @scn.string = @scn.string.dup
    end

    def property_value i
      @indexed or index!
      send PROP_VAL_H__.fetch i
    end

    PROP_VAL_H__ = { name: :name_property_value, value: :value_property_value }

    def name_property_value
      @scn.string[ name_range ]
    end

    def value_property_value
      @scn.string[ value_range ]
    end

    def set! start, end_d, str
      @indexed = nil
      @start_pos = start ; @end_pos = end_d
      if @scn
        @scn.string = str
      else
        @scn = TanMan_::Lib_::String_scanner[].new str
      end ; nil
    end

    def colon_pos
      index! unless @indexed
      @colon_pos
    end

    def destroy error, success
      from = line_start
      to = value_range.last + 1  # assume `NEWLINE_` is 1 char wide
      new_string = @scn.string.dup
      new_string[ from .. to ] = EMPTY_S_
      old_len = @scn.string.length
      scn.string.replace( new_string )
      new_len = @scn.string.length
      success[ old_len - new_len ]
    end

    def line_start
      from = @start_pos
      if from > 0
        back = @scn.string.rindex( "\n", from - 1 )
        if back
          from = back + 1
        else
          from = 0
        end
      end
      from
    end

    def name_range
      index! unless @indexed
      @name_range
    end

    def value_range
      index! unless @indexed
      @value_range
    end

    def whole_string # for extreme hacking only
      @scn.string
    end

  private

    white_rx = /[ \t]+/

    define_method :index! do
      @scn.pos = @start_pos
      @scn.skip white_rx
      name_start = @scn.pos
      @scn.skip( /[-a-z]+/ ) or fail 'parse error - name'
      name_end = @scn.pos - 1
      @scn.skip white_rx
      @colon_pos = @scn.pos
      @scn.skip( /:/ ) or fail 'parse error - colon'
      @scn.skip white_rx
      value_start = @scn.pos
      @scn.skip( /[^\r\n]+/ ) or fail 'parse error - empty value?'
      value_end = @scn.pos - 1
      @name_range = name_start .. name_end
      @value_range = value_start .. value_end
      @scn.skip( /\r?\n/ )
      @next_line_start_pos = @scn.pos
      @indexed = true
    end
  end
  end
end
