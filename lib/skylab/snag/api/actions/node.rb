module Skylab::Snag
  module API::Actions::Node
  end

  module API::Actions::Node::Tags
    extend MetaHell::Autoloader::Autovivifying::Recursive
  end

  class API::Actions::Node::Tags::Add < API::Action
    emits :payload, :info, :error

    params :dry_run, :node_ref, :tag_name

    include API::Action::Node_InstanceMethods

    def execute
      res = nil
      begin
        node = find_node( node_ref ) or break( res = node )
        res = node.add_tag tag_name, -> e { error e }, -> e { info e }
      end while nil
      res
    end
  end
end
