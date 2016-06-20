module Skylab::DocTest

  module Models_::Code

    class Run

      class << self
        alias_method :begin_via_offsets__, :new
        undef_method :new
      end  # >>

      def initialize m_r, c_r, lts_r, s

        @_a = []

        @_see = -> li do

          if ! li.is_blank_line
            # (hi.)
            if li.has_magic_copula
              @has_magic_copula = true
              @_see = MONADIC_EMPTINESS_ ; nil
            end
          end
        end

        accept_line Line.via_offsets_( m_r, c_r, lts_r, s )
      end

      def accept_line li

        @_see[ li ]
        @_a.push li ; nil
      end

      def finish
        remove_instance_variable :@_see
        @_a.freeze  # or not..
        self
      end

      def to_line_object_stream___  # #testpoint-only
        Common_::Stream.via_nonsparse_array @_a
      end

      def number_of_lines___  # #testpoint-only
        @_a.length
      end

      def category_symbol___  # #testpoint-only
        :code
      end
    end

    class Line

      class << self
        alias_method :via_offsets_, :new
        undef_method :new
      end  # >>

      def initialize margin_r, content_r, lts_r, s

        # not blank so the content string has something

        md = COPULA_MD___.match s, content_r.begin

        if md
          @has_magic_copula = true
          @_COPULA_RANGE = md.offset 0
        else
          @has_magic_copula = false
        end

        @_margin_range = margin_r
        @_content_range = content_r
        @_LTS_range = lts_r
        @_string = s
      end

      COPULA_MD___ = /[ \t]*#[ \t]=>[ \t]/

      def string___  # #testpoint-only
        @_string
      end

      attr_reader(
        :has_magic_copula,
      )

      def is_blank_line
        false
      end
    end

    # ==

    MONADIC_EMPTINESS_ = -> _ { NIL_ }
  end
end
