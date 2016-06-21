module Skylab::DocTest

  module Models_::Code

    class Run

      class << self
        alias_method :begin_via_offsets__, :new
        undef_method :new
      end  # >>

      def initialize m_r, c_r, lts_r, s

        @_a = []
        @_content_begin = c_r.begin
        accept_line_via_offsets m_r, c_r, lts_r, s
      end

      def accept_line_via_offsets m_r, c_r, l_r, s

        # whatever the first code line was, that sets the cutoff margin
        # to be used for all code lines. so disregard what the common
        # regex says is the beginning offset for content.

        li = Line___.__via_offsets m_r, ( @_content_begin ... c_r.end ), l_r, s
        if li.has_magic_copula
          @has_magic_copula = true
        end
        accept_line_object li
      end

      def accept_line_object li
        @_a.push li ; nil
      end

      def finish
        @_a.freeze  # or not..
        self
      end

      def to_line_stream_  # might be #testpoint-only
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

      attr_reader(
        :has_magic_copula,
        :MARGIN_POSITION___,
      )

      def category_symbol
        :code
      end
    end

    class Line___

      class << self
        alias_method :__via_offsets, :new
        undef_method :new
      end  # >>

      def initialize margin_r, content_r, lts_r, s

        # not blank so the content string has something

        md = COPULA_RX___.match s, content_r.begin

        if md
          @has_magic_copula = true
          @copula_range = ::Range.new( * md.offset(0), true )
        else
          @has_magic_copula = false
        end

        @_margin_range = margin_r
        @_content_range = content_r
        @LTS_range = lts_r
        @string = s
      end

      COPULA_RX___ = /[ \t]*#[ \t]=>[ \t]/

      def to_common_paraphernalia_given choices  # assume has magic copula
        Models_::CopulaAssertion.via_code_line__ self, choices
      end

      def to_line_stream
        Common_::Stream.via_item get_content_line
      end

      def get_content_line
        @string[ get_content_line_range ]
      end

      def get_content_line_range
        content_begin ... @LTS_range.end
      end

      def content_begin
        @_content_range.begin
      end

      attr_reader(
        :copula_range,
        :LTS_range,
        :has_magic_copula,
        :string,
      )

      def is_blank_line
        false
      end
    end

    # ==

    MONADIC_EMPTINESS_ = -> _ { NIL_ }
  end
end
