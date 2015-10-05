module Skylab::CodeMolester

  class Invalid_Reason__  # #interesting-history

    def initialize parser, pn
      @input_s = parser.input ; @pn = pn
      @terminal_failure_a = parser.terminal_failures ; nil
    end

    attr_reader( * MEMBER_I_A__ = %i( input_s pn terminal_failure_a ).freeze )

    def to_s
      render
    end
    #
    def render opt_h=nil
      x_a = if opt_h
        opt_h.each_pair.reduce( [] ) do |m, (k,v)| m << k << v ; m end
      else EMPTY_A_ end
      render_with( * x_a )
    end
    #
    def render_with * x_a
      Home_::Expression_Agent__.new( x_a ).
        instance_exec( * to_a, & message_proc )
    end
    #
    def to_a
      members.map( & method( :send ) )
    end
    def members ; self.class.members end
    def self.members ; const_get( :MEMBER_I_A__, false ) end

    def message_proc ; self.class.const_get( :MESSAGE_PROC__, true ) end
    #
    MESSAGE_PROC__ = -> input_s, pn, terminal_failure_a do
      min_index, expected = Min_index__expected__[ terminal_failure_a ]
      line_number, line_begin_idx, = Line_info__[ input_s, min_index ]
      y = [ "Expecting #{ or_ expected.map( & :inspect ) }" ]
      if line_begin_idx != min_index
        excerpt = input_s[ line_begin_idx .. min_index ].inspect
      end
      if pn
        y << "in #{ pth pn }:#{ line_number }"
        if excerpt
          y << "at the end of #{ excerpt }"
        else
          y << "at the beginning of the line"
        end
      elsif excerpt
        y << "in line #{ line_number } at the end of #{ excerpt }"
      else
        y << "at the beginning of line #{ line_number }"
      end
      y * ' '
    end

    # result : start_idx_of_line, line_number (1-indexed), line_width
    Line_info__ = -> string, seek_idx do
      scn = Home_::Library_::StringScanner.new string
      at_idx = -1
      line_idx = 0
      content = nil
      loop do
        content = scn.scan( / [^\n]* \n? /x ) # always match, even when eos
        next_at_idx = at_idx + content.length
        if next_at_idx >= seek_idx or scn.eos?
          break
        end
        line_idx += 1
        at_idx = next_at_idx
      end
      [line_idx + 1, at_idx + 1, content.length]
    end

    # this might be stupid, it warrants further testing
    # tt parser gives us a `max_terminal_failure_index`, are we trying to
    # be clever and get the min?
    Min_index__expected__ = -> terminal_failures do
      min_index = terminal_failures.first.index
      expected = [terminal_failures.first.expected_string]
      terminal_failures[ 1 .. -1 ].reduce nil do |_, o|
        o.index < min_index and min_index = o.index
        expected |= [o.expected_string]
        _
      end
      [min_index, expected]
    end
  end
end
