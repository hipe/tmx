module Skylab::DocTest

  module Models_::Discussion

    class Run

      class << self
        alias_method :new_empty__, :new
        undef_method :new
      end  # >>

      def initialize
        @_a = []
      end

      def accept_line o
        @_a.push o ; nil
      end

      def finish__
        @_a.freeze ; self   # or not..
      end

      def to_line_stream_  # might be #testpoint-only..
        to_line_object_stream___.map_by do |o|
          o.string
        end
      end

      def to_line_object_stream___  # here too, #testpoint-only
        Common_::Stream.via_nonsparse_array @_a
      end

      def number_of_lines___  # #testpoint-only
        @_a.length
      end

      def category_symbol
        :discussion
      end
    end

    class Line

      class << self
        alias_method :via_offsets__, :new
        undef_method :new
      end  # >>

      def initialize r, r_, r3, s
        @_margin_range = r
        @_content_range = r_
        @_LTS_range = r3
        @string = s
      end

      attr_reader(
        :string,
      )
    end
  end
end
