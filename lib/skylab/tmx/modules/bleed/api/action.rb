module Skylab::Tmx::Modules::Bleed::Api
  module MyPathTools
    def contract_tilde path
      path.sub(%r{^#{Regexp.escape ENV['HOME']}/}, '~/')
    end
  end
  class Action
    extend ::Skylab::PubSub::Emitter
    emits :all,  info: :all, error: :all,
      head: :all, tail: :all

    include MyPathTools

    def config
      @config ||= ::Skylab::Tmx::Model::Config.build
    end
    def config_write
      config.write do |o|
        o.on_before    { |e| emit(:head, "config: #{e.message}") ; e.touch! }
        o.on_after     { |e| emit(:tail, " .. done (wrote #{e.bytes} bytes).") ; e.touch! }
        o.on_no_change { |e| emit(:info, e.message) ; e.touch! }
        o.on_all       { |e| emit(:info, "handle me-->#{e.type}<-->#{e.message}" ) unless e.touched? }
      end
    end
    def error msg
      emit :error, msg # child action class must actualy declare that it emits this
      false
    end
    def initialize ctx
      @config = nil
      @params = ctx
      yield self
    end
    attr_reader :params
  end
end

