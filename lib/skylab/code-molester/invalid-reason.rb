module Skylab::CodeMolester

  class InvalidReason

    # This class has a background shrouded in mystery and is of dubious utility,
    # but has nonethelss been rewritten several times as an exercize.
    #
    # If ever we have really kinky requirements for rendering parse
    # error messages, this would be a place to start.
    #
    # EDIT: no actually i take that back. this class *is* used and it *is*
    # useful - it is the first hint an event object as we use them today -
    # it is a nice little encapsulation of the parse error message that
    # we can throw around and bubble up.

    # (amusingly in the next screen we pretty much take a tour through the
    # entire history of event message rendering..)

    render_options = ::Struct.new :escape_path

    define_method :render do |opts_h=nil|
      o = render_options.new
      opts_h and opts_h.each { |k, v| o[k] = v }
      o[:escape_path] ||= -> pn { pn.basename }

      @render[ o ]
    end

    alias_method :to_s, :render

    # `message_function` - implement the unified interface (contemporary
    # with its date of writing) by wrapping the above.

    attr_reader :message_function  # ( set in `initialize` )

  protected

    # result : start_idx_of_line, line_number (1-indexed), line_width
    line_info = -> string, seek_idx do
      scn = CodeMolester::Services::StringScanner.new string
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
    min_index__expected = -> terminal_failures do
      min_index = terminal_failures.first.index
      expected = [terminal_failures.first.expected_string]
      terminal_failures[ 1 .. -1 ].reduce nil do |_, o|
        o.index < min_index and min_index = o.index
        expected |= [o.expected_string]
        _
      end
      [min_index, expected]
    end

    include Headless::NLP::EN::Methods # or_

    define_method :initialize do |parser, pathname|

      @render = -> params do
        min_index, expected = min_index__expected[ parser.terminal_failures ]
        line_number, line_begin_idx, = line_info[ parser.input, min_index ]

        a = [ "Expecting #{ or_ expected.map(& :inspect) }" ]

        excerpt = if line_begin_idx != min_index
                    parser.input[ line_begin_idx .. min_index ].inspect
                  end

        if pathname
          a << "in #{ params.escape_path[ pathname ] }:#{ line_number }"
          if excerpt
            a << "at the end of #{ excerpt }"
          else
            a << "at the beginning of the line"
          end
        elsif excerpt
          a << "in line #{ line_number } at the end of #{ excerpt }"
        else
          a << "at the beginning of line #{ line_number }"
        end

        a.join ' '
      end

      me = self
      @message_function = -> do
        me.render
      end

      freeze
    end
  end
end
