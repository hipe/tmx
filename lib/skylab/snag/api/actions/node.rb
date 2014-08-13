module Skylab::Snag

  module API::Actions::Node
    # (as a fun exercise, can you spot the exploratory exercise in here?)
  end

  class API::Actions::Node::Close < API::Action

    params    :be_verbose,
                 :dry_run,
                :node_ref

    listeners_digraph  info: :lingual

    def execute
      nodes and when_nodes
    end
  private
    def when_nodes
      @node = @nodes.fetch_node @node_ref
      @node and when_node
    end
    def when_node
      res = @node.close
      res and @nodes.changed @node, @dry_run, @be_verbose
    end
  end

  module API::Actions::Node::Tags
  end

  class API::Actions::Node::Tags::Add < API::Action

    params    :be_verbose,
               :do_append,
                 :dry_run,
                :node_ref,
                :tag_name

    listeners_digraph  info: :lingual

    def execute
      res = nil
      begin
        nodes or break
        node = @nodes.fetch_node( @node_ref ) or break( res = node )
        res = node.add_tag( @tag_name, @do_append ) or break
        res = @nodes.changed node, @dry_run, @be_verbose
      end while nil
      res
    end
  end

  class API::Actions::Node::Tags::Ls < API::Action

    params       :node_ref

    listeners_digraph  tags: :datapoint

    def execute
      if nodes
        node = @nodes.fetch_node @node_ref
        if ! node then node else
          call_digraph_listeners :tags, Tags_Event__.new( node, node.tags )
          true
        end
      end
    end
  end
  Tags_Event__ = Event_[].new :node, :tags do
    message_proc do |y, o|
      y << "#{ val o.node.identifier } is tagged with #{
       }#{ and_ o.tags.map{ |t| val t } }."
    end
  end

  class API::Actions::Node::Tags::Rm < API::Action

    params    :be_verbose,
                 :dry_run,
                :node_ref,
                :tag_name

    listeners_digraph  info: :lingual,
                 payload: :datapoint

    def execute
      nodes and begin
        node = @nodes.fetch_node @node_ref
        node and begin
          ok = node.remove_tag @tag_name
          ok and begin
            @nodes.changed node, @dry_run, @be_verbose
          end
        end
      end
    end
  end
end
