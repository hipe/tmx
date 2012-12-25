require_relative '..'

module Skylab::Semantic
  class Digraph

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

    def flatten nodes
      # return an emitter that yields, for each node in "node", each of its
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

    def node! name, predicates=nil # node! :ambiguous, is: :error
      if @hash.key? name
        node = @hash[name]
      else
        node = Node.new self, name
        @hash[name] = node
        @order.push name
      end
      predicates and predicates.each { |m, v| node.send m, v }
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

    def initialize *a
      if 1 == a.length && self.class === a.first
        dupe! a.first
      else
        @hash = { }
        @order = [ ]
        nodes! a if a.length.nonzero?
      end
    end

    # --*--

    def dupe! digraph
      @hash = { }
      @order = digraph.instance_variable_get('@order').dup
      _hash = digraph.instance_variable_get('@hash')
      @order.each do |k|
        @hash[k] = Node.new(self, _hash[k])
      end
    end
  end


  class Node < ::Struct.new :name, :is_names

    def all_ancestor_names
      all_ancestors.map(&:name)
    end

    def describe
      [ name.to_s,
        (is_names.join(', ') unless is_names.empty?)
      ].compact.join(' -> ')
    end

    def is? node
      target_name = ::Symbol === node ? node : node.name
      !!( all_ancestors.detect { |_node| target_name == _node.name } )
    end

    attr_accessor :visited        # for client

  protected

    def initialize graph, name
      @graph = graph
      if self.class === name then dupe!(name) else super(name, []) end
    end

    # --*--

    def all_ancestors
      @graph.all_ancestors(name)
    end

    def dupe! node
      self.name = node.name
      self.is_names = node.is_names.dup
      nil
    end

    def is name
      case name
      when ::Array
        name.each { |x| is(x) }
      when ::Symbol
        unless is_names.include? name
          # ensure that the graph has such a node
          @graph.node! name
          is_names.push name
        end
      else
        raise ::ArgumentError.new "bad type: #{name.class}"
      end
      nil
    end
  end
end
