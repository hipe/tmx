module Skylab::TanMan

  class API::Actions::Remote::Add < API::Action
    extend API::Action::Attribute_Adapter

    attribute :host, required: true
    attribute :name, required: true
    attribute :resource, default: :local, mutex_boolean_set: [:local, :global]

  protected

    def execute
      result = nil
      begin
        controllers.config.ready? or break
        result = controllers.config.add_remote name, host, resource
      end while nil
      result
    end
  end
end
