require 'pathname'
require 'skylab/tmx/model/config'

module Skylab::TMX::Modules::Bleed
  API_ROOT = Pathname.new('../api').expand_path(__FILE__)
  module API
    # extend ::Skylab::Autoloader # @todo
    require API_ROOT.join('action').to_s
    require API_ROOT.join('bash-action').to_s
    module Actions
    end
  end
  class << API
    def build &b
      b and raise ArgumentError.new("do not pass a block here for now")
      API::Dispatcher.new
    end
  end
  class API::Dispatcher
    ACTIONS_ROOT = API_ROOT.join('actions')
    def initialize &events
      events and raise ArgumentError.new("do not pass block here for now")
    end
    def invoke act, ctx, &events
      events or raise ArgumentError.new("expected block here")
      Array === act or act = [act]
      require ACTIONS_ROOT.join(act.join('/')).to_s
      klass = act.reduce(API::Actions) do |m, s|
        m.const_get(s.to_s.gsub(/(^[a-z]|[a-z](?=-))(?:-(.))?/) { "#{$1.upcase}#{$2}" })
      end
      klass.new(ctx, &events).invoke
    end
  end
end

