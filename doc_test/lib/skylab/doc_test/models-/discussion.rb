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

      def accept_line_via_offsets m_r, c_r, l_r, s
        accept_line_object Line___.___via_offsets( m_r, c_r, l_r, s ) ; nil
      end

      def accept_line_object o
        @_a.push o ; nil
      end

      def finish__
        @_a.freeze ; self   # or not..
      end

      def any_last_nonblank_line_object__

        a = @_a
        _st = Common_::Stream.via_range( a.length - 1 .. 0 ).map_by do |d|
          a.fetch d
        end
        _any_first_nonblank_line_object_in _st
      end

      def any_first_nonblank_line_object__

        _any_first_nonblank_line_object_in Common_::Stream.via_nonsparse_array @_a
      end

      def _any_first_nonblank_line_object_in st
        begin
          lo = st.gets
          lo || break
          lo.is_blank_line ? redo : break
        end while nil
        lo
      end

      def to_line_stream_  # might be #testpoint-only..
        to_line_object_stream.map_by do |o|
          o.string
        end
      end

      def to_line_object_stream
        Common_::Stream.via_nonsparse_array @_a
      end

      def number_of_lines___  # #testpoint-only
        @_a.length
      end

      def category_symbol
        :discussion
      end
    end

    class Line___

      class << self
        alias_method :___via_offsets, :new
        undef_method :new
      end  # >>

      def initialize r, r_, r3, s
        @_margin_range = r
        @_content_range = r_
        @_LTS_range = r3
        @string = s
      end

      def get_content_string
        @string[ @_content_range ]
      end

      attr_reader(
        :string,
      )

      def is_blank_line
        false
      end
    end
  end
end
