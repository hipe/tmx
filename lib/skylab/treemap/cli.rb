require_relative 'actions'

module Skylab::Treemap
  class CLI < Skylab::Porcelain::Bleeding::Runtime
    extend Skylab::PubSub::Emitter

    emits Skylab::Porcelain::Bleeding::EVENT_GRAPH
    emits payload: :all, info: :all

    desc "experiments with R."

    def porcelain # @todo after:#100.200: not here
      self.class
    end
  end
  class << CLI
    def build_client_instance runtime, slug
      new.tap do |c|
        c.program_name = slug
        c.on_error   { |e| runtime.emit(:error, e) }
        c.on_help    { |e| runtime.emit(:help,  e) }
        c.on_info    { |e| runtime.emit(:info, e) }
        c.on_payload { |e| runtime.emit(:payload, e) }
        runtime_instance_settings and runtime_instance_settings[c] # @todo
      end
    end
    def porcelain # @todo after:#100.200: not here
      self
    end
    attr_accessor :runtime_instance_settings
  end
end

