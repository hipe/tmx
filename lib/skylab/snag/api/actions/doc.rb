module Skylab::Snag

  API::Actions::Doc = ::Module.new

  class API::Actions::Doc::Digraph < API::Action_

    Delegate = Snag_::Model_::Delegate.
      new :error_event, :info_line

    Entity_[ self,
      :make_delegate_properties,
      :property, :is_dry_run,
      :required, :property, :working_dir
    ]

    # inflection.inflect.noun :singular

  private

    def if_nodes_execute
      Snag_::Models::Digraph.shell do |o|
        o.delegate = @delegate
        o.nodes = @nodes
      end
    end
  end
end
