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
    def invalid_reason
      @invalid_reason and return @invalid_reason
      if :unparsed == @state
        _parsed
      end
      case @state
      when :parsed   ; nil
      when :invalid  ; @invalid_reason || "(reason unknown)"
      when :initial  ; "the issue is in the initial state"
      else           ; fail('bad state')
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
      case @state
      when :parsed   ; @parsed
      when :unparsed ;
        if @parsed = REGEX.match(@line)
          @state = :parsed
          @parsed
        else
          @state = :invalid
          @invalid_reason = "Failed to match line with regex (line:\n#{@line})"
          false
        end
      when :initial  ; nil
      when :invalid  ; false
      else           ; fail('bad state')
      end
    end
    attr_reader :pathname
    attr_reader :state
    def valid?
      if :unparsed == @state
        _parsed
      end
      case @state
      when :parsed   ; true
      when :invalid  ; false
      when :initial  ; false
      else           ; fail('bad state')
      end
    end
  end
  class << Models::Issue
    alias_method :build_flyweight, :new
  end
end

