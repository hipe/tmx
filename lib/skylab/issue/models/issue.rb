module Skylab::Issue
  class Models::Issue
    def identifier
      _parsed[:identifier]
    end
    def initialize; end
    def line= line
      @_parsed = nil
      @line = line.strip
    end
    REGEX  = %r{\A\[#(\d+)\](.*)\z}
    REGEX_ = [:identifier, :rest]
    def _parsed
      @_parsed ||= begin
        md = REGEX.match(@line) or fail("Failed to match line with regex (line:\n#{@line})")
        Hash[* REGEX_.zip(md.captures).flatten ]
      end
    end
  end
  class << Models::Issue
    alias_method :build_flyweight, :new
  end
end

