require File.expand_path('../api', __FILE__)

module Skylab::TanMan

  module MyNamespaceInstanceMethods
    include MyActionInstanceMethods
  end

  class Cli < Bleeding::Runtime
    extend PubSub::Emitter
    emits Bleeding::EVENT_GRAPH.merge(MY_EVENT_GRAPH)

    actions_module { self::Actions }

    def initialize
      super
      @stdout = $stdout
      if block_given?
        yield self
      else
        on_all { |e| stdout.puts e.message }
      end
    end
    attr_accessor :stdout
  end

  class Cli::Action
    extend Bleeding::Action
    extend Bleeding::DelegatesTo
    extend PubSub::Emitter

    emits Bleeding::EVENT_GRAPH.merge(MY_EVENT_GRAPH)

    include MyActionInstanceMethods

    def api
      @api and return @api
      require File.expand_path('../api/binding', __FILE__)
      @api = Api::Binding.new(self)
    end

    def initialize runtime
      @api = nil
      my_action_init
      @runtime = runtime
      on_error { |e| add_invalid_reason( format_error e ) }
      on_all   { |e| runtime.emit(e) }
    end

    attr_reader :runtime
    delegates_to :runtime, :stdout
  end

  module Cli::Actions
  end

  module Cli::Actions::Remote
    extend Bleeding::Namespace
    include MyNamespaceInstanceMethods
    desc "manage remotes."
    summary { ["#{action_syntax} remotes"] }
  end

  class Cli::Actions::Remote::Add < Cli::Action
    desc "add the remote."
    def execute name, host
      api.invoke name: name, host: host
    end
  end

  class Cli::Actions::Remote::List < Cli::Action
    desc "list the remotes."
    def execute
      require 'skylab/porcelain/table'
      table = api.invoke or return false
      Porcelain.table(table, separator: '  '){ |o| o.on_all { |e| emit(:out, e) } }
      true
    end
  end

  class Cli::Actions::Remote::Rm < Cli::Action
    desc "remove the remote."
    def execute remote_name
      api.invoke remote_name: remote_name
    end
  end

  class Cli::Actions::Push < Cli::Action
    desc "push any single file anywhere in the world."
    desc "(scp wrapper)"
    option_syntax do |h|
      on('-n', '--dry-run', 'dry run.') { h[:dry_run] = true }
    end
    def execute remote_name, file, opts
      api.invoke opts.merge(remote: remote_name, file:file)
    end
  end
end

