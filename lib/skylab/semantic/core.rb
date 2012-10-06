require_relative '..'

module Skylab::Semantic
  class Digraph

  public
    def [](name)
      @hash[name]
    end
    def node! name, predicates=nil
      if @hash.key?(name)
        node = @hash[name]
      else
        node = Node.new(self, name)
        @hash[name] = node
        @order.push name
      end
      predicates and predicates.each { |m, v| node.send(m, v) }
      node
    end
    def nodes_count
      @hash.length 
    end
  protected
    def initialize *a
      @order = [ ] ; @hash = { }
      i = 0 ; len = a.length
      while i < len && ::Symbol === a[i]
        node! a[i]
        i += 1
      end
      while i < len && ::Hash === a[i]
        a[i].each do |k, v|
          node! k, :"is_name!" => v
        end
        i += 1
      end
      if i < len then raise ::ArgumentError.new("bad type: #{a[i].class}") end
    end
  end
  class Node < ::Struct.new(:name, :is_names)
  protected
    def initialize graph, name
      @graph = graph
      super(name, [])
    end
    # --*--
    def is_name! name
      unless is_names.include? name
        # ensure that the graph has such a node
        @graph.node! name
        is_names.push name
      end
      nil
    end
  end
end
