module Skylab::Tmx::Bleed::Api
  class Action
    def emit a, b
      @on[a] or fail("unexpected event type: #{a.inspect}")
      @on[a].call b
    end
    def initialize ctx, &events
      @ctx = ctx
      @on = {}
      events.call(self)
    end
    %w(error info out).each do |e|
      define_method("on_#{e}") do |&b|
        @on[e.intern] = b
      end
    end
  end
end

