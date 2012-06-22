require_relative 'api'

module Skylab::Treemap

  class CLI < Skylab::Porcelain::Bleeding::Runtime
    desc "experiments with R."

    Bleeding = Skylab::Porcelain::Bleeding

    extend Skylab::Autoloader
    extend Bleeding::DelegatesTo
    extend Skylab::PubSub::Emitter
    extend Bleeding::Stubs

    emits Bleeding::EVENT_GRAPH
    emits payload: :all, info: :all, error: :all
    event_class API::Event

    delegates_to :stylus, :do_stylize=, :em, :pre

    def self.action_collections
      super + [ * plugin_action_collections ]
    end

    def api
      API::Client.instance
    end

    def format prefix, e
      msg = e.message
      parens = msg.match(%r{\A(?<open>\()(?<message>.*)(?<close>\))\z}) and msg = parens[:message]
      msg = "#{prefix} #{msg}"
      if Hash === e.payload and e.payload[:path]
        msg = "#{msg}: #{e.path.pretty}"
      end
      parens and msg = "#{parens[:open]}#{msg}#{parens[:close]}"
      msg
    end

    def initialize
      @stylus = Stylus.new # let's have this be the only place this is built
      yield self
    end

    def porcelain # @todo 100.200 not here
      self.class
    end

    attr_reader :stylus

    def wire_action action
      verb = action.class.inflection.stems.verb
      inflected = action.class.inflection.inflected
      action.on_info_line { |e| emit(:info, e) }
      action.on_payload { |e| emit(e) }
      action.on_info do |e|
        emit(:info, format("#{em 'o'} #{inflected.noun} #{verb.progressive}", e))
      end
      action.on_error do |e|
        emit(:error, format("#{stylize 'o', :red} couldn't #{verb} #{inflected.noun}:", e))
      end
    end
  end
  module CLI::Actions
    extend Skylab::Autoloader
  end

  class CLI::Action
    extend CLI::Bleeding::Action
    extend CLI::Bleeding::DelegatesTo
    delegates_to :runtime, :api
    def wire
      @wire ||= ->(action) { wire_action(action) }
    end
    def wire_action api_action
      runtime.wire_action api_action
      api_action.stylus = runtime.stylus
      runtime.stylus.wire! self, api_action
      api_action
    end
  end
  class << CLI
    def build_client_instance runtime, slug
      new do |c|
        c.program_name = slug
        c.on_error   { |e| runtime.emit(:error, e) }
        c.on_help    { |e| runtime.emit(:help,  e) }
        c.on_info    { |e| runtime.emit(:info, e) }
        c.on_payload { |e| runtime.emit(:payload, e) }
        c.do_stylize = runtime.err.tty?
        runtime_instance_settings and runtime_instance_settings.call(c) # @todo #100.200
      end
    end
    def plugin_action_collections
      return []
      @plugin_action_collections_cache ||= begin
      end
    end
    def porcelain # @todo #100.200 not here
      self
    end
    attr_accessor :runtime_instance_settings
  end
end

