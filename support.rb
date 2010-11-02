# support classes used in filemetrics, not dependant on it! maybe they will have broader use

# defined here: Hipe::Stats, Hipe::DataNode, Hipe::ShapeGrammar
# they may be put into their own files but will always be accessible heres

module Hipe
  module DataNode
    #
    # data nodes are slightly enhanced structs of some sort.
    # they should not have a lot of heavy method implementations,
    # they just hold data
    #
    class Branch < Hipe::Tinyscript::Support::EpeenStruct.new(:children, :name)
      undef :count
      def initialize *args, &block
        super(*args)
        yield self if block_given?
        self.children = [] unless children
      end
      def sort_by!(&block)
        children.sort! do |x,y|
          left = block.call(x) || 0
          rite = block.call(y) || 0
          (left == rite) ? 0 : (left > rite ? -1 : 1 )
        end
      end
    end
    class Leaf <  Hipe::Tinyscript::Support::EpeenStruct.new(:name, :count)
      def initialize *args, &block
        super(*args)
        yield self
      end
    end
  end

  module FileMetrics

    module PathTools
      def escape_path path
        (path =~ / |\$|'/) ? Shellwords.shellescape(path) : path
      end
    end

    class FindCommand
      include PathTools
      def initialize
        @extra = ''
        yield self
        fail('need at least one search path') unless @paths && @paths.any?
      end
      attr_accessor :extra
      ivars = [:paths, :skip_dirs, :names]
      attr_writer(*ivars)
      ivars.each do |ivar|
        define_method(ivar) do |*a|
          case a.size ;
          when 0 ; instance_variable_get("@#{ivar}")
          when 1 ; instance_variable_set("@#{ivar}", a.first.kind_of?(Array) ? a.first : [a.first])
          else     instance_variable_set("@#{ivar}", a)
          end
        end
      end
      def render
        cmd = "find " << @paths.map{ |p| escape_path(p) }.join(' ')
        if @skip_dirs && @skip_dirs.any?
          paths = @skip_dirs.map{ |p| escape_path(p) }
          cmd << ' -not \( -type d \( -mindepth 1 -a '
          cmd << paths.map{ |p| " -name '#{p}'" }.join(' -o')
          cmd << " \\) -prune \\)#{@extra}"
        end
        if @names && @names.any?
          paths = @names.map{ |p| escape_path(p) }
          cmd << ' \(' << paths.map{ |p| " -name '#{p}'" }.join(' -o') << ' \)'
        end
        cmd
      end
    end
  end

  class ShapeGrammar
    # experimental DSL-like thing for asserting things about an object and reporting
    # on their failure, inspired a bit by bacon

    class Fail < RuntimeError
      def initialize grammar, recording
        super(recording.sentence.map do |pred|
          "#{grammar.desc} #{pred[0]}(#{pred[1].map(&:inspect).join(', ')}) was not true."
        end.join('  '))
      end
    end
    class << self
      def create
        g = new and yield g
        g
      end
    end
    attr_reader :desc
    def as desc
      @desc = desc
    end
    def assert target
      unless match target
        raise get_error(target)
      end
    end
    def define *extra, &block
      @extra = extra
      @block = block
      self
    end
    def get_error target
      rec = RecordingGrammar.new(self, target, @extra, @block)
      if catch(:assertion_fail_during_recording) do
        rec.run_block
        false
      end then
        Fail.new(self, rec)
      else
        nil
      end
    end
    def match target
      catch(:assertion_fail) do
        target.instance_exec(self, &@block)
        true
      end
    end
    def must b
      throw(:assertion_fail, false) unless b
    end
    class RecordingGrammar
      def initialize grammar, target, extra, block
        @block = block
        @extra = extra
        @grammar = grammar
        @sentence = []
        @target = target
      end
      attr_reader :sentence
      def must bool
        bool ? @sentence.clear : throw(:assertion_fail_during_recording, true)
        nil
      end
      def run_block
        @proxy = RecordingProxy.new(@target, @sentence)
        @proxy.instance_exec(self, *@extra, &@block)
        nil
      end
    end
    class RecordingProxy
      KeepThese = %w(__send__ __id__ debugger inspect instance_exec object_id pretty_print puts) # @todo get rid of puts!
      (public_instance_methods.map(&:to_sym) - KeepThese.map(&:to_sym)).each do |meth|
        undef_method meth.to_sym
      end
      def initialize target, sentence
        @sentence = sentence
        @target = target
      end
      def method_missing meth, *a, &b
        @sentence.push [meth, a, b]
        @target.send(meth, *a, &b)
      end
      def __target__
        @target
      end
    end
  end

  class SoftError < RuntimeError
    include Hipe::Tinyscript::Support::Stringy
    def initialize(*a, &b)
      super(*a)
      yield self if block_given?
    end
    attr_reader :show_origin
    alias_method :show_origin?, :show_origin
    def show_origin!; @show_origin = true end
    def ui_message
      [message, show_origin? ? "from #{from_where}" : nil].compact.join(' ')
    end
    def from_where
      parts = parse_backtrace_line(backtrace[0]) and "#{File.basename(parts[:path])}:#{parts[:line]}"
    end
  end

  module Stats
    #
    # Enhance a DataNode::Branch-like with statistics about its nodes
    #
    # Objects that extend Stats::Calculator should respond to "count" or "children".
    # those that respond to "children" should yield objects that respond to "count"
    # or "children"... and so on.
    #
    # (originally jumped through a lot of hoops so that we could
    # determine the percentile rating of the number of lines of each file
    # among the set of files,
    # (including re-writing a pure-ruby binary search tree,)
    # then realized after finishing it that a percentile rating of
    # each item among a group of items will always have a linear distribution,
    # making the results uninteresting.)
    #
    #

    class StatsError < RuntimeError; end

    module Calculator
      class << self
        def extended obj; obj.init_stats; end
      end
      def init_stats
        @stats ||= NodeCalculator.new self
      end
      attr_reader :stats
    end

    class NodeCalculator
      #
      # A stats calculator object that holds a handle to a data node and
      # calculates and caches statistical operations on the node.
      #

      class << self
        def calculatable_node_grammar
          @cng ||= Hipe::ShapeGrammar.create do |it|
            it.as "calculatable node"
          end.define do |it|
            it.must respond_to?(:name)
            it.must( respond_to?(:count) || respond_to?(:children) )
          end
        end
      end

      def initialize node
        @sing = class << self; self end
        self.class.calculatable_node_grammar.assert(node)
        @node = node
        @cache = {}
        if @node.respond_to?(:children) && ! @node.children.nil?
          @node.children.each do |child|
            child.extend Calculator
            child.stats.set_parent self
          end
        end
      end
      def count
        @cache.key?(:count) ? @cache[:count] : begin
          @cache[:count] =
          if @node.respond_to? :count
            @node.count
          elsif @node.respond_to? :children
            @node.children.map{ |child| child.stats.count }.reduce(:+)
          else
            raise StatsError.new(%|can't determine count for "#{@node.name}"|)
          end
        end
      end
      def max_node
        @cache.key?(:max_node) ? @cache[:max_node] : begin
          @cache[:max_node] =
          if @node.respond_to? :children
            if @node.children.size == 0
              nil
            else
              @node.children.inject do |longest, current|
                longest.stats.max > current.stats.max ? longest : current
              end
            end
          elsif @node.respond_to? :count
            @node
          else
            raise StatsError.new(
              %|can't determine max node for "#{@node.name}"|)
          end
        end
      end
      def max
        max_node ? max_node.stats.count : 0
      end
      def ratio_of_max
        raise StatsError.new(%|can't calculate ratio of max |<<
          %|on nodes without parents|) unless parent
        result = count.to_f / parent.max.to_f
        result
      end
      def parent; nil end # memoized
      def percent_of_max
        ratio_of_max * 100
      end
      def set_parent calc
        @sing.send(:define_method, :parent){ calc } # memoize!
      end
    private
    end

    #
    # map line numbers to their percentile rating(s), array must be sorted
    # the resulting array will have the percentile as an index, contiguous
    # integers from zero to the largest percentile you requested in
    # which_percentiles.  The value of the array elements will be nil for the
    # percentiles not present which_percentiles
    #
    # def calculate_percentiles(which_percentiles = (0..99).to_a )
    #   # which_percentiles =  (0..99).to_a #[0,25,50,75,99]#
    #   raise "please don't ask for 100 or above percentile rating" if
    #     which_percentiles.last >= 100
    #   result = {}
    #   which_percentiles.each do |percentile|
    #     result[percentile] = data[
    #       ((percentile.to_f / 100) * data.length).floor
    #     ][attribute]
    #   end
    #   btree = Hipe::SimpleBTree.new()
    #   btree.write_mode_on
    #   result.each do |percent,count|
    #     btree[count] ||= []
    #     btree[count] << percent
    #   end
    #   btree.write_mode_off
    #   # we might have multiple percentiles for single linecount values,
    #   # in which case we want to make a percentile range.  In other words we
    #   # are losslessly inverting the hash
    #   btree.each.each do |pair|
    #     btree[pair[0]] = (pair[1].min .. pair[1].max)
    #   end
    #   @btree = btree
    # end
    #
    # def percentile_range count
    #   if @btree[count]
    #     @btree[count]
    #   else
    #     above = @btree.lower_bound count
    #     below = @btree.upper_bound count
    #     my_lo = below ? below[1].end : 0
    #     my_hi = above ? above[1].begin : 99
    #     my_lo .. my_hi
    #   end
    # end
  end # Stats
end
