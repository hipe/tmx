module Skylab::TanMan
  module Api::Actions::Remote
  end
  class Api::Actions::Remote::Add < Api::Action
    attribute :host, required: true
    attribute :name, required: true
    def execute
      config? or return
      config.add_remote(name, host) or help(invite_only: true)
    end
  end
end

