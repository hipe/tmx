module Skylab::Snag
  class CLI::ToDo::Tree
    Tree_Node = Porcelain::Tree::Node

    def render
      tree = @todos.reduce( Tree_Node.new slug: :root ) do |node, todo|
        path = todo.path.split( '/' ).push todo.line_number_string
        node.find!(path) do |child|
          if child.leaf?
            child[:todo] = todo
          end
        end
        node
      end
      1 == tree.children_length and tree = tree.children.first # comment out and see
      Porcelain::Tree.lines(tree, node_formatter: -> x { x } ).each do |line|
        if line.node.leaf?
          a = [ "#{ line.prefix } #{ line.node.slug }" ]
          if line.node[:todo]
            a.push line.node[:todo].full_source_line
          end
          out a.join( ' ' )
        else
          out "#{ line.prefix } #{ line.node.slug }"
        end
      end
    end

  protected

    def initialize action, client
      @action = action
      @client = client
      @todos = []
      @action.send( :event_listeners )[:payload].clear # #todo NO. BAD.
      @action.on_payload do |event|
        pay = event.payload
        if pay.respond_to? :valid?
          if pay.valid?
            @todos.push pay.collapse
          end
        else
          info "not teh payload we were expecing: #{pay.class}"
        end
      end
    end

    def info msg
      @client.send :emit, :info, msg
    end

    def out msg
      @client.send :emit, :payload, msg
    end
  end
end
