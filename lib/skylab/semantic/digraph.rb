require_relative '..'

module Skylab::Semantic
  class Digraph

    def self.[] *a
      g = new
      g.nodes! a
      g
    end

  public

    def [] name
      @hash[name]
    end

    def all_ancestors name
      ::Enumerator.new do |y|
        seen = { }
        visit_f = ->(_name) do
          node = self[_name] or fail("sanity: no such name: #{_name.inspect}")
          y << node
          seen[_name] = true
          node.is_names.each { |__name| seen.key?(__name) or visit_f[__name] }
        end
        visit_f[name]
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

    def fetch name, &otherwise
      @hash.fetch name, &otherwise
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
          seen[node.name]
        end
        nil
      end
    end

    def has? name
      @hash.key? name
    end

    def names
      @order.dup
    end

    def node! name, predicates=nil # node! :ambiguous, is: :error
      if @hash.key? name
        node = @hash[name]
      else
        node = Node.new self, name
        @hash[name] = node
        @order.push name
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
        @order.each { |name| y << @hash[name] }
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
      all_ancestors.map(& :name )
    end

    def describe
      a = [ @name.to_s ]
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
      name = ::Symbol === node ? node : node.name
      !! all_ancestors.detect do |nd|
        name == nd.name
      end
    end

    attr_reader :is_names

    attr_reader :name

    attr_accessor :visited        # for client

  protected

    def initialize graph, name
      ::Symbol === name or fail 'dupe logic will fail with non-immediate values'
      @name, @graph = name, graph
      @is_names = [ ]
      nil
    end

    def base_args
      [ @name, @is_names ]
    end

    def base_init graph, name, is_names
      @name = name
      @is_names = is_names.dup
      @graph = graph
      nil
    end

    def all_ancestors
      @graph.all_ancestors @name
    end

    def is! name
      case name
      when ::Array
        name.each(& method( :is! ) )
      when ::Symbol
        if ! @is_names.include? name
          # ensure that the graph has such a node
          @graph.node! name
          @is_names.push name
        end
      else
        raise ::ArgumentError.new "bad type: #{ name.class }"
      end
      nil
    end
  end
end
