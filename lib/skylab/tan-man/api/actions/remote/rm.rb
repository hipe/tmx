module Skylab::TanMan

  class API::Actions::Remote::Rm < API::Action
    extend API::Action::Attribute_Adapter

    attribute :remote_name, required: true
    attribute :resource_name, mutex_boolean_set: [:local, :global]

  protected

    def execute
      result = nil
      begin
        controllers.config.ready? or break
        result = controllers.config.remove_remote remote_name, resource_name
        result ||= false
      end while nil
      result
    end

    attr_reader :verbose
  end
end
