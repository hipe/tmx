module Skylab::TanMan
  module API::Actions::Remote
  end
  class API::Actions::Remote::Rm < API::Action
    attribute :remote_name, required: true
    attribute :resource_name, mutex_boolean_set: [:local, :global]
    def execute
      config.ready? or return
      config.remove_remote(remote_name, resource_name) or false
    end
  end
end

