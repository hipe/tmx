module Skylab::TanMan

  module Models_::Meaning

  class Flyweight__

      class << self
        def via_this_data__ * a
          new.__init_via_this_data( * a )
        end
      end  # >>

    def initialize
      @indexed = @scn = nil
    end

    attr_reader :start_pos, :end_pos
    attr_reader :next_line_start_pos

    def initialize_copy _otr_
      @scn = @scn.dup
      @scn.string = @scn.string.dup
    end

    def natural_key_string
      dereference :name
    end

    def value_string
      dereference :value
    end

    def dereference i
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
        @scn = Home_.lib_.string_scanner.new str
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
        back = @scn.string.rindex( NEWLINE_, from - 1 )
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

    def mutable_whole_string
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

      public

      def __init_via_this_data v_r, n_r, line

        # a hackish afterthought to bridge legacy code with our new thing
        # of resulting in an entity after an add: while changing as little
        # other code as possible here, let the client prouduce a meaning
        # "entity" given the arguments. the implementation is hacked to
        # allow the rest of the subject to think it's in the middle of a
        # scan of a large string #spot2.3

        @value_range = v_r
        @name_range = n_r
        @scn = StaticScanner___.new line
        @indexed = true
        freeze
      end

      def HELLO_MEANING  # #todo during development
        NOTHING_
      end

      # ==

      StaticScanner___  = ::Struct.new :string  # per #spot2.3 (above)

      # ==
      # ==
  end
  end
end
# #tombstone-A.1 (should be temporary): used to have a hook-out for [#br-021] magic result shapes
