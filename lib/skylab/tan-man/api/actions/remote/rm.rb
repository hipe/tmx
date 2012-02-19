module Skylab::TanMan
  module Api::Actions::Remote
  end
  class Api::Actions::Remote::Rm < Api::Action
    attribute :remote_name, required: true
    attribute :resource_name, mutex_boolean_set: [:local, :global]
    def execute
      config.ready? or return
      config.remove_remote(remote_name, resource_name) or false
    end
  end
end

