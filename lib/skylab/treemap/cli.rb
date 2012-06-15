require_relative 'api'

module Skylab::Treemap
  Bleeding = Skylab::Porcelain::Bleeding
  class CLI < Bleeding::Runtime
    extend Skylab::PubSub::Emitter

    emits Bleeding::EVENT_GRAPH
    emits payload: :all, info: :all, error: :all

    desc "experiments with R."

    def api
      @api ||= API::Client.new
    end

    def porcelain # @todo after:#100.200: not here
      self.class
    end

    actions_module { CLI::Actions }

    def wire
      @wire ||= ->(action) { wire_action(action) }
    end

    def wire_action action
      action.on_all { |e| emit(e) }
    end
  end
  module CLI::Actions
  end
  class CLI::Action
    extend Bleeding::Action
    extend Bleeding::DelegatesTo
    delegates_to :runtime, :api, :wire
  end
  class CLI::Actions::Install < CLI::Action
    desc "for installing R"

    URL_BASE = 'http://cran.stat.ucla.edu/'
    def execute
      emit :payload, "To install R, please download the package for your OS from #{URL_BASE}"
    end
  end
  class CLI::Actions::Render < CLI::Action
    desc "render a treemap from a text-based tree structure"
    option_syntax do |o|
      o[:char] = '+'
      on('-c', '--char <CHAR>', %{use CHAR (default: #{o[:char]})}) { |v| o[:char] = v }
    end
    def execute path, opts
      api.action(:render).wire!(&wire).invoke(opts.merge(path: path))
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

