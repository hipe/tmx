# support classes used in filemetrics, not dependant on it! maybe they will have broader use

# defined here: Hipe::Stats, Hipe::DataNode, Hipe::ShapeAssert
# they may be put into their own files but will always be accessible heres

require 'ostruct'

module Hipe
  module DataNode
    #
    # data nodes are slightly enhanced structs of some sort.
    # they should not have a lot of heavy method implementations,
    # they just hold data
    #
    class Branch < Struct.new(:children, :name);
      undef :count
      def initialize *args, &block
        super(*args)
        yield self if block_given?
        self.children = [] unless self.children
      end
      def sort_by!(&block)
        children.sort! do |x,y|
          left = block.call(x) || 0
          rite = block.call(y) || 0
          (left == rite) ? 0 : (left > rite ? -1 : 1 )
        end
      end
    end
    class Leaf < Struct.new(:name, :count);
      def initialize *args, &block
        super(*args)
        yield self
      end
    end
  end

  module ShapeAssert
    #
    # attempt at a really lightweight structural/interface assertion thing
    # inspired by bacon
    #
    class ShapeAssertFail     < RuntimeError;     end
    class MakeDefinitionFail  < ShapeAssertFail;  end
    class MatchDefinitionFail < ShapeAssertFail
      attr_reader :metadata
      def initialize msg, metadata=nil
        super msg
        @metadata = metadata
      end
    end

    #
    # raises MatchDefinitionFail if the thing doesn't match the description
    # raises MakeDefinitionFail if there is something wrong with the definition
    # @return nil
    #
    def self.against thing, &block
      fail = fails(thing, &block) and raise fail
    end

    def self.fails thing, &block
      defin = Definition.new
      proxy = RecordingProxy.new thing
      fail = catch(:fail) do
        defin.instance_exec(proxy, &block)
        nil
      end
      if fail
        rec = proxy.recordings.last
        meth = rec[0]
        args = rec.slice(1,rec.size).map{|x| x.inspect} * ', '
        msg = %|to be a #{defin.desc} it must #{meth}(#{args})|
        return MatchDefinitionFail.new msg, thing
      end
      return nil
    end

    class Definition
      attr_reader :desc
      def to_be_a desc
        raise MakeDefinitionFail.new(
         %|let's stick to strings not #{desc.inspect} for descriptions|
        ) unless desc.kind_of? String
        raise MakeDefinitionFail.new(
         %|won't clobber existing description'|
        ) if @desc
        @desc = desc
      end
      def required_that mixed
        throw(:fail,'fail') unless mixed
      end
    end

    class RecordingProxy
      #
      # pass (almost) every message along to target, but record each one.
      # we might eventually make recording proxies for calls like .class()
      #
      keep_these = [:__send__, :__id__, :debugger, :object_id]
      (instance_methods.map(&:to_sym) - keep_these).each do |name|
        undef_method name
      end
      attr_accessor :recordings, :target
      def initialize mixed
        @target = mixed
        @recordings = []
      end
      def method_missing name, *args
        @recordings.push [name, *args]
        @target.send(name, *args)
      end
    end
  end

  module Stats
    #
    # Enhance a DataNode::Branch-like with statistics about its nodes
    #
    # Objects that extend Stats should respond to "count" or "children", those
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

    # common pattern
    def self.[] obj; obj.extend self; obj  end
    def self.extended obj;  obj.init_stats end

    def init_stats
      class << self
        attr_reader :stats
      end
      @stats ||= Calculator.new self
    end

    class StatsError < RuntimeError; end

    class Calculator
      #
      # A stats calculator object holds a handle to a data node and
      # calculates and caches statistical operations on the node.
      #

      attr_accessor :parent
      def initialize node
        err = Hipe::ShapeAssert.fails(node) do |it|
          to_be_a "calculatable node"
          required_that it.respond_to?(:name)
          required_that it.respond_to?(:count) || it.respond_to?(:children)
        end
        if err
          raise StatsError.new(err.message) if err
        end
        @node = node
        @cache = {}
        if @node.respond_to? :children
          @node.children.each do |child|
            Hipe::Stats[child]
            child.stats.parent = self
          end
        end
      end
      def count
        @cache.key?(:count) ? @cache[:count] : begin
          @cache[:count] =
          if @node.respond_to? :count
            @node.count
          elsif @node.respond_to? :children
            @node.children.map{|child| child.stats.count}.reduce(:+)
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
      def percent_of_max
        ratio_of_max * 100
      end
    end # Calculator

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
