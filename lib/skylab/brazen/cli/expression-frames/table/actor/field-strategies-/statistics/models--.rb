module Skylab::Brazen

  class CLI::Expression_Frames::Table::Actor

    class Field_Strategies_::Statistics

      # (the below moved here with the file but have become detached frm tests)

    # it is a pesudo-proc ..
    #
    #     Table = Face_::CLI::Table
    #
    #
    # call it with nothing and it renders nothing:
    #
    #     Table[]  # => nil
    #
    #
    # call it with one thing, must respond to each (in two dimensions)
    #
    #     Table[ :a ]  # => NoMethodError: "private method .."
    #
    #
    # that is, an array of atoms won't fly either
    #
    #     Table[ [ :a, :b ] ]  # => NoMethodError: undefined method `each_wi..
    #
    #
    # here is the smallest table you can render, which is boring
    #
    #     Table[ [] ]  # => ''
    #
    #
    # default styling ("| ", " |") is evident in this minimal non-empty table:
    #
    #     Table[ [ [ 'a' ] ] ]   # => "| a |\n"
    #
    #
    # the default styling also includes " | " as the middle separator
    # and text cels aligned left with this
    # minimal normative example:
    #
    #     act = Table[ [ [ 'Food', 'Drink' ], [ 'donuts', 'coffee' ] ] ]
    #     exp = <<-HERE.gsub %r<^ +>, ''
    #       | Food   | Drink  |
    #       | donuts | coffee |
    #     HERE
    #     act  # => exp

    # specify custom headers, separators, and output functions:
    #
    #     a = []
    #     x = Face_::CLI::Table[ :field, 'Food', :field, 'Drink',
    #       :left, '(', :sep, ',', :right, ')',
    #       :read_rows_from, [[ 'nut', 'pomegranate' ]],
    #       :write_lines_to, a ]
    #
    #     x  # => nil
    #     ( a * 'X' )  # => "(Food,Drink      )X(nut ,pomegranate)"

    # add field modifiers between the `field` keyword and its label (left/right):
    #
    #     str = Face_::CLI::Table[
    #       :field, :right, :label, "Subproduct",
    #       :field, :left, :label, "num test files",
    #       :read_rows_from, [ [ 'face', 100 ], [ 'headless', 99 ] ] ]
    #
    #     exp = <<-HERE.unindent
    #       | Subproduct | num test files |
    #       |       face | 100            |
    #       |   headless | 99             |
    #     HERE
    #     str # => exp

    class Field_Statistics__

      attr_reader :d, :min_numeric_x, :max_numeric_x,
        :min_strlen, :max_strlen,
        :max_whole_places, :max_rational_places,
        :typecount_h

      def initialize d
        @d = d
        @min_numeric_x = @max_numeric_x = nil
        @min_strlen = @max_strlen = nil
        @max_whole_places = @max_rational_places = 0
        @render_p = nil
        @typecount_h = ::Hash.new 0

        @check_numeric_min_max = -> do
          @min_numeric_x = @max_numeric_x = @x
          @check_numeric_min_max = -> do
            if @x < @min_numeric_x
              @min_numeric_x = @x
            elsif @max_numeric_x < @x
              @max_numeric_x = @x
            end ; nil
          end ; nil
        end

        @check_strlen_min_max = -> do
          @min_strlen = @max_strlen = @x.length
          @check_strlen_min_max = -> do
            len = @x.length
            if len < @min_strlen
              @min_strlen = len
            elsif @max_strlen < len
              @max_strlen = len
            end ; nil
          end ; nil
        end
      end
      def see_value_and_build_cel x
        if x
          @x = x
          if x.respond_to? :ascii_only?
            see_string_value
          else
            see_numeric_value
          end
          @typecount_h[ @cel.type_i ] += 1
          @cel
        else
          @typecount_h[ :falseish ] += 1
          x
        end
      end
    private
      def see_numeric_value
        @cel = Numeric_Cel__.new @x
        @check_numeric_min_max[]
        convert_to_string_and_count_places
        finish_string_value
      end

      def convert_to_string_and_count_places
        @x = @x.to_s
        whole = @x.index PERIOD__
        if whole
          rational = @x.length - whole - 1
          rational > @max_rational_places and @max_rational_places = rational
        else
          whole = @x.length
        end
        whole > @max_whole_places and @max_whole_places = whole
      end
      PERIOD__ = '.'.freeze

      def see_string_value
        @cel = String_Cel__.new
        finish_string_value
      end

      def finish_string_value
        @check_strlen_min_max[]
        @cel.as_string = @x ; nil
      end
    public
      def finish_string_pass
        @check_numeric_min_max = @check_strlen_min_max = nil
        @cel = @x = nil ; self
      end
    end

    class String_Cel__
      attr_accessor :as_string
      def type_i
        :string
      end
    end

    class Numeric_Cel__ < String_Cel__
      def initialize x
        @x = x
      end
      attr_reader :x
      def type_i
        :numeric
      end
    end

    class Cel_Renderer__
      def self.produce_via_field_and_stats field, stats
        new( field, stats ).produce
      end
      def initialize field, stats
        @field = field ; @stats = stats
      end
      def produce
        if @stats.typecount_h.key? :numeric
          if @stats.max_rational_places.zero?
            Integer_Cel_Renderer__.new @field.align_i, @stats
          else
            Floating_Point_Cel_Renderer__.new @field.align_i, @stats
          end
        else
          String_Cel_Renderer__.new @field.align_i, @stats.max_strlen
        end
      end
    end

    class Functional_Cel_Renderer__
      def call cel
        @render_cel_p[ cel ]
      end
    end

    class String_Cel_Renderer__ < Functional_Cel_Renderer__
      def initialize align_i, max_strlen
        resolve_string_format_string_from align_i, max_strlen
        @render_cel_p = -> cel do
          if cel
            @string_format_string % cel.as_string
          else
            @string_format_string % cel
          end
        end ; nil
      end
    private
      def resolve_string_format_string_from align_i, max_strlen
        :right == align_i or minus = MINUS_
        @string_format_string = "%#{ minus }#{ max_strlen }s" ; nil
      end
    end

    class Numeric_Cel_Renderer__ < String_Cel_Renderer__
    private
      def from_two_formats_resolve_standard_numeric_renderer
        @render_cel_p = -> cel do
          if cel
            if :numeric == cel.type_i
              @numeric_format_string % cel.x
            else
              @string_format_string % cel.as_string
            end
          else
            @string_format_string % cel
          end
        end
      end
    end

    class Integer_Cel_Renderer__ < Numeric_Cel_Renderer__
      def initialize align_i, stats
        :left == align_i and minus = MINUS_
        @numeric_format_string = "%#{ minus }#{ stats.max_strlen }d"
        resolve_string_format_string_from align_i, stats.max_strlen
        from_two_formats_resolve_standard_numeric_renderer ; nil
      end
    end

    class Floating_Point_Cel_Renderer__ < Numeric_Cel_Renderer__
      def initialize align_i, stats
        :left == align_i and minus = MINUS_
        number_of_numeric_columns =
          stats.max_whole_places + 1 + stats.max_rational_places
        if stats.max_strlen > number_of_numeric_columns
          over_d = stats.max_strlen - number_of_numeric_columns
        else
          use_max_strlen = number_of_numeric_columns
          over_d = 0
        end
        _bignum = number_of_numeric_columns + over_d
        @numeric_format_string =
          "%#{ minus }#{ _bignum }.#{ stats.max_rational_places }f"
        resolve_string_format_string_from align_i || :right, use_max_strlen
        from_two_formats_resolve_standard_numeric_renderer ; nil
      end
    end

    # but the real fun begins with currying
    # you can curry properties and behavior for table in one place ..
    #
    #     P = Face_::CLI::Table.curry :left, '<', :sep, ',', :right, ">\n"
    #
    #
    # and then use it in another place:
    #
    #     P[ [ %w(a b), %w(c d) ] ]  # => "<a,b>\n<c,d>\n"
    #
    #
    # you can optionally modify the properties for your call:
    #
    #     P[ :sep, ';', :read_rows_from, [%w(a b), %w(c d)] ]  # => "<a;b>\n<c;d>\n"
    #
    #
    #
    # you can even curry the curried "function", curry the data, and so on -
    #
    #     q = P.curry( :read_rows_from, [ %w( a b ) ], :sep, 'X' )
    #     q[ :sep, '_' ]  # => "<a_b>\n"
    #     q[]  # => "<aXb>\n"

    end
  end
end
