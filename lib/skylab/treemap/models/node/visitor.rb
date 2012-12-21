module Skylab::Treemap
  class Models::Node::Visitor
    extend Skylab::PubSub::Emitter
    emits :visit

    def initialize root
      @root = root
    end

    def invoke &b
      b.call self
      @stack = [[@root]]
      @path = []
      @flyweight = Flyweight.new(nil, nil)
      loop do
        break if @stack.empty?
        if @stack.last.empty?
          @stack.pop
          @path.pop
        else
          curr = @stack.last.pop
          visit(curr)
          if curr.children?
            @path.push curr.content
            @stack.push curr.children.to_a.reverse
          end
        end
      end
    end

    def visit node
      emit(:visit, @flyweight.set!(node, @path.dup))
    end
  end
  class Models::Node::Visitor::Flyweight < Struct.new(:node, :path)
    def set! node, path
      self.node = node
      self.path = path
      self
    end
  end
end

