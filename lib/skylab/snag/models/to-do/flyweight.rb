module Skylab::Snag
  class Models::ToDo::Flyweight

    def collapse
      Models::ToDo.new path, line_number_string, full_source_line, @pattern
    end

    def full_source_line
      @md or parse
      @md[:full_source_line]
    end

    attr_reader :full_string

    alias_method :to_s, :full_string

    def line_number_string
      @md or parse
      @md[:line]
    end

    def path
      @md or parse
      @md[:path]
    end

    def set! string
      @md = nil
      @full_string = string
      self
    end

    def valid?
      @md or parse
      if @md
        @md[:line] && @md[:path]
      end
    end

  protected

    def initialize pattern
      @full_string = nil
      @md = nil
      @pattern = pattern          # just passed around. not used here.
    end

    rx = /\A (?<path>[^:]+) : (?<line>\d+) : (?<full_source_line>.*) $/x
    # (if the above changes be *sure* to audit all of the heavyweight class)

    define_method :parse do
      if @full_string and md = rx.match( @full_string )
        @md = md
      else
        @md = false
        fail 'sanity'
      end
    end
  end
end
