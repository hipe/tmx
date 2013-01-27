module Skylab::Treemap
  class Models::Node::Visitor

    def self.[] root, visit
      new( root ).visit visit
    end

    def visit visit
      @func = visit # careful
      @flyweight.clear
      @path.clear
      @stack.clear.push [ @root ]
      while @stack.length.nonzero?
        if @stack.last.empty?
          @stack.pop
          @path.pop
        else
          curr = @stack.last.pop
          visit_node curr
          if curr.has_children
            @path.push curr.content
            @stack.push curr.children.to_a.reverse
          end
        end
      end
    end

  protected

    def initialize root
      @func = nil # careful
      @flyweight = Flyweight.new
      @path = [ ]
      @stack = [ ]
      @root = root
    end

    def visit_node node
      @flyweight.set node, @path.dup
      @func[ @flyweight ]
      nil
    end
  end

  class Models::Node::Visitor::Flyweight

    def clear
      @node = @path = nil
    end

    attr_reader :node

    attr_reader :path

    def set node, path
      @node, @path = node, path
      nil
    end

  protected

    alias_method :initialize, :clear
  end
end
