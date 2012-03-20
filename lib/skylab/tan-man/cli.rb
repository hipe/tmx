require File.expand_path('../api', __FILE__)

module Skylab::TanMan

  module ConfigMethods
    def config
      @config and return @config
      require ROOT.join('models/config').to_s
      @config = Models::Config.new(self, TanMan.conf_path).init
    end

    # loudly
    def config?
      config and return true
      error "sorry, failed to load config file subsystem :("
    end
  end

  module MyActionInstanceMethods
    extend Bleeding::DelegatesTo

    delegates_to :runtime, :config, :config?

    def error msg
      emit :error, msg
      false
    end
  end

  VERBS = { is: ['exist', 'is', 'are'], no: ['no '] }
  module MyActionInstanceMethods
    def s a, v=nil # just one tiny hard to read hack
      v.nil? and return( 1 == a.size ? '' : 's' )
      VERBS[v][case a.count ; when 0 ; 0 ; when 1 ; 1 ; else 2 ; end]
    end
  end

  module MyNamespaceInstanceMethods
    include MyActionInstanceMethods
  end

  class Cli < Bleeding::Runtime
    extend PubSub::Emitter
    emits Bleeding::EVENT_GRAPH.merge(MY_GRAPH)
    include ConfigMethods

    def initialize
      super
      @config = nil
      @stdout = $stdout
      if block_given?
        yield self
      else
        on_all { |e| stdout.puts e.payload.first }
      end
    end
    attr_accessor :stdout
  end

  class MyAction
    extend Bleeding::Action
    extend Bleeding::DelegatesTo

    extend PubSub::Emitter
    emits Bleeding::EVENT_GRAPH.merge(MY_GRAPH)

    include MyActionInstanceMethods

    def api
      @api and return @api
      require File.expand_path('../api/binding', __FILE__)
      @api = Api::Binding.new(self)
    end

    def format_error event
      event.tap do |e|
        if runtime.runtime
          subj, verb, obj = [runtime.runtime.program_name, action.name, runtime.actions_module.name]
        else
          subj, verb = [runtime.program_name, action.name]
        end
        e.payload[0] = "#{subj} failed to #{verb}#{" #{obj}" if obj}: #{e.message}"
      end
    end

    def initialize runtime
      @api = nil
      @invalid_reasons = []
      @runtime = runtime
      on_error { |e| @invalid_reasons.push(format_error(e)) }
      on_all   { |e| runtime.emit(e.type, *e.payload) }
    end

    attr_reader :runtime
    delegates_to :runtime, :stdout

    def valid?
      @invalid_reasons.size.nonzero? and return false
      required_ok?
      @invalid_reasons.size.zero?
    end
  end

  module Actions
  end

  module Actions::Remote
    extend Bleeding::Namespace
    include MyNamespaceInstanceMethods
    desc "manage remotes."
    summary { ["#{action_syntax} remotes"] }
  end

  class Actions::Remote::Add < MyAction
    desc "add the remote."
    def execute name, host
      config? or return
      config.add_remote(name, host) or help(invite_only: true)
    end
  end

  class Actions::Remote::List < MyAction
    desc "list the remotes."
    def execute
      config? or return
      require 'skylab/porcelain/table'
      Porcelain.table(Enumerator.new do |y|
        config.remotes.each do |r|
          y << Enumerator.new do |yy|
            yy << r.name
            yy << r.url
          end
        end
      end, :separator => '  ' ) {|o| o.on_all { |e| emit(:out, e) } }
      true
    end
  end

  class Actions::Remote::Rm < MyAction
    desc "remove the remote."
    def execute remote_name
      config? or return
      unless remote = config.remotes.detect { |r| remote_name == r.name }
        a = config.remotes.map { |r| "#{pre r.name}" }
        b = error "couldn't find a remote named #{remote_name.inspect}"
        emit :info, "#{s a, :no}known remote#{s a} #{s a, :is} #{oxford_comma(a, ' and ')}".strip << '.'
        return b
      end
      !! config.remotes.remove(remote)
    end
  end

  class Actions::Push < MyAction
    desc "push any single file anywhere in the world."
    desc "(scp wrapper)"
    option_syntax do |h|
      on('-n', '--dry-run', 'dry run.') { h[:dry_run] = true }
    end
    def execute remote_name, file, opts
      api.invoke(:push, opts.merge(remote: remote_name, file:file))
    end
  end
end

