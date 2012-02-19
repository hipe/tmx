module Skylab::Issue
  class Models::Issue
    def clear!
      @index = @invalid_reason = @line = @parsed = @state = nil
      self
    end
    def date
      _parsed[:rest][1,10] # @todo!
    end
    def identifier
      _parsed[:identifier]
    end
    def initialize params
      clear!
      @state = :initial
      @pathname = (params = params.dup).delete(:pathname)
      params.any? and raise ArgumentError.new('bad keys')
    end
    def invalid_info
      valid? and return
      send("invalid_info_#{invalid_reason}")
    end
    def invalid_info_issue_is_in_initial_state
      { invalid_reason:   invalid_reason }
    end
    def invalid_info_line_failed_to_match_regex
      {
        line:              @line,
        line_number:       line_number,
        pathname:          pathname,
        invalid_reason:    invalid_reason
      }
    end
    def invalid_reason
      :unparsed == @state and _parsed
      case @state
      when :initial ; :issue_is_in_initial_state
      when :invalid ; @invalid_reason
      when :parsed  ; nil
      else          ; fail('bad state')
      end
    end
    attr_reader :line # should only be used for error reporting
    def line! line, index
      clear!
      @index = index
      @line = line
      @state = :unparsed
      self
    end
    def line_number
      @index + 1
    end
    def message
      _parsed[:rest][12..-1] # @todo!
    end
    REGEX = /\A\[#(?<identifier>\d+)\](?<rest>.*)\z/
    def _parsed
      if :unparsed == @state
        if @parsed = REGEX.match(@line)
          @state = :parsed
        else
          @state = :invalid
          @invalid_reason = :line_failed_to_match_regex
        end
      end
      @parsed
    end
    attr_reader :pathname
    attr_reader :state
    def valid?
      :unparsed == @state and _parsed
      case @state
      when :initial  ; false
      when :invalid  ; false
      when :parsed   ; true
      else           ; fail('bad state')
      end
    end
  end
  class << Models::Issue
    alias_method :build_flyweight, :new
  end
end

