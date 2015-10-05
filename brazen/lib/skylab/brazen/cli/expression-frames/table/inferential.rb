module Skylab::Brazen

  module CLI::Expression_Frames::Table::Inferential  # [#096.C]

    # emigrated from [hl] - this file has some ANCIENT style in it...

    class << self
      def render row_enum, param_h=nil, & x_p
        Render___[ row_enum, param_h, & x_p ]
      end
    end # >>

    # <-

  # (emigrated from porcelain, one of its last remaining useful nerks)
  # a rewrite of a table renderer that, as an excercise:
  #   + is purely event-driven
  #   + does some clever bs with type inference and alignment
  # issues / wishlist:
  #
  #   * left/right alignment config options

  class Table_Session__

    # here have a goofy experiment - the public methods here (direct and
    # derived) are isomorphic with the parameters you can pass as settings
    # to your call to render (or you can manipualte it directly in
    # the block).

    Callback_[ self, :employ_DSL_for_digraph_emitter ]

    listeners_digraph  row: :text,  # (contrast with `textual`, `on_text` reads better)
         info: :text,  # (:info is strictly a branch not a leaf)
        empty: :info,
    row_count: :datapoint

    def initialize
      @field_box = Callback_::Box.new
      @head = @separator = @tail = nil
    end

    attr_writer :head, :tail, :separator

    def field! symbol
      @field_box.touch symbol do
        Field_Session___.new
      end
    end

    def build_digraph_event x, _i, _esg
      x  # text, datapoints
    end
  end

  class Field_Session___
    attr_accessor :style  # a function
  end


  Render___ = -> do

    shell_and_result = -> param_h, blk do
      shell = Table_Session__.new
      param_h.each { |k, v| shell.send "#{ k }=", v } if param_h
      if blk then blk[ shell ] else
        x = Home_.lib_.string_IO.new
        shell.on_text { |txt| x.puts txt }
      end
      shell.instance_exec do
        @head ||=nil ; @tail ||= nil ; @separator ||=  SPACE_  # TERM_SEPARATOR_STRING_
      end
      [ shell, x ]
    end

    census_and_rows = -> row_enum, shell do
      census = Census___.new
      field_box = shell.instance_variable_get :@field_box
      rows_cache = row_enum.reduce [] do |rows, cel_enum|
        rows << ( cel_enum.each_with_index.reduce [] do |cels, (cel_x, idx)|
          cel_s = if ::String === cel_x
            cel_x
          elsif ::Array === cel_x
            if 2 == cel_x.length
              field_box.fetch( cel_x.first ).style[ cel_x.last ]
            else
              raise ::ArgumentError, "expecting 2 had #{ cel_x.length } arr"
            end
          elsif ::NilClass
            nil
          else
            raise ::ArgumentError, "no strategy for #{ cel_x.class }"
          end
          census.see idx, cel_s
          cels << cel_s
        end )
      end
      [ census, rows_cache ]
    end

    -> row_enum, param_h=nil, & edit_p do

      shell, sio = shell_and_result[ param_h, edit_p ]

      census, rows = census_and_rows[ row_enum, shell ]

      Implementation___.new( shell, census, rows, sio ).render
    end
  end.call

  class Implementation___ < Table_Session__

    def render
      call_digraph_listeners :row_count, @row_a.length
      if @row_a.length.zero?
        call_digraph_listeners :empty, '(empty)'
      else
        @row_a.each do |col_a|
          call_digraph_listeners :row, "#{ @head }#{
            }#{ @idx_a.map do |idx|
              @field_h.fetch( idx ).render col_a[idx]
            end.join @separator
          }#{ @tail }"
        end
      end
      if @sio
        @sio.rewind
        @sio.read
      end
    end

    def initialize shell, census, rows, sio
      shell.instance_variables.each do |ivar|
        instance_variable_set ivar, shell.instance_variable_get( ivar )
      end
      @row_a, @sio = rows, sio
      @field_h = { }
      @idx_a = []
      census.fields.each do |stats|
        if stats.has_information
          @idx_a << stats.index
          @field_h[ stats.index ] = Field___.new stats.index, stats
        end
      end
      NIL_
    end
  end

  class Census___

    def fields
      ::Enumerator.new do |y|
        # we're just being crazy - what is the min and max index seen!?
        min, max = @hash.keys.reduce [ nil, nil ] do |m, x|
          m[0] = x if ! m[0] || m[0] > x
          m[1] = x if ! m[1] || m[1] < x
          m
        end
        if min && max
          ( min .. max ).each do |idx|
            if @hash.key? idx  # sure why not - skip columns that you never saw
              y << @hash[ idx ]
            end
          end
        end
        nil
      end
    end

    def see idx, text
      @hash.fetch idx do
        @hash[ idx ] = Type_Stats___.new idx
      end.see text
      nil
    end

    def initialize
      @hash = { }
    end
  end

  class Field_Type__

    attr_reader :align

    attr_reader :ancestor

    def match? str
      @rx =~ str
    end

    attr_reader :render

    attr_reader :rx

    attr_reader :symbol

    param_h_h = {
      align: -> v { @align = v },
      ancestor: -> v { @ancestor_i = v },
      render: -> v { @render = v },
      rx: -> v { @rx = v }
    }

    define_method :initialize do |symbol, param_h|
      @symbol = symbol
      @ancestor_i = nil
      param_h.each do |k, v|
        instance_exec v, & param_h_h.fetch( k )
      end
      @ancestor = if @ancestor_i
        Autoloader_.const_reduce [ @ancestor_i ], Types__
      end
      freeze
    end

    def ancestor_names_recursive
      @ancestor_names_recursive ||= begin
        bx = Callback_::Box.new
        _ancestor_names_recursive bx
        bx.get_names
      end
    end

    public def _ancestor_names_recursive box
      if @ancestor
        bx.touch @ancestor do
          Types__.fetch( @ancestor )._ancestor_names_recursive bx
          ACHIEVED_
        end
      end
      nil
    end
  end

  FLOAT_DETAIL_RX__ = /\A(-?\d+)((?:\.\d+)?)\z/  # used 2x

  module Types__

    mod = Home_::CLI::Styling
    unstyle = mod::Unstyle

    parse_styles = mod::Parse_styles
    unparse_styles = mod::Unparse_style_sexp

    hackable_a = [ :style, :string, :style ]

    common = -> fld do
      fmt = "%#{ '-' if fld.is_align_left }#{ fld.max_width :full }s"
      -> str do
        sexp = parse_styles[ str ]  # are you ready for ridiculous? if the
        if sexp  # string was styled, remove the styling, apply the width
          if hackable_a == sexp.map(& :first )  # resizing, and re-apply styling
            sexp[1][1] = fmt % sexp[1][1]
            unparse_styles[ sexp ]
          else
            unstyle[ str ]  # glhf
          end
        else
          fmt % str
        end
      end
    end

    float_detail_rx = FLOAT_DETAIL_RX__

    float = -> fld do
      int_max = fld.max_width :int_part
      flt_max = fld.max_width :frac_prt
      fmt = "%#{ int_max }s%-#{ flt_max }s"
      fallback = common[ fld ]
      -> str do
        md = float_detail_rx.match str
        if md
          fmt % md.captures
        else
          fallback[ str ]
        end
      end
    end

    STRING = Field_Type__.new :string, rx: //, align: :left, render: common


    BLANK = Field_Type__.new :blank, ancestor: :string,
                                   rx: /\A[[:space:]]*\z/, render: common

    FLOAT = Field_Type__.new :float, ancestor: :string,
                                   rx: /\A-?\d+(?:\.\d+)?\z/, render: float

    INTEGER = Field_Type__.new :integer, ancestor: :float, align: :right,
                                       rx: /\A-?\d+\z/, render: common

  end

  class Type_Stats___

    def has_information
      0 < @num_non_nil_seen
    end

    attr_reader(
      :index,
      :max_h,
      :type_h,
    )

    # --*--

    blank_rx = Types__::BLANK.rx

    float_detail_rx = FLOAT_DETAIL_RX__

    start_type = Types__::INTEGER

    unstyle = Home_::CLI::Styling::Unstyle

    define_method :see do |cel_x|  # `cel_x` must be ::String or nil
      if ! cel_x.nil?
        ::String === cel_x or raise ::ArgumentError, "table cels *must* #{
          }be nil or string for reasons - #{ cel_x.class }"
        @num_non_nil_seen += 1
        raw = unstyle[ cel_x ]
        @max_h[:full] = raw.length if raw.length > @max_h[:full]
        if blank_rx =~ raw
          @type_h[:blank] += 1
        else
          type = start_type
          type = type.ancestor until type.match? raw  # ballzy
          @type_h[ type.symbol ] += 1
          if :float == type.symbol
            md = float_detail_rx.match raw
            @max_h[:int_part] = md[1].length if md[1].length > @max_h[:int_part]
            @max_h[:frac_prt] = md[2].length if md[2].length > @max_h[:frac_prt]
          end
        end
      end
    end

    def initialize idx
      @num_non_nil_seen = 0
      @index = idx
      @max_h, @type_h = 2.times.map { ::Hash.new { |h, k| h[k] = 0 } }
      # `max_h` -  max width seen in this column for this kind of thing
      # `type_h` - number of each type of thing seen in this column
    end
  end

  class Field___

    attr_reader :is_align_left

    def max_width k
      @stats.max_h[ k ] if @stats.max_h.key? k
    end

    def render str
      @render[ str ]
    end

    def initialize index, stats
      @index = index
      mode = stats.type_h.reduce( [ :string, 0 ] ) do |m, pair|
        pair.last > m.last ? pair : m
      end.first
      @cel = Autoloader_.const_reduce [ mode ], Types__
      @stats = stats
      @is_align_left = :left == @cel.align
      @render = @cel.render[ self ]
    end
  end
  # ->
  end
end
