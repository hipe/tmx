require_relative '..'

module Skylab::Semantic
  class Digraph

    def self.[] *a
      g = new
      g.nodes! a
      g
    end

  public

    def [] normalized_local_name
      @hash[normalized_local_name]
    end

    def all_ancestors normalized_local_name
      ::Enumerator.new do |y|
        seen = { }
        visit_f = ->(_name) do
          node = self[_name] or fail("sanity: no such name: #{_name.inspect}")
          y << node
          seen[_name] = true
          node.is_names.each { |__name| seen.key?(__name) or visit_f[__name] }
        end
        visit_f[normalized_local_name]
      end
    end

    def clear
      @hash.clear
      @order.clear
      nil
    end

    def describe
      nodes.map(&:describe).join "\n"
    end

    def dupe
      ba = base_args
      self.class.allocate.instance_exec do
        base_init(* ba )
        self
      end
    end

    def fetch normalized_local_name, &otherwise
      @hash.fetch normalized_local_name, &otherwise
    end

    def flatten nodes
      # result is an emitter that yields, for each node in "node", each of its
      # "is-a" parents and then then node itself.  Each node is
      # presented only once, so nodes that have been presented already
      # are skipped on subsequent visits.  #todo: find out why this is
      # useful to have this not be recursive.  It may not be.
      ::Enumerator.new do |y|
        seen = ::Hash.new { |h, k| y << self[k] ; h[k] = true }
        nodes.each do |node|
          node.is_names.each { |k| seen[k] }
          seen[ node.normalized_local_name ]
        end
        nil
      end
    end

    def has? normalized_local_name
      @hash.key? normalized_local_name
    end

    def names
      @order.dup
    end

    def node! normalized_local_name, predicates=nil # node! :ambiguous, is: :error
      if @hash.key? normalized_local_name
        node = @hash[normalized_local_name]
      else
        node = Node.new self, normalized_local_name
        @hash[normalized_local_name] = node
        @order.push normalized_local_name
      end
      if predicates
        node.absorb_predicates predicates
      end
      node
    end

    def nodes! a
      i = 0 ; len = a.length ; y = [ ]
      while i < len && ::Symbol === a[i]
        y << node!(a[i])
        i += 1
      end
      while i < len && ::Hash === a[i]
        a[i].each do |k, v|
          y << node!(k, is: v)
        end
        i += 1
      end
      if i < len then raise ::ArgumentError.new("bad type: #{a[i].class}") end
      y
    end

    def nodes
      ::Enumerator.new do |y|
        @order.each { |normalized_local_name| y << @hash[normalized_local_name] }
        nil
      end
    end

    def nodes_count
      @hash.length
    end

  protected

    def initialize
      @order = [ ]
      @hash = { }
    end

    def base_args
      [ @order, @hash ]
    end

    def base_init order, hash
      @order = order.dup
      @hash = { }
      hash.each do |k, v|
        @hash[ k ] = v.dupe self
      end
      nil
    end
  end

  class Node

    pred_h_h = {                  # (validates the predicate name, and
      is: -> v { is! v }          # translates from one nice-looking dsl
    }                             # to another name convention.)

    define_method :absorb_predicates do |pred_h|
      pred_h.each { |k, v| instance_exec v, & pred_h_h.fetch( k ) }
      nil
    end

    def all_ancestor_names
      all_ancestors.map(& :normalized_local_name )
    end

    def describe
      a = [ @normalized_local_name.to_s ]
      a << @is_names.join( ', ' ) if @is_names.length.nonzero?
      a * ' -> '
    end

    def dupe graph
      ba = base_args
      self.class.allocate.instance_exec do
        base_init graph, *ba
        self
      end
    end

    def is? node
      normalized_local_name = ::Symbol === node ? node : node.normalized_local_name
      !! all_ancestors.detect do |nd|
        normalized_local_name == nd.normalized_local_name
      end
    end

    attr_reader :is_names

    attr_reader :normalized_local_name

    attr_accessor :visited        # for client

  protected

    def initialize graph, normalized_local_name
      ::Symbol === normalized_local_name or fail 'dupe logic will fail with non-immediate values'
      @normalized_local_name, @graph = normalized_local_name, graph
      @is_names = [ ]
      nil
    end

    def base_args
      [ @normalized_local_name, @is_names ]
    end

    def base_init graph, normalized_local_name, is_names
      @normalized_local_name = normalized_local_name
      @is_names = is_names.dup
      @graph = graph
      nil
    end

    def all_ancestors
      @graph.all_ancestors @normalized_local_name
    end

    def is! normalized_local_name
      case normalized_local_name
      when ::Array
        normalized_local_name.each(& method( :is! ) )
      when ::Symbol
        if ! @is_names.include? normalized_local_name
          # ensure that the graph has such a node
          @graph.node! normalized_local_name
          @is_names.push normalized_local_name
        end
      else
        raise ::ArgumentError.new "bad type: #{ normalized_local_name.class }"
      end
      nil
    end
  end
end
