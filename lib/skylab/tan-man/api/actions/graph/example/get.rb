module Skylab::TanMan

  class API::Actions::Graph::Example::Get < API::Action
    extend API::Action::Parameter_Adapter

    param :resource_name, accessor: true, default: :all,
      enum: [:local, :global, :all], required: true

  protected

    # (for now, experimentally this api call is very porcelain-y,
    # but additionally it tries to emit useful metadata)
    def execute
      f = -> m do
        a = m.searched_resources
        str = nil
        if m.value_was_set
          rsc = a[m.found_resource_index]
          str = "example is set to #{ m.value.inspect } in #{ rsc.noun }."
        else
          str = "there is no example set in #{ or_ a.map(&:noun) }"
        end
        info message: str, meta: m
      end
      # failure handled by callee
      controllers.examples.selected_status resource_name, f
    end
  end
end
