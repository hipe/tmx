# rewrite as an excercize to be purely event-driven

# issues / wishlist:
#
#   * left/right alignment config options


require_relative 'core'
require 'skylab/code-molester/core'
require 'skylab/pub-sub/core'

module ::Skylab::Porcelain::Table

  Sexp = ::Skylab::CodeMolester::Sexp
  TiteColor = ::Skylab::Porcelain::TiteColor

  module Column
  end

  class Column::Type < Struct.new(:align, :ancestor_names, :name, :regex, :renderer_factory)
    def ancestor
      ancestor_names.size == 1 or fail("ancestor() accessor can only be " <<
        "used on nodes with one ancestor (\"parent\").  #{name.inspect} " <<
        "has: (#{ancestor_names.map(&:inspect).join(', ')})")
      Column::TYPES[ancestor_names.first]
    end
    def ancestors= o # for now this adds to the ordered set, but it might change!
      self.ancestor_names |= (Array===o ? o : [o])
    end
    def ancestor_names_recursive seen = nil
      Enumerator.new do |y|
        seen ||= {}
        ancestor_names.each do |k|
          unless seen[k]
            seen[k] = true
            anc = Column::TYPES[k] or fail("huh?")
            y << k
            anc.ancestor_names_recursive(seen).each { |kk| y << kk }
          end
        end
      end
    end
    def build_cel_renderer col
      renderer_factory or fail("#{name} did not define a renderer (a build_cel_renderer)")
      renderer_factory.call col
    end
    def initialize name, args
      super(nil, [], name, nil, nil)
      args.each { |k, v| send("#{k}=", v) }
    end
    def match? str
      regex.match(str)
    end
  end

  module Column
    TYPES = {
      :string  => (STRING   = Type.new(:string,  :regex => //, :align => :left)),
      :float   => (FLOAT    = Type.new(:float,   :ancestors => :string,  :regex => /\A-?\d+(?:\.\d+)?\z/)),
      :integer => (INTEGER  = Type.new(:integer, :ancestors => :float,   :regex => /\A-?\d+\z/, :align => :right)),
      :blank   => (BLANK    = Type.new(:blank,   :ancestors => :string,  :regex => /\A[[:space:]]*\z/ ))
    }
    TIGHTEST = INTEGER
    FLOAT_DETAIL_RE = /\A(-?\d+)((?:\.\d+)?)\z/
  end

  parse_styles = -> do
    # Parse a string with ascii styles into an S-expression.

    style_parser_rx = /\A (?<string>[^\e]*)  \e\[
      (?<digits> \d+  (?: ; \d+ )* )  m  (?<rest> .*) \z/x

    -> str do
      out = nil
      while md = style_parser_rx.match(str)
        out ||= []
        if md[:string].length.nonzero?
          out.push Sexp[ :string, md[:string] ]
        end
        out.push Sexp[ :style, * md[:digits].split(';').map(&:to_i) ]
        str = md[:rest]
      end
      if out and str.length.nonzero?
        out.push Sexp[ :string, str ]
      end
      out
    end

  end.call

  Column::STRING.renderer_factory = ->(col) do
    fmt = "%#{'-' if col.align_left?}#{col.max_width_seen[:full]}s"
    ->(str) do
      if a = parse_styles[ str ]
        if 2 == a.count { |p| :style == p.first } and :style == a.first.first and
        :style == a.last.first and [0] == a.last[1..-1]
          "\e[#{a.first[1..-1].join(';')}m#{ fmt % [a[1].last] }\e[0m" # jesus wept
        else
          str # whatever you do to "fix" these cases will require overhauling a lot
        end
      else
        fmt % [str]
      end
    end
  end

  Column::BLANK.renderer_factory = Column::INTEGER.renderer_factory = Column::STRING.renderer_factory

  Column::FLOAT.renderer_factory = ->(col) do
    int_max = col.max_width_seen[:integer_part]
    flt_max = col.max_width_seen[:fractional_part]
    fmt = "%#{int_max}s%-#{flt_max}s"
    fallback_renderer = Column::STRING.build_cel_renderer(col)
    ->(str) do
      if md = Column::FLOAT_DETAIL_RE.match(str)
        fmt % md.captures
      else
        fallback_renderer.call(str)
      end
    end
  end

  Column::Type.tap do |klass|
    Column::TYPES.values.map(&:name).each do |name|
      klass.send(:define_method, "#{name}?") do
        name == self.name or ancestor_names_recursive.detect { |k| name == k }
      end
    end
    klass.send(:alias_method, :numeric?, :float?)
  end

  class Column::ViewModel < Struct.new(:align, :index, :max_width_seen, :printf_format, :type_stats,
    :field_name, :formatter
  )
    def align_left?
      align and return :left == align
      :left == (inferred_type || Column::STRING).align
    end
    def cel_renderer
      @cel_renderer ||= (inferred_type || STRING).build_cel_renderer(self)
    end
    def format &b
      1 == b.arity or raise ArgumentError.new("formatter blocks must always take exactly one argument")
      self.formatter = b
    end
    def _format_cel str
      formatter ? formatter.call(str) : str.to_s
    end
    def initialize index, opts = nil
      @cel_renderer = @inferred_type = nil
      super(nil, index, nil, nil, nil)
      self.type_stats = Hash.new { |h, k| h[k] = 0 }
      self.max_width_seen = Hash.new { |h, k| h[k] = 0 }
      opts and opts.each { |k, v| send("#{k}=", v) }
    end
    def inferred_type
      @inferred_type ||= infer_type
    end
    def infer_type
      Column::TYPES[infer_type_name] || Column::STRING
    end
    def infer_type_name
      type_stats.empty? and return :string
      type_stats.reduce { |m, o| o.last > m.last ? o : m }.first
    end
    def render_cel str
      cel_renderer.call(str)
    end
    def see val
      val.nil? and return
      val = TiteColor.unstylize val
      val.length > max_width_seen[:full] and max_width_seen[:full] = val.length
      if Column::BLANK.match?(val)
        type_stats[:blank] += 1
      else
        type = Column::TIGHTEST
        type = type.ancestor until type.match?(val)
        type_stats[type.name] += 1
        if :float == type.name
          md = Column::FLOAT_DETAIL_RE.match(val)
          md[1].length > max_width_seen[:integer_part] and max_width_seen[:integer_part] = md[1].length
          md[2].length > max_width_seen[:fractional_part] and max_width_seen[:fractional_part] = md[2].length
        end
      end
    end
  end


  module Columns
  end

  class Columns::ViewModelAggregator < Hash
    def initialize
      super { |h, k| h[k] = Column::ViewModel.new(k) }
    end
    def ordered
      Enumerator.new { |y| ordered_keys.each { |idx| y << self[idx] } }
    end
    def ordered_keys
      size.zero? and return []
      min, max = keys.reduce([nil,nil]) { |m, o| m[0] = o if !m[0] || m[0] > o ; m[1] = o if !m[1] || m[1] < o ; m }
      (min..max).to_a
    end
  end

  module RenderTable
    def build_table_columns_inferences_aggregator
      Columns::ViewModelAggregator.new
    end
    class OnTable < Struct.new(:head, :tail, :separator)
      extend ::Skylab::PubSub::Emitter
      emits(:all, :info => :all, :empty => :info, :row => :all, :row_count => :data)

      def field name
        @fields[name] ||= Column::ViewModel.new(nil, field_name: name)
      end
      alias_method :[], :field
      attr_reader :fields
      def format_cel field_name, cel_value
        fields[field_name] ? fields[field_name]._format_cel(cel_value) : cel_value
      end
      def initialize
        @fields = {}
      end
    end
    def render_table row_enumerator, opts=nil
      o = OnTable.new
      opts and opts.each { |k, v| o.send("#{k}=", v) }
      if block_given? then yield(o) else
        ret = StringIO.new
        o.on_all { |ev| ret.puts ev }
      end
      o.head ||= '' ; o.tail ||= '' ; o.separator ||= ' '
      cache = []
      cols = build_table_columns_inferences_aggregator
      row_enumerator.each do |col_enumerator|
        cache.push(row_cache = [])
        col_enumerator.each_with_index do |col, idx|
          if Array === col && 2 == col.count
            col = o.format_cel(*col)
          end
          cols[idx].see(col)
          row_cache.push col
        end
      end
      o.emit(:row_count) { { row_count: cache.size } }
      if cache.size.zero? then o.emit(:empty, '(empty)') else
        arr = cols.ordered.to_a # cache the results, it won't change
        cache.each do |row|
          o.emit :row, "#{o.head}#{arr.map { |c| c.render_cel(row[c.index]) }.join(o.separator)}#{o.tail}"
        end
      end
      ret.string if ret
    end
  end
end

