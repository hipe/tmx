module ::Skylab::CodeMolester

  class ParseFailurePorcelain # @api private
    include Porcelain::En::Methods

    attr_reader :failures

    def render
      o = @meta
      a = [ "Expecting #{ or_ o[:expect].map(&:inspect) }" ]
      a << o[:line_head] if o[:line_head]
      if o[:escaped_path]
        aa = [ "in #{ o[:escaped_path] }" ]
        aa << ":#{ o[:line_number] }" if o[:line_number]
        a << aa.join( '' )
      elsif o[:line_number]
        a << "at line #{ o[:line_number] }"
      end
      str = a.join ' '
      str
    end

    alias_method :to_s, :render

  protected

    # result : start_idx_of_line, line_width, line_number (1-indexed)
    line_indices = -> string, seek_idx do
      scn = CodeMolester::Services::StringScanner.new string
      at_idx = -1
      line_idx = 0
      content = nil
      loop do
        content = scn.scan( / [^\n]* \n? /x ) # always match, even when eos?
        next_at_idx = at_idx + content.length
        if next_at_idx >= seek_idx or scn.eos?
          break
        end
        line_idx += 1
        at_idx = next_at_idx
      end
      [at_idx + 1, content.length, line_idx + 1]
    end


    define_method :initialize do |parser|
      @failures = parser.terminal_failures.dup
      arr = @failures.dup
      f = arr.shift
      h = { min: f.index, max: f.index, expect: [f.expected_string] }
      @meta = arr.reduce( h ) do |m, o|
        o.index < m[:min] and m[:min] = o.index
        o.index > m[:max] and m[:max] = o.index
        m[:expect] |= [o.expected_string]
        m
      end
      idx, width, @meta[:line_number] = line_indices[ parser.input, @meta[:min]]
      if idx == @meta[:min]
        @meta[:line_head] = "at beginning of line"
      else
        @meta[:line_head] = "at the end of #{
          }#{ parser.input[ idx .. @meta[:min] ].inspect }"
      end
    end
  end
end
