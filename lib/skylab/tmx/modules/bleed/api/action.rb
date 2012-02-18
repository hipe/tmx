require 'skylab/tmx/model/config'

module Skylab::Tmx::Bleed::Api
  class Action
    EVENTS = %w(
      error
      info
      info_head
      info_tail
      out
    )
    def config
      @config ||= begin
        ::Skylab::Tmx::Model::Config.build do |o|
          EVENTS.each do |s|
            o.send("on_#{s}") { |e| emit(s.intern, e) }
          end
        end
      end
    end
    def emit a, b
      @on[a] or fail("unexpected event type: #{a.inspect}")
      @on[a].call b
    end
    def initialize ctx, &events
      @ctx = ctx
      @on = {}
      events.call(self)
    end
    EVENTS.each do |e|
      define_method("on_#{e}") do |&b|
        @on[e.intern] = b
      end
    end
  end
end

