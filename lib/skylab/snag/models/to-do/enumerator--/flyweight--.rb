module Skylab::Snag

  class Models::ToDo::Enumerator__::Flyweight__

    def initialize pattern
      @md = nil
      @pattern = pattern  # just passed around. not used here.
      @upstream_output_line = nil  # e.g ffrom find, e.g "path:line:source"
    end

    def collapse
      Models::ToDo.new full_source_line, line_number_string, path, @pattern
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

    def is_valid
      @md or parse
      if @md
        @md[:line] && @md[:path]
      end
    end

  private

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
