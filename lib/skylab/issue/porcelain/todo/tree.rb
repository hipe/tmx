module Skylab::Issue

  class Porcelain::Todo::Tree
    Node = Porcelain_::Tree::Node

    def initialize action, client
      @action = action
      @client = client
      @todos = []
      @action.event_listeners[:payload].clear
      @action.on_payload do |event|
        pay = event.payload
        if pay.respond_to? :valid?
          if pay.valid?
            @todos.push pay.dup
          end
        else
          info "not teh payload we were expecing: #{pay.class}"
        end
      end
    end
    def info msg
      @client.emit :info, msg
    end
    def out msg
      @client.emit :payload, msg
    end
    def render
      tree = @todos.reduce(Node.new({slug: :root})) do |node, todo|
        path = todo.path.split('/').push(todo.line)
        node.find!(path) do |child|
          if child.leaf?
            child[:todo] = todo
          end
        end
        node
      end
      1 == tree.children_length and tree = tree.children.first # comment out and see
      Porcelain_::Tree.lines(tree, node_formatter: ->(x){x} ).each do |line|
        if line.node.leaf?
          out "#{line.prefix} #{line.node.slug} #{line.node[:todo].content}"
        else
          out "#{line.prefix} #{line.node.slug}"
        end
      end
    end
  end
end

