module Skylab::Snag
  class Models::ToDo::Flyweight

    def content
      @rest.nil? and parse!
      @rest
    end

    def dup
      self.class.new.set! @string
    end

    def line
      @line.nil? and parse!
      @line
    end

    def path
      @path.nil? and parse!
      @path
    end

    def set! string
      @line = @path = @rest = nil
      @string = string
      self
    end

    attr_reader :string

    alias_method :to_s, :string

    def valid?
      if ! (@line && @path) and @string
        parse!
      end
      @line && @path
    end

  protected

    def initialize
      set! nil
    end


    rx = /\A (?<path>[^:]+) : (?<line>\d+) : (?<rest>.*) $/x

    define_method :parse! do
      if @string and md = rx.match( @string )
        @line = md[:line].to_i
        @path = md[:path]
        @rest = md[:rest]
      else
        @line = @path = @rest = false
      end
    end
  end
end
