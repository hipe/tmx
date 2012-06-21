require_relative 'api'

module Skylab::Treemap

  class CLI < Skylab::Porcelain::Bleeding::Runtime
    desc "experiments with R."

    Bleeding = Skylab::Porcelain::Bleeding # pls don't ask

    extend Skylab::Autoloader
    extend Bleeding::DelegatesTo
    extend Skylab::PubSub::Emitter

    emits Bleeding::EVENT_GRAPH
    emits payload: :all, info: :all, error: :all
    event_class API::Event

    delegates_to :stylus, :do_stylize=, :em, :pre

    def api
      @api ||= API::Client.new
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

    def find token
      action = super or return action
      action.respond_to?(:stub?) && action.stub? and action = CLI::Actions.const_get(action.const)
      action
    end

    def help_list
      if CLI::ActionStubs == action.actions_module
        CLI::ActionStubs.values.each { |s| CLI::Actions.const_get(s.const) }
        action.actions_module = CLI::Actions
      end
      super
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
  class CLI::ActionStub < Struct.new(:const)
    def name
      const.gsub(/(?:^|([a-z]))([A-Z])/) { "#{$1}#{'-' if $1}#{$2}" }.downcase
    end
    def names
      [name]
    end
    def visible?
      true
    end
    def stub?
      true
    end
    def summary
fail("no")
    end
  end
  CLI::ActionStubs = Class.new(Hash).class_eval do
    alias_method :constants, :keys
    alias_method :const_get, :[]
    def load_actions!
      (@loaded ||= nil) and return
      CLI::Actions.dir.children.each do |child|
        const = child.basename.to_s.sub(/\.rb\z/,'').gsub(/(?:^|-)([a-z])/){ $1.upcase }
        stub = CLI::ActionStubs[const] = CLI::ActionStub.new(const)
       # puts "OK: #{stub}"
      end
      @loaded = true
    end
    self.new
  end
  CLI.actions_module CLI::ActionStubs

  class CLI::Action
    extend CLI::Bleeding::Action
    extend CLI::Bleeding::DelegatesTo
    delegates_to :runtime, :api
    def stub?
      false
    end
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
    def porcelain # @todo #100.200 not here
      self
    end
    attr_accessor :runtime_instance_settings
  end
end

