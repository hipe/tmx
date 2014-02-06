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
      res = nil
      begin
        nodes or break
        res = node = @nodes.fetch_node( @node_ref ) or break
        res = node.close or break
        res = @nodes.changed node, @dry_run, @be_verbose
      end while nil
      res
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
          call_digraph_listeners :tags, Snag::Models::Tag::Events::Tags.new( node, node.tags )
          true
        end
      end
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
