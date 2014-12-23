module Skylab::Face

  class CLI::Table  # read [#036] the CLI table narrative #storypoint-5

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
    #     Table[ :a ]  # => NoMethodError: undefined method `each' for :a..
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

    class << self
      def [] * x_a
        new( x_a ).execute
      end
      def via_iambic x_a
        if x_a.length.zero?
          self
        else
          new( x_a ).execute
        end
      end
    end

    def initialize x_a
      @do_show_header = @field_box = @left_x =
        @right_x = @read_rows_from =
        @sep_x = @target_width_d = @write_lines_to = nil
      Table_Shell__.new 0, x_a, self
    end

    attr_writer :do_show_header, :field_box, :left_x, :read_rows_from,
      :right_x, :sep_x, :write_lines_to

    alias_method :dupe, :dup  # :+[#mh-021] (ok)

    def initialize_copy _otr_
      # @do_show_header, @left_x @right_x, @sep_x copy-by-reference

      # ALSO @read_rows_from, @write_lines_to copy-by-reference (for now)

      @field_box and @field_box = @field_box.dupe  # deep copy #storypoint-80
      nil
    end

    class Table_Shell__
      def initialize d, x_a, kernel
        @d = d ; @kernel = kernel ; @x_a = x_a
        @field_box = nil
        1 == @x_a.length and when_one
        absrb
        if @field_box
          @kernel.do_show_header.nil? and @kernel.do_show_header = true
          @kernel.field_box and raise "field merge not implemented"
          @kernel.field_box = @field_box
        end
      end
    private
      def when_one  # hack - whenever exactly 1 element is passed
        # assume it is a rows enumerator.
        @x_a.unshift :read_rows_from ; nil
      end
    LIB_.fields_from_methods :niladic, :absorber, :absrb, -> do
      def field
        bx = (( @field_box ||= LIB_.box.new ))
        shell = Field_Shell__.new @d, @x_a, bx
        @d = shell.d
      end
      def header
        x = iambic_property
        :none == x or raise ::ArgumentError, "only 'none' is allowed (#{ x })"
        @kernel.do_show_header = false
      end
      def left
        @kernel.left_x = iambic_property
      end
      def read_rows_from
        @kernel.read_rows_from = iambic_property  # empty ary must be OK here
      end
      def right
        @kernel.right_x = iambic_property
      end
      def sep
        @kernel.sep_x = iambic_property
      end
      def show_header
        @kernel.do_show_header = iambic_property
      end
      def target_width
        @kernel.accept_target_width_from_stream @iambic_scan
      end
      def write_lines_to
        @kernel.write_lines_to = iambic_property
      end
    end
    end

    # specify custom headers, separators, and output functions:
    #
    #     a = []
    #     x = Face_::CLI::Table[ :field, 'Food', :field, 'Drink',
    #       :left, '(', :sep, ',', :right, ')',
    #       :read_rows_from, [[ 'nut', 'pomegranate' ]],
    #       :write_lines_to, a.method( :<< ) ]
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
          @field.name_i ||= :"#{ bx.length }"
        end
        bx.add @field.name_i, @field ; nil
      end
      attr_reader :d
      LIB_.fields_from_methods(
        :niladic, :passive, :absorber, :absrb_passive,
      -> do
        def cel_renderer_builder
          x = iambic_property
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
          @field.name_i = iambic_property
        end
        def label
          @field.label_s = iambic_property
          @field.name_i.nil? and @field.name_i = @field.label_s.intern
        end
        def left
          @field.align_i = :left
        end
        def right
          @field.align_i = :right
        end
      end )
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
      attr_accessor :align_i, :label_s, :name_i, :cel_renderer_p_p
    end

  public

    def execute
      ok = @read_rows_from  # nothing to do when no data producers
      ok &&= string_pass
      ok && render_pass
    end

  private

    # ~ the string pass

    def string_pass
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
        if (( @scn = bld_row_stream ))
          yield( * rslv_two_from_scan )
        else
          yield @scn
        end
      end
    private
      def bld_row_stream
        p = nil
        initialize_normal_p = -> do
          ea = @kernel.read_rows_from.to_enum
          p = -> do
            begin
              ea.next
            rescue ::StopIteration
            end
          end ; nil
        end
        if @kernel.do_show_header
          p = -> do
            initialize_normal_p[]
            @kernel.field_box.map( & :label_s )
          end
        else
          initialize_normal_p[]
        end
        Callback_::Scn.new { p[] }
      end
      def rslv_two_from_scan
        h = ::Hash.new do |h_, d|
          h_[ d ] = Field_Statistics__.new d
        end
        cel_matrix = []
        while (( row = @scn.gets ))
          cel_matrix.push( cel_row = [] )
          row.each_with_index do |cel_x, d|
            cel_row.push h[ d ].see_value_and_build_cel( cel_x )
          end
        end
        [ h.length.times.map do |d|
            h.fetch( d ).finish_string_pass
          end, cel_matrix ]
      end
    end
  public
    attr_reader :do_show_header, :field_box, :read_rows_from

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

    def render_pass
      cel_renderers = prdc_cel_renderers
      if @write_lines_to
        puts_p = @write_lines_to
      else
        io = Library_::StringIO.new
        puts_p = io.method :puts
      end

      left = @left_x || DEFAULT_LEFT_MARGIN__
      sep = @sep_x || DEFAULT_SEPARATOR__
      right = @right_x || DEFAULT_RIGHT_MARGIN__

      scn = get_cel_row_iterator
      while (( row = scn.gets ))
        puts_p[ "#{ left }#{
          ( row.map.with_index do |cel, d|
            cel_renderers.fetch( d ).call cel
          end ) * ( sep ) }#{
          }#{ right }" ]
      end
      io && io.string
    end

    DEFAULT_LEFT_MARGIN__ = '| '.freeze
    DEFAULT_SEPARATOR__ = ' | '.freeze
    DEFAULT_RIGHT_MARGIN__ = ' |'.freeze

    def get_cel_row_iterator
      d = -1 ; last = @cel_matrix.length - 1
      Callback_::Scn.new do
        if d < last
          @cel_matrix.fetch d += 1
        end
      end
    end

    def prdc_cel_renderers
      @widest_row_cels_count = @field_stats.length
      @field_fetcher = prdc_field_fetcher
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

    def prdc_field_fetcher
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
    #     P = Face_::CLI::Table.curry :left, '<', :sep, ',', :right, '>'
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

    class << self
      def curry * x_a
        new( x_a ).freeze
      end
    end
  public
    def curry * x_a
      mutable_kernel = dupe
      mutable_kernel.absorb_iambic_flly x_a
      mutable_kernel.freeze
    end
    def [] * x_a  # typically from a frozen, curried kernel
      mutable_kernel = dupe
      mutable_kernel.absorb_iambic_flly x_a
      mutable_kernel.execute
    end
  protected
    def absorb_iambic_flly x_a
      Table_Shell__.new 0, x_a, self
    end

    # ~ done with currying

    # ~ support for the "fill" subsystem

    def self.some_screen_width
      Table_::Fill_.some_screen_w
    end
    def self.any_calculated_screen_width
      Table_::Fill_.any_calculated_screen_w
    end
  public
    def accept_target_width_from_stream scan
      @target_width_d = scan.gets_one ; nil
    end
  private
    class Field__
      attr_accessor :fill
    end
    def prdc_late_pass_renderers a
      Table_::Fill_.produce_late_pass_renderers a do |o|
        o.field_fetcher = @field_fetcher
        o.field_stats = @field_stats
        o.left = @left_x ; o.sep = @sep_x ; o.right = @right_x
        o.num_fields = @widest_row_cels_count
        o.target_width_d = @target_width_d
      end ; nil
    end

    MINUS_ = '-'.freeze
    Table_ = self
  end
end
