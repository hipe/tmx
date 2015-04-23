module Skylab::Snag

  module API::Actions::Node
    # (as a fun exercise, can you spot the exploratory exercise in here?)
  end

  class API::Actions::Node::Close < API::Action

    params    :be_verbose,
                 :dry_run,
                :node_ref,
             :working_dir

    listeners_digraph :error_event,
      :error_string,
      :info_event

  private

    def if_node_execute
      res = @node.close
      res and @nodes.changed @node, @dry_run, @be_verbose
    end

    make_sender_methods
  end
end
