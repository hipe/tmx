module Skylab::Snag
  module API::Actions::Node
  end

  module API::Actions::Node::Tags
    extend MetaHell::Autoloader::Autovivifying::Recursive
  end

  class API::Actions::Node::Tags::Add < API::Action
    emits :payload, :info, :error

    params :dry_run, :node_ref, :tag_name, :verbose

    def execute
      res = nil
      begin
        nodes or break
        node = @nodes.fetch_node( node_ref ) or break( res = node )
        res = node.append_tag( tag_name ) or break
        res = @nodes.changed node, dry_run, verbose
      end while nil
      res
    end
  end
end
