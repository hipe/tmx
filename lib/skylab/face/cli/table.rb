module Skylab::Face

  class CLI::Table  # read [#036] the CLI table narrative #storypoint-5

    # a table
    # with nothing renders nothing
    #
    #     Table = Face::CLI::Table
    #     Table[]  # => nil
    #
    # with one thing, must respond to each (in two dimensions)
    #
    #     Table[ :a ]  # => NoMethodError: undefined method `each' for :a..
    #
    # that is, an array of atoms won't fly either
    #
    #     Table[ [ :a, :b ] ]  # => NoMethodError: undefined method `each_wi..
    #
    # but here is the smallest table you can render, which is boring
    #
    #     Table[ [] ]  # => ''
    #
    # here's a minimal non-empty table (note you get default styling):
    #
    #     Table[ [ [ 'a' ] ] ]   # => "|  a |\n"
    #
    # for a minimal normative example:
    #
    #     act = Table[ [ [ 'Food', 'Drink' ], [ 'donuts', 'coffee' ] ] ]
    #     exp = <<-HERE.gsub %r<^ +>, ''
    #       |    Food |   Drink |
    #       |  donuts |  coffee |
    #     HERE
    #     act  # => exp

    class << self
      def [] * a
        via_iambic a
      end
      def via_iambic a
        new( a ).execute
      end
    end

    def initialize x_a
      @left_x = @sep_x = @right_x = @do_show_header = @field_box =
        @read_rows_from = @write_lines_to = nil
      1 == x_a.length and when_one x_a
      abs_iambic_fully x_a
      clear_iambic_ivars
    end
  private
    def when_one x_a  # hack - whenever exactly 1
      # element is passed assume it is a rows enumerator.
      x_a.unshift :read_rows_from ; nil
    end

    # ~ :+[#mh-021] typical base class implementation:
  public
    def dupe
      dup
    end
    def initialize_copy _otr_
      # copy-by-reference @do_show_header, @left_x, @read_rows_from,
      # @right_x, @sep_x, @write_lines_to

      # do not copy e.g @d, @x_a, @x_a_length @iambic_scan (iambic parse)
      clear_iambic_ivars

      # deep copy:
      @field_box and @field_box = @field_box.dupe  # #storypoint-80
      nil
    end
  protected
    def get_args_for_copy
      [ @field_box ]
    end
    # ~

  public

    def execute
      begin
        @read_rows_from or break  # nothing to do when no data producers
        r = first_pass or break
        r = render
      end while nil
      r
    end

   private

    def first_pass  # #storypoint-100
      max_a = [ ] ; get_max_of_row = -> ea do
        ea.each_with_index do |x, d|
          if (( len = max_a[ d ] ))
            len < x.length and max_a[ d ] = x.length
          else
            max_a[ d ] = x.length
          end
        end
      end
      @do_show_header and get_max_of_row[ header_row ]
      cache_a = [ ] ; ok = @read_rows_from.each do |row_ea|
        get_max_of_row[ row_ea ]
        cache_a << row_ea
        nil
      end
      if ok
        @max_a = max_a ; @cache_a = cache_a ; true
      else
        @max_a = @cache_a = nil ; ok  # promulgate particular false-ish-ness
      end
    end

    def render
      (( yp = @write_lines_to )) or begin
        io = Library_::StringIO.new
        yp = io.method :puts
      end
      fmt = get_format
      row_p = -> cel_ea { yp[ fmt % cel_ea ] }
      @do_show_header and row_p[ header_row ]
      @cache_a.each( & row_p )
      io && io.string
    end

    def get_format
      sep = @sep_x || SEP_DEFAULT_
      "#{ @left_x || LEFT_DEFAULT_ }#{
        a = (( bx = @field_box )) ? bx._a : MONADIC_EMPTINESS_
        num_cols.times.map do |d|
          sign = MINUS_ if (( k = a[ d ] )) && :left == bx.fetch( k ).align_i
          "%#{ sign }#{ @max_a[ d ] || 0 }s"
        end * sep
      }#{ @right_x || RIGHT_DEFAULT_ }"
    end

    MINUS_ = '-'.freeze
    MONADIC_EMPTINESS_ = -> _ { }
    LEFT_DEFAULT_ = '|  '.freeze
    SEP_DEFAULT_ = ' |  '.freeze
    RIGHT_DEFAULT_ = ' |'.freeze

    def num_cols
      @max_a.length
    end

    Lib_::Fields_from_methods[ :absorber, :abs_iambic_fully, -> do
      def read_rows_from
        @read_rows_from = iambic_property ; nil
      end
    end ]
  end

  class CLI::Table

    # but wait there's more-
    # you can specify custom headers, separators, and output functions:
    #
    #     Table = Face::CLI::Table
    #     a = []
    #     r = Table[ :field, 'Food', :field, 'Drink',
    #                :left, '(', :sep, ',', :right, ')',
    #                :read_rows_from, [[ 'nut', 'pomegranate' ]],
    #                :write_lines_to, a.method( :<< )
    #                ]
    #
    #     r  # => nil
    #     ( a * 'X' )  # => "(Food,      Drink)X( nut,pomegranate)"

    private
    Lib_::Fields_from_methods[ :absorber, :absorb_iambic_fully, -> do
      def field
        bx = (( @field_box ||= Lib_::Box[] ))
        fld = Field__.new @d, @x_a, bx.length
        @d = fld.d
        bx.add fld.name_i, fld
        @do_show_header.nil? and @do_show_header = true
        @header_cel_a = nil
      end
      def write_lines_to
        @write_lines_to = iambic_property ; nil
      end
      def show_header
        @do_show_header = iambic_property ; nil
      end
      def left
        @left_x = iambic_property ; nil
      end
      def sep
        @sep_x = iambic_property ; nil
      end
      def right
        @right_x = iambic_property ; nil
      end
    end ]

    def header_row
      @header_cel_a ||= @field_box.map( & :label_s )
    end

    # this syntax is "contoured" - fields themselves eat keywords
    # like so : you can align `left` or `right` (and watch for etc)
    #
    #     str = Face::CLI::Table[
    #       :field, :right, :label, "Subproduct",
    #       :field, :left, :label, "num test files",
    #       :read_rows_from, [ [ 'face', '100' ], [ 'headless', '99' ] ] ]
    #
    #     exp = <<-HERE.unindent
    #       |  Subproduct |  num test files |
    #       |        face |  100            |
    #       |    headless |  99             |
    #     HERE
    #     str # => exp

    class Field__
      def initialize d, x_a, idx
        @d = d
        @name_i = nil
        if x_a.fetch( d ).respond_to? :ascii_only?
          prepare_peaceful_parse_for_iambic x_a
          label
        else
          absorb_iambic_passively x_a
        end
        @name_i ||= :"#{ idx }"  # always give it a unique id to act as a key
        d = @d ; clear_iambic_ivars ; @d = d
        freeze  # ensure that we can dupe with shallow copies
      end

      attr_reader :label_s, :name_i, :align_i
      attr_reader :d

      private
      Lib_::Fields_from_methods[
        :passive, :absorber, :absorb_iambic_passively,
      -> do
        def left
          @align_i = :left ; nil
        end
        def right
          @align_i = :right ; nil
        end
        def label
          @label_s = iambic_property
          @name_i.nil? and @name_i = @label_s.intern
          nil
        end
        def id  # typically for fields w/o labels, i.e non-displayed headers
          @name_i = iambic_property ; nil
        end
      end ]
    end

    # but the real fun begins with currying - curry a table in one place
    # and (perhaps modify it) and use it in another (CASCADING stylesheet like!)
    #
    #     P = Face::CLI::Table.curry :left, '<', :sep, ',', :right, '>'
    #
    #     P[ :sep, ';', :read_rows_from, [%w(a b), %w(c d)] ]  # => "<a;b>\n<c;d>\n"
    #
    #     P[ [ %w(a b), %w(c d) ] ]  # => "<a,b>\n<c,d>\n"
    #
    # you can even curry the curried "function", curry the data, and so on -
    #
    #     Q = P.curry( :read_rows_from, [ %w( a b ) ], :sep, 'X' )
    #     Q[ :sep, '_' ]  # => "<a_b>\n"
    #     Q[]  # => "<aXb>\n"

    def self.curry *a
      # (currying from the class means you get no ivars out of the box)
      new( a ).freeze
    end

  public

    def [] *a  # #storypoint-280
      cury_iambic( a ).execute
    end

    def curry * x_a
      cury_iambic x_a
    end
  private
    def cury_iambic x_a
      1 == x_a.length and when_one x_a
      otr = dupe
      otr.absorb_iambic_fully x_a
      otr
    end
  public

    Multiline_column_B = -> row_a, cel_a, a do
      #  #todo spec and/or cleanup interface
      col_a = [ cel_a ]
      if a.length.zero?
        col_a << ''
      else
        col_a << a.fetch( 0 )
      end
      row_a << col_a
      if 1 < a.length
        row_a.concat a[ 1 .. -1 ].map { |s| [ '', s ] }
      end
      nil
    end

    EMPTY_A_ = [].freeze
  end
end
