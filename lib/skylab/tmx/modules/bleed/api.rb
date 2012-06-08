require 'pathname'
require 'skylab/tmx/model/config'

module Skylab::Tmx::Modules::Bleed
  API_ROOT = Pathname.new('../api').expand_path(__FILE__)
  module Api
    require API_ROOT.join('action').to_s
    module Actions
    end
  end
  class << Api
    def build &b
      b and raise ArgumentError.new("do not pass a block here for now")
      Api::Dispatcher.new
    end
  end
  class Api::Dispatcher
    ACTIONS_ROOT = API_ROOT.join('actions')
    def initialize &events
      events and raise ArgumentError.new("do not pass block here for now")
    end
    def invoke act, ctx, &events
      events or raise ArgumentError.new("expected block here")
      require ACTIONS_ROOT.join(act.join('/')).to_s
      klass = act.reduce(Api::Actions) do |m, s|
        m.const_get(s.to_s.gsub(/(^[a-z]|[a-z](?=-))(?:-(.))?/) { "#{$1.upcase}#{$2}" })
      end
      klass.new(ctx, &events).invoke
    end
  end
end

