require File.expand_path('../api', __FILE__)

module Skylab::TanMan

  module MyNamespaceInstanceMethods
    include MyActionInstanceMethods
  end

  class Cli < Bleeding::Runtime
    extend PubSub::Emitter
    emits EVENT_GRAPH

    actions_module { self::Actions }

    def initialize
      super
      @config = nil
      @singletons = Api::Singletons.new
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

    emits EVENT_GRAPH

    include MyActionInstanceMethods

    alias_method :action_class, :class

    delegates_to :action_class, :action_name

    def api
      @api and return @api
      require File.expand_path('../api/binding', __FILE__)
      @api = Api::Binding.new(self)
    end

    def initialize runtime
      @api = nil
      @runtime = runtime
      my_action_init
      on_no_config_dir do |e|
        error "couldn't find #{e.touch!.dirname} in this or any parent directory: #{e.from.pretty}"
        emit(:info, "(try #{pre "#{runtime.root_runtime.program_name} #{Cli::Actions::Init.syntax}"} to create it)")
      end
      on_info  { |e| e.message = "#{runtime.program_name} #{action_name}: #{e.message}" }
      on_error { |e| add_invalid_reason( format_error e ) }
      on_all   { |e| runtime.emit(e) unless e.touched? }
    end

    alias_method :on_no_action_name, :full_action_name_parts

    attr_reader :runtime
    delegates_to :runtime, :stdout
  end

  module Cli::Actions
  end

  class Cli::Actions::Init < Cli::Action
    desc "create the #{LOCAL_CONF_DIRNAME} directory"
    option_syntax { |h| on('-n', '--dry-run', 'dry run.') { h[:dry_run] = true } }
    def execute path=nil, opts
      api.invoke opts.merge(path: path, local_conf_dirname: LOCAL_CONF_DIRNAME)
    end
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

