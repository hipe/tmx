module Skylab::Git::TestSupport

  class CommonTabularScreenIndex

    def initialize lines

      lio_h = {}
      parsed_lines = []

      lines.each_with_index do |line, d|

        pl = ParsedLine___.new d, line
        k = pl.operation_symbol
        _a = lio_h.fetch k do
          x = []
          lio_h[ k ] = x
          x
        end
        _a.push d
        parsed_lines.push pl
      end

      lio_h.values.each do |a|
        a.freeze
      end

      @__line_indexes_of = lio_h.freeze
      @parsed_lines = parsed_lines.freeze
      freeze
    end

    def line_indexes_of operation_symbol  # create|delete
      @__line_indexes_of.fetch operation_symbol
    end

    attr_reader(
      :parsed_lines,
    )

    # ==

    class ParsedLine___

      def initialize d, line

        :o == line.stream_symbol || self._WHOOPS_got_an_errput_line

        md = COMMON_LINE_RX___.match line.string

        if ! md
          self._REGEX_FAILURE
        end

        @line_index = d
        @operation_symbol = OPERATION_SYMBOLS___.fetch md[ :operation_string ]
        @time = Home_.lib_.time.parse md[ :date_and_time_and_zone ]
      end

      attr_reader(
        :line_index,
        :operation_symbol,
        :time,
      )

      # ==

      OPERATION_SYMBOLS___ = {
        'create' => :create,
        'rename from' => :rename,
      }

      COMMON_LINE_RX___ = /\A

        [^ ]+  # sha
        [ ]
        (?<date_and_time_and_zone>
          (?:\d{4}-\d{2}-\d{2})
          [ ]
          (?:\d{2}:\d{2}:\d{2})
          [ ]
          (?:-?\d{4})
        )
        [ ]
        (?<operation_string>
          [^ ]+  (?:[ ][^ ]+)*
        )
        [ ]+
        [^ ]+  # path
      $/x

      # ==
    end

    # ==
  end
end
