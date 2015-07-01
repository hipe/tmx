module Skylab::Brazen

  class CLI::Expression_Frames::Table::Actor

    class Field_Strategies_::Statistics

      ROLES = nil
      SUBSCRIPTIONS = nil

      # <- NOTHING below this line is functioning

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

    class Field_Shell__
      def initialize d, x_a, bx
        @d = d ; @x_a = x_a
        prepare_peaceful_parse
        Field__.new do |fld|
          @field = fld
          if @x_a.fetch( @d ).respond_to? :ascii_only?
            label
          else
            absrb_passive
          end
          @field.name_symbol ||= :"#{ bx.length }"
        end
        bx.add @field.name_symbol, @field ; nil
      end
      attr_reader :d

      LIB_.fields.from_methods(
        :niladic, :passive, :absorber, :absrb_passive
      ) do
        def cel_renderer_builder
          x = gets_one_polymorphic_value
          if x.respond_to? :id2name
            @field.cel_renderer_p_p = Table_::Fill_.p_p_from_i x
          else
            @field.cel_renderer_p_p = x
          end ; nil
        end
        def fill
          shell = CLI::Table::Fill_::Shell.new
          @field.fill and shell.previous_fill = @field.fill
          shell.from_d_parse_iambic_passively @d, @x_a
          @d = shell.d ; @field.fill = shell.fill
        end
        def id  # typically for fields w/o labels, i.e non-displayed headers
          @field.name_symbol = gets_one_polymorphic_value
        end
        def label
          @field.label_s = gets_one_polymorphic_value
          @field.name_symbol.nil? and @field.name_symbol = @field.label_s.intern
        end
        def left
          @field.align_i = :left
        end
        def right
          @field.align_i = :right
        end
      end
    end

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

    class Field__
      def initialize
        @cel_renderer_p_p = nil
        yield self
        freeze  # ensure that we can dupe with shallow copies
      end
      attr_accessor :align_i, :label_s, :name_symbol, :cel_renderer_p_p
    end

  public

    def execute
      ok = ( @row_upstream || @line_downstream_yielder )  # else don't bother
      ok &&= __string_pass
      ok && __render_pass
    end

    # ~ the string pass

    def __string_pass
      The_String_Pass__.new( self ).field_stats_and_cel_matrix do |fs, cm|
        @cel_matrix = cm
        @field_stats = fs
      end
    end

    class The_String_Pass__

      def initialize kernel
        @kernel = kernel
      end

      def field_stats_and_cel_matrix

        @up_st = __build_row_stream
        if @up_st

          yield( * __via_upstream_produce_two )

        else
          yield @up_st
        end
      end

      def __build_row_stream

        st = @kernel.row_upstream

        p = if @kernel.do_show_header

          -> do
            p = -> do
              st.gets
            end
            @kernel.field_box.map( & :label_s )
          end
        else
          -> do
            st.gets
          end
        end

        Callback_::Scn.new do
          p[]
        end
      end

      def __via_upstream_produce_two

        h = ::Hash.new do |h_, d|
          h_[ d ] = Field_Statistics__.new d
        end

        cel_matrix = []

        begin

          row = @up_st.gets
          row or break

          cel_row = []
          cel_matrix.push cel_row

          row.each_with_index do |cel_x, d|
            cel_row.push h[ d ].see_value_and_build_cel( cel_x )
          end

          redo
        end while nil

        [ h.length.times.map do |d|
            h.fetch( d ).finish_string_pass
          end, cel_matrix ]
      end
    end

  public

    attr_reader :do_show_header, :field_box

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

  private

    # ~ the render pass

    def __render_pass

      cel_renderers = __produce_cel_renderers

      y = @line_downstream_yielder

      if ! y
        io = Library_::StringIO.new
        y = io
      end

      left = @left_x || DEFAULT_LEFT_MARGIN__
      sep = @sep_x || DEFAULT_SEPARATOR__
      right = @right_x || DEFAULT_RIGHT_MARGIN__

      st = __cel_row_stream
      begin
        row = st.gets
        row or break
        y << "#{ left }#{
          ( row.map.with_index do |cel, d|
            cel_renderers.fetch( d ).call cel
          end ) * ( sep ) }#{
          }#{ right }"
        redo
      end while nil

      io && io.string
    end

    DEFAULT_LEFT_MARGIN__ = '| '.freeze
    DEFAULT_SEPARATOR__ = ' | '.freeze
    DEFAULT_RIGHT_MARGIN__ = " |\n".freeze

    def __cel_row_stream

      Callback_::Stream.via_nonsparse_array @cel_matrix
    end

    def __produce_cel_renderers
      @widest_row_cels_count = @field_stats.length
      @field_fetcher = __produce_field_fetcher
      early_pass_only = true
      a = @widest_row_cels_count.times.map do |d|
        x = @field_fetcher[ d ].
          prdc_early_pass_cel_renderer_via_stats @field_stats.fetch d
        if x
          x
        else
          early_pass_only = nil
        end
      end
      early_pass_only or prdc_late_pass_renderers a
      a
    end

    def __produce_field_fetcher
      if @field_box
        field_a = @field_box.values
        fields_count = field_a.length
        overage = @widest_row_cels_count - fields_count
        if 0 < overage
          field_a.concat overage.times.map { DEFAULT_FIELD__ }
        end
        -> d { field_a.fetch d }
      else
        -> _ { DEFAULT_FIELD__ }
      end
    end
    DEFAULT_FIELD__ = Field__.new { }

    class Field__
      def prdc_early_pass_cel_renderer_via_stats stats
        ! @cel_renderer_p_p and
          Cel_Renderer__.produce_via_field_and_stats self, stats
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

    # ->
    end
  end
end
