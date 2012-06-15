require 'skylab/porcelain/tree'
require 'skylab/porcelain/tree/node'

module Skylab::Issue

  class Porcelain::Todo::Tree
    Node = Skylab::Porcelain::Tree::Node

    def initialize action, client
      @action = action
      @client = client
      @todos = []
      @action.event_listeners[:payload].clear
      @action.on_payload do |event|
        @todos.push(event.payload.dup) if event.payload.valid?
      end
    end
    def render
      tree = @todos.reduce(Node.new) do |node, todo|
        path = todo.path.split('/').push(todo.line)
        node.find!(path) do |child, info|
          child[:slug] = info[:slug]
          if info[:leaf]
            child[:leaf] = true
            child[:todo] = todo # this could actually be overwriting something
          end
        end
        node
      end
      1 == tree.children_length and tree = tree.children.first # comment out and see
      Skylab::Porcelain::Tree.lines(tree, node_formatter: ->(x){x} ).each do |line|
        if line.node[:leaf]
          @client.emit(:payload, "#{line.prefix} #{line.node.slug} #{line.node[:todo].content}")
        else
          @client.emit(:payload, "#{line.prefix} #{line.node.slug}")
        end
      end
    end
  end
end

