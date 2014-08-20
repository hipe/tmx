module Skylab::Snag

  API::Actions::Doc = ::Module.new

  class API::Actions::Doc::Digraph < API::Action_

    Listener = Snag_::Model_::Listener.
      new :error_event, :info_line

    Entity_[ self,
      :make_listener_properties,
      :property, :is_dry_run,
      :required, :property, :working_dir
    ]

    # inflection.inflect.noun :singular

  private

    def if_nodes_execute
      Snag_::Models::Digraph.shell do |o|
        o.listener = @listener
        o.nodes = @nodes
      end
    end
  end
end
