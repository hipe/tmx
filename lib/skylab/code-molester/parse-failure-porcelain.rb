require 'stringio'

# this is intended to be an independant class that is safe to use in
# isolation from the rest of the library (however, its test suite
# is currently part of its parent module.)

# This thing was stupid.  I basically wanted to customize treetop Parser#failure_reason
# but ended up not really adding anything to it.
#

module Skylab ; end

module Skylab::CodeMolester

  module En # can be moved up
    def oxford_comma a, ult = ' or ', sep = ', '
      (hsh = Hash.new(sep))[a.length - 1] = ult
      [a.first, * (1..(a.length-1)).map { |i| [ hsh[i], a[i] ] }.flatten].join
    end
    alias_method :_or, :oxford_comma
  end

  class ParseFailurePorcelain # @api private
    include En
    attr_reader :failures
    attr_reader :info
    def initialize parser
      @failures = parser.terminal_failures.dup
      f = (arr = @failures.dup).shift
      @info = arr.reduce(
        :min => f.index, :max => f.index, :expect => [f.expected_string]
      ) do |m, o|
        o.index < m[:min] and m[:min] = o.index
        o.index > m[:max] and m[:max] = o.index
        m[:expect] |= [o.expected_string]
        m
      end
      idx, width, @info[:line_number] = self.class.line_indices(parser.input, @info[:min])
      if @info[:min] == idx
        @info[:line_head] = "at beginning of line"
      else
        @info[:line_head] = "at the end of #{parser.input[idx..@info[:min]].inspect}"
      end
    end
    def paint
      [ "Expecting #{_or(@info[:expect].map(&:inspect))}",
        @info[:line_head],
        (
         if @info[:pretty_path]
           ["in #{@info[:pretty_path]}",
             (":#{@info[:line_number]}" if @info[:line_number])
           ].compact.join('')
         elsif @info[:line_number]
           "at line #{@info[:line_number]}"
         end
        )
      ].flatten.compact.join(' ')
    end
    alias_method :to_s, :paint
  end
  class << ParseFailurePorcelain
    # @return start_idx_of_line, line_width, line_number (1-indexed)
    def line_indices string, seek_idx
      scn = ::StringScanner.new(string)
      at_idx = -1
      line_idx = 0
      content = nil
      loop do
        content = scn.scan(/[^\n]*\n?/) # should always return '', even when eos?
        next_input_idx = (at_idx + content.length)
        if next_input_idx >= seek_idx or scn.eos?
          break
        end
        line_idx += 1
        at_idx = next_input_idx
      end
      [at_idx + 1, content.length, line_idx + 1]
    end
  end
end

