module Skylab::Snag
  class CLI::ToDo::Tree
    # [#sl-109] class as namespace
  end

  class CLI::ToDo::Tree::Node < Porcelain::Tree::Node
    attr_accessor :todo
  end

  class CLI::ToDo::Tree
    include Snag::Core::SubClient::InstanceMethods

    def render
      _root = CLI::ToDo::Tree::Node.new slug: :root
      tree = @todos.reduce _root do |node, todo|
        path_a = todo.path.split( '/' ).push todo.line_number_string
        node.find! path_a do |nd|
          if nd.is_leaf
            nd.todo = todo
          end
        end
        node
      end

      if 1 == tree.children_length
        tree = tree.children.first # comment out and see
      end

      Porcelain::Tree.lines( tree, node_formatter: -> x { x } ).each do |line|
        if line.node.is_leaf
          a = [ "#{ line.prefix } #{ line.node.slug }" ]
          if line.node.todo
            a.push line.node.todo.full_source_line
          end
          payload a.join( ' ' )
        else
          payload "#{ line.prefix } #{ line.node.slug }"
        end
      end
    end

  protected

    def initialize client, action
      _snag_sub_client_init! client
      @action = action
      @todos = []
      @action.send( :event_listeners )[:payload].clear # #todo NO. BAD.
      @action.on_payload do |event|
        pay = event.payload
        if pay.respond_to? :valid?
          if pay.valid?
            @todos.push pay.collapse
          end
        else
          info "not teh payload we were expecing: #{ pay.class }"
        end
      end
    end
  end
end
