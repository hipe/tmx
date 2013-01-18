module Skylab::Snag
  module API::Actions::Node
  end

  class API::Actions::Node::Close < API::Action
    emits :info, :error

    params :dry_run, :node_ref, :verbose

    def execute
      res = nil
      begin
        nodes or break
        node = @nodes.fetch_node( node_ref ) or break( res = node )
        res = node.close or break
        res = @nodes.changed node, dry_run, verbose
      end while nil
      res
    end
  end

  module API::Actions::Node::Tags
    extend MetaHell::Autoloader::Autovivifying::Recursive
  end

  class API::Actions::Node::Tags::Add < API::Action
    emits :payload, :info, :error

    params :do_append, :dry_run, :node_ref, :tag_name, :verbose

    def execute
      res = nil
      begin
        nodes or break
        node = @nodes.fetch_node( node_ref ) or break( res = node )
        res = node.add_tag( tag_name, do_append ) or break
        res = @nodes.changed node, dry_run, verbose
      end while nil
      res
    end
  end

  class API::Actions::Node::Tags::Ls < API::Action
    emits :payload, :error

    params :node_ref

    def execute
      res = nil
      begin
        nodes or break
        node = @nodes.fetch_node( node_ref ) or break( res = node )
        payload Snag::Models::Tag::Events::Tags.new( node, node.tags )
        res = true
      end while nil
      res
    end
  end

  class API::Actions::Node::Tags::Rm < API::Action
    emits :payload, :info, :error

    params :dry_run, :node_ref, :tag_name, :verbose

    def execute
      res = nil
      begin
        nodes or break
        node = @nodes.fetch_node( node_ref ) or break( res = node )
        res = node.remove_tag( tag_name ) or break
        res = @nodes.changed node, dry_run, verbose
      end while nil
      res
    end
  end
end
