require 'skylab/tmx/model/config'

module Skylab::Tmx::Modules::Bleed::Api
  class Action
    extend ::Skylab::PubSub::Emitter
    emits :all,  info: :all
    def config
      @config ||= ::Skylab::Tmx::Model::Config.build
    end
    def initialize ctx
      @config = nil
      @ctx = ctx
      yield self
    end
  end
end

