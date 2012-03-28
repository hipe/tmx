module Skylab::TanMan
  module Api::Actions::Remote
  end
  class Api::Actions::Remote::Add < Api::Action
    attribute :host, required: true
    attribute :name, required: true
    attribute :resource, default: :local, mutex_boolean_set: [:local, :global]
    def execute
      config.ready? or return
      config.add_remote(name, host, resource)
    end
  end
end

