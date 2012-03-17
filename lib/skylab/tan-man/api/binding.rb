module Skylab::TanMan
  module Api
    module Actions
    end
  end

  require File.expand_path('../action', __FILE__)

  class Api::Binding
    extend Bleeding::DelegatesTo
    delegates_to :emitter, :emit
    attr_reader :emitter
    delegates_to :emitter, :error
    def initialize emitter
      @emitter = emitter
    end
    def invoke action, args
      /\A[-a-z]+\z/ =~ action or fail("invalid action name: #{action.inspect}")
      require File.expand_path("../actions/#{action}", __FILE__)
      mod = Api::Actions.const_get(action.to_s.gsub(/(?:^|-)([a-z])/){ $1.upcase })
      mod.call(self, args)
    end
  end
end

