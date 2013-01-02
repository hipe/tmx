module Skylab::TanMan

  class API::Actions::Graph::Starter::Get < API::Action
    extend API::Action::Parameter_Adapter

    param :resource_name, accessor: true, default: :all,
      enum: [:local, :global, :all], required: true

  protected

    # (for now, experimentally this api call is very porcelain-y,
    # but additionally it tries to emit useful metadata)
    def execute
      # failure handled by callee
      collections.starter.using_starter_metadata resource_name, -> m do
        a = m.searched_resources
        str = nil
        if m.value_was_set
          rsc = a[m.found_resource_index]
          str = "starter is set to #{ m.value.inspect } in #{ rsc.noun }."
        else
          str = "there is no starter set in #{ or_ a.map(&:noun) }"
        end
        info message: str, meta: m
      end
    end

    attr_reader :verbose #compat
  end
end
