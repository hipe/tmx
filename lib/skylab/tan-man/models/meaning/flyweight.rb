module Skylab::TanMan
  class Models::Meaning::Flyweight


                                  # if you need to use the data in a flyweight
    def collapse request_client   # at any time other than during that iteration
      Models::Meaning.new request_client, name, value # you must
    end                           # collapse it.  one day when we get retarded
                                  # we might try to make them editable.

    def colon_pos
      index! unless @indexed
      @colon_pos
    end

    def destroy error, success
      from = line_start
      to = value_index.last + 1 # dos line endings whatever
      new_string = scn.string.dup
      new_string[ from .. to ] = ''
      old_name = name
      old_len = scn.string.length
      scn.string.replace( new_string )
      new_len = scn.string.length
      success[ old_len - new_len ]
    end

    def line_start
      from = @start_pos
      if from > 0
        back = scn.string.rindex( "\n", from - 1 )
        if back
          from = back + 1
        else
          from = 0
        end
      end
      from
    end

    def name
      scn.string[ name_index ]
    end

    def name_index
      index! unless @indexed
      @name_index
    end

    def set! str, pos
      @indexed = nil
      @start_pos = pos
      scn.string = str
      nil
    end

    attr_reader :start_pos

    def whole_string # for extreme hacking only
      scn.string
    end

    def value
      scn.string[ value_index ]
    end

    def value_index
      index! unless @indexed
      @value_index
    end

  protected

    def initialize
      @indexed = nil
      @scn = TanMan::Services::StringScanner.new ''
    end

    white_rx = /[ \t]+/

    define_method :index! do
      scn.pos = @start_pos
      scn.skip white_rx
      name_start = scn.pos
      scn.skip( /[-a-z]+/ ) or fail 'parse error - name'
      name_end = scn.pos - 1
      scn.skip white_rx
      @colon_pos = scn.pos
      scn.skip( /:/ ) or fail 'parse error - colon'
      scn.skip white_rx
      value_start = scn.pos
      scn.skip( /[^\r\n]+/ ) or fail 'parse error - empty value?'
      value_end = scn.pos - 1
      @name_index = name_start .. name_end
      @value_index = value_start .. value_end
      @indexed = true
    end

    attr_reader :scn

  end
end
