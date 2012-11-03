module Skylab::TanMan
  class API::Actions::Remote::Add < API::Action
    attribute :host, required: true
    attribute :name, required: true
    attribute :resource, default: :local, mutex_boolean_set: [:local, :global]
    def execute
      config.ready? or return
      config.add_remote(name, host, resource)
    end
  end
end

