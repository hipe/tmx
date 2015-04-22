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

  module API::Actions::Node::Tags
  end

  class API::Actions::Node::Tags::Add < API::Action

    params    :be_verbose,
               :do_append,
                 :dry_run,
                :node_ref,
                :tag_name,
             :working_dir

    listeners_digraph :error_event,
      :info_event

  private

    def if_node_execute
      ok = @node.add_tag @tag_name, * [ * ( :prepend if ! @do_append ) ]
      ok and @nodes.changed @node, @dry_run, @be_verbose
    end
  end
end
