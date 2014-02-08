module Skylab::Headless::CLI::Table

  # (emigrated from porcelain, one of its last remaining useful nerks)
  # a rewrite of a table renderer that, as an excercise:
  #   + is purely event-driven
  #   + does some clever bs with type inference and alignment
  # issues / wishlist:
  #
  #   * left/right alignment config options

  Headless = ::Skylab::Headless
  Callback = Headless::Library_::Callback
  Table = self  # partly b.c Callback is not part of headless proper
  TERM_SEPARATOR_STRING_ = Headless::TERM_SEPARATOR_STRING_

  class Table::Shell
    # here have a goofy experiment - the public methods here (direct and
    # derived) are isomorphic with the parameters you can pass as settings
    # to your call to Table.render (or you can manipualte it directly in
    # the block).

    Callback[ self, :employ_DSL_for_digraph_emitter ]

    event_factory -> { Callback::Event::Factory::Isomorphic.new Table::Events }

    listeners_digraph  row: :text,  # (contrast with `textual`, `on_text` reads better)
         info: :text,  # (:info is strictly a branch not a leaf)
        empty: :info,
    row_count: :datapoint

    attr_writer :head, :tail, :separator

    def field! symbol
      @field_box.if? symbol, Headless::IDENTITY_, -> box do
        box.add symbol, Table::Field::Shell.new
      end
    end
    # --*--
    def initialize
      @head = @tail = @separator = nil
      @field_box = Headless::Library_::Formal_Box::Open.new
    end
  end

  module Table

    shell_and_result = -> param_h, blk do
      shell = Shell.new ; res = nil
      param_h.each { |k, v| shell.send "#{ k }=", v } if param_h
      if blk then blk[ shell ] else
        res = Headless::Library_::StringIO.new
        shell.on_text { |txt| res.puts txt }
      end
      shell.instance_exec do
        @head ||=nil ; @tail ||= nil ; @separator ||= TERM_SEPARATOR_STRING_
      end
      [ shell, res ]
    end

    census_and_rows = -> row_enum, shell do
      census = Census.new
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

    render = -> row_enum, param_h=nil, &blk do
      shell, sio = shell_and_result[ param_h, blk ]
      census, rows = census_and_rows[ row_enum, shell ]
      Table::Engine.new( shell, census, rows, sio ).render
    end

    define_singleton_method :render, &render
  end

  module Table::Events
    Headless::Library_::Boxxy[ self ]  # this gives us `const_fetch`
  end

  module Table::Events::Datapoint
    def self.event graph, stream_name, payload_x
      payload_x
    end
  end

  module Table::Events::Text
    def self.event graph, stream_name, payload_x
      payload_x
    end
  end

  class Table::Engine < Table::Shell

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

  private

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
          @field_h[ stats.index ] = Table::Field.new stats.index, stats
        end
      end
      nil
    end
  end

  class Table::Census

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
        @hash[ idx ] = Table::Cel::Stats.new idx
      end.see text
      nil
    end

  private

    def initialize
      @hash = { }
    end
  end
                                  # (it's really cel-type but we don't model
  class Table::Cel                #  cels directly and it's a nicer name)

    attr_reader :align

    attr_reader :ancestor

    def match? str
      @rx =~ str
    end

    attr_reader :render

    attr_reader :rx

    attr_reader :symbol

  private

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
      @ancestor = ( Table::Cels.const_fetch @ancestor_i if @ancestor_i )
      freeze
    end

    def ancestor_names_recursive
      @ancestor_names_recursive ||= begin
        box = Headless::Library_::Formal_Box::Open.new
        _ancestor_names_recursive box
        box.names
      end
    end

    def _ancestor_names_recursive box
      if @ancestor
        box.if? @ancestor, -> x { }, -> bx do
          bx.add @ancestor, true
          anc = Table::Cels.fetch @ancestor
          anc.send :_ancestor_names_recursive, box
        end
      end
      nil
    end
  end

  class Table::Cel
    FLOAT_DETAIL_RX = /\A(-?\d+)((?:\.\d+)?)\z/  # used 2x
  end

  module Table::Cels

    Headless::Library_::Boxxy[ self ]

    parse_styles   = Headless::CLI::FUN::Parse_styles
    unparse_styles = Headless::CLI::FUN::Unparse_styles
    unstyle      = Headless::CLI::Pen::FUN.unstyle
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

    float_detail_rx = Table::Cel::FLOAT_DETAIL_RX

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

    STRING = Table::Cel.new :string, rx: //, align: :left, render: common


    BLANK = Table::Cel.new :blank, ancestor: :string,
                                   rx: /\A[[:space:]]*\z/, render: common

    FLOAT = Table::Cel.new :float, ancestor: :string,
                                   rx: /\A-?\d+(?:\.\d+)?\z/, render: float

    INTEGER = Table::Cel.new :integer, ancestor: :float, align: :right,
                                       rx: /\A-?\d+\z/, render: common

  end

  class Table::Cel::Stats

    def has_information
      0 < @num_non_nil_seen
    end

    attr_reader :index

    attr_reader :max_h

    attr_reader :type_h

    # --*--

    blank_rx = Table::Cels::BLANK.rx
    unstyle = Headless::CLI::Pen::FUN.unstyle
    start_type = Table::Cels::INTEGER
    float_detail_rx = Table::Cel::FLOAT_DETAIL_RX

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

  private

    def initialize idx
      @num_non_nil_seen = 0
      @index = idx
      @max_h, @type_h = 2.times.map { ::Hash.new { |h, k| h[k] = 0 } }
      # `max_h` -  max width seen in this column for this kind of thing
      # `type_h` - number of each type of thing seen in this column
    end
  end

  class Table::Field

    attr_reader :is_align_left

    def max_width k
      @stats.max_h[ k ] if @stats.max_h.key? k
    end

    def render str
      @render[ str ]
    end

  private

    def initialize index, stats
      @index = index
      mode = stats.type_h.reduce( [ :string, 0 ] ) do |m, pair|
        pair.last > m.last ? pair : m
      end.first
      @cel = Table::Cels.const_fetch mode
      @stats = stats
      @is_align_left = :left == @cel.align
      @render = @cel.render[ self ]
    end
  end

  class Table::Field::Shell
    attr_accessor :style  # a function
  end
end
