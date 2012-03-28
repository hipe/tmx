require 'pathname'

module Skylab
  module Tmx
    module Bleed
      API_ROOT = Pathname.new('../api').expand_path(__FILE__)
      module Api
        require API_ROOT.join('action')
        module Actions
        end
      end
    end
  end
end

module Skylab::Tmx::Bleed
  class << Api
    def build &b
      Api::Dispatcher.new(&b)
    end
  end
  class Api::Dispatcher
    ACTIONS_ROOT = API_ROOT.join('actions')
    def initialize &events
      @events = events or fail("must pass event handlers when building api.")
    end
    def invoke act, ctx
      require ACTIONS_ROOT.join(act.join('/'))
      klass = act.reduce(Api::Actions) do |m, s|
        m.const_get(s.to_s.gsub(/(^[a-z]|[a-z](?=-))(?:-(.))?/) { "#{$1.upcase}#{$2}" })
      end
      klass.new(ctx, &@events).invoke
    end
  end
end

