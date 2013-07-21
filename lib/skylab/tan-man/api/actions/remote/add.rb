module Skylab::TanMan

  class API::Actions::Remote::Add < API::Action

    extend API::Action::Attribute_Adapter

    attribute :host, required: true
    attribute :name, required: true
    attr_reader :name  # ICK override ..
    attribute :resource, default: :local, mutex_boolean_set: [:local, :global]

    attr_reader :verbose # compat

  private

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
