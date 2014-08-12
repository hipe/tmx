module Skylab::Snag

  class Models::ToDo::Enumerator__::Flyweight__

    def collapse
      Models::ToDo.new path, line_number_string, full_source_line, @pattern
    end

    def full_source_line
      @md or parse
      @md[:full_source_line]
    end

    def line_number_string
      @md or parse
      @md[:line]
    end

    def path
      @md or parse
      @md[:path]
    end

    # replace the *entire* defining contents of the flyweight

    def replace string
      @md = nil
      @upstream_output_line = string
      self
    end

    attr_reader :upstream_output_line

    def valid?
      @md or parse
      if @md
        @md[:line] && @md[:path]
      end
    end

  private

    def initialize pattern
      @upstream_output_line = nil  # e.g ffrom find, e.g "path:line:source"
      @md = nil
      @pattern = pattern          # just passed around. not used here.
    end

    rx = /\A (?<path>[^:]+) : (?<line>\d+) : (?<full_source_line>.*) $/x
    # (if the above changes be *sure* to audit all of the heavyweight class)

    define_method :parse do
      if @upstream_output_line and md = rx.match( @upstream_output_line )
        @md = md
      else
        @md = false
        fail 'sanity'
      end
    end
  end
end
