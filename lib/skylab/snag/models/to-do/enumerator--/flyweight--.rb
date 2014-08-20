module Skylab::Snag

  class Models::ToDo::Enumerator__::Flyweight__

    def initialize pattern
      @md = nil
      @pattern = pattern  # just passed around. not used here.
      @upstream_output_line = nil  # e.g ffrom find, e.g "path:line:source"
    end

    attr_reader :upstream_output_line

    def collapse listener
      @md or parse
      Models::ToDo.build( @md[ :full_source_line ], @md[ :line ], @md[ :path ],
        @pattern, listener )
    end

    def is_valid
      @md or parse
      @md[ :line ] && @md[ :path ]
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

  private

    def parse
      @upstream_output_line or self._SANITY
      @md = RX__.match( @upstream_output_line ) or self._SANITY
    end

    RX__ = /\A (?<path>[^:]+) : (?<line>\d+) : (?<full_source_line>.*) $/x
  end
end
