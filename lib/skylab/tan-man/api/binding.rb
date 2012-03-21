module Skylab::TanMan

  module Api::Actions
  end

  require File.expand_path('../action', __FILE__)

  class Api::Binding
    extend Bleeding::DelegatesTo

    def config
      @config and return @config
      require ROOT.join('models/config').to_s
      @config = Models::Config.new(self, TanMan.conf_path).init
    end
    def config?
      config and return true
      error "sorry, failed to load config file subsystem :("
    end
    delegates_to :runtime, :emit, :error
    def initialize runtime
      @config = nil
      @runtime = runtime
    end
    def invoke action=nil, args=nil
      if args.nil? && Hash === action
        args = action
        action = nil
      end
      Symbol === action and action = [action]
      action ||= runtime.full_action_name_parts
      require ROOT.join('api/actions', *action).to_s
      modul = action.reduce(Api::Actions) do |mod, name|
        /\A[-a-z]+\z/ =~ name or fail("invalid action name part: #{action.inspect}")
        mod.const_get name.to_s.gsub(/(?:^|-)([a-z])/){ $1.upcase }
      end
      modul.call(self, args)
    end
    delegates_to :runtime, :program_name
    attr_reader :runtime
    delegates_to :runtime, :stdout
  end
end

