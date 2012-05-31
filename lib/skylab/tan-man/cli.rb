require File.expand_path('../api', __FILE__)

module Skylab::TanMan

  class Cli < Bleeding::Runtime
    extend PubSub::Emitter

    emits EVENT_GRAPH
    event_class Api::Event

    actions_module { self::Actions }

    def initialize
      super
      @singletons = Api::Singletons.new
      @stderr = $stderr
      @stdout = $stdout
      if block_given?
        yield self
      else
        on_out { |e| stdout.puts(e.touch!.message) }
        on_all { |e| stderr.puts(e.touch!.message) unless e.touched? }
      end
    end
    def root_runtime ; self end
    attr_reader :singletons
    attr_accessor :stderr, :stdout
    def text_styler ; self end
  end

  class Cli::Action
    extend Bleeding::Action
    extend Bleeding::DelegatesTo
    extend PubSub::Emitter

    include Api::RuntimeExtensions

    emits EVENT_GRAPH
    event_class Api::Event

    alias_method :action_class, :class

    delegates_to :action_class, :action_name

    def api
      @api ||= begin
        require_relative 'api/binding'
        Api::Binding.new(self)
      end
    end

    def format_error event
      event.tap do |e|
        if runtime.runtime
          subj, verb, obj = [runtime.runtime.program_name, action.name, runtime.actions_module.name]
        else
          subj, verb = [runtime.program_name, action.name]
        end
        e.message = "#{subj} failed to #{verb}#{" #{obj}" if obj}: #{e.message}"
      end
    end

    def full_action_name_parts
      a = [action.name]
      root_id = root_runtime.object_id
      current = self
      until root_id == current.runtime.object_id
        current = current.runtime
        a.push current.name
      end
      a.reverse
    end

    def initialize runtime
      @api = nil
      @runtime = runtime
      on_no_config_dir do |e|
        emit(:error, "couldn't find #{e.touch!.dirname} in this or any parent directory: #{e.from.pretty}")
        emit(:info, "(try #{pre "#{runtime.root_runtime.program_name} #{Cli::Actions::Init.syntax}"} to create it)")
      end
      on_info  { |e| e.message = "#{runtime.program_name} #{action_name}: #{e.message}" }
      on_error { |e| add_invalid_reason( format_error e ) }
      on_all   { |e| runtime.emit(e) unless e.touched? }
    end

    alias_method :on_no_action_name, :full_action_name_parts

    attr_reader :runtime

    delegates_to :runtime, :text_styler
  end

  module Cli::Actions
  end

  class Cli::Actions::Status < Cli::Action
    desc "show the status of the config director{y|ies} active at the path."
    def execute path=nil
      require 'skylab/porcelain/table'
      path ||= FileUtils.pwd
      groups = Hash.new { |h, k| h[k] = [] }
      ee = api.invoke(path: path)
      ee.each do |e|
        groups[e.is?(:global) ? :global : (e.is?(:local) ? :local : :other )].push(e)
      end
      table = []
      groups.each do |k, e|
        table.push [[:header, k], e.first.message]
        table.concat( e[1..-1].map{ |x| [nil, x.message] } )
      end
      Porcelain.table(table, separator: '  ') do |o|
        o.field(:header).format { |x| hdr x }
        o.on_all { |e| emit(:out, e) }
      end
    end
  end

  class Cli::Actions::Init < Cli::Action
    desc "create the #{Api.local_conf_dirname} directory"
    option_syntax { |h| on('-n', '--dry-run', 'dry run.') { h[:dry_run] = true } }
    def execute path=nil, opts
      api.invoke opts.merge(path: path, local_conf_dirname: Api.local_conf_dirname)
    end
  end
  module Cli::Actions::Remote
    extend Bleeding::Namespace
    include Api::RuntimeExtensions
    desc "manage remotes."
    summary { ["#{action_syntax} remotes"] }
  end

  class Cli::Actions::Remote::Add < Cli::Action
    option_syntax do |h|
      on('-g', '--global', "add it to the global config file.") { h[:global] = true }
    end
    desc "add the remote."
    def execute name, host, opts
      args = opts.merge(name: name, host: host)
      args[:resource] = args.delete(:global) ? :global : :local
      b = api.invoke(args)
      b == false and help(invite_only: true)
      b
    end
  end

  class Cli::Actions::Remote::List < Cli::Action
    desc "list the remotes."
    option_syntax do |h|
      on('-v', '--verbose', "show more fields.") { h[:verbose] = true }
    end
    def execute opts
      require 'skylab/porcelain/table'
      table = api.invoke(opts) or return false
      Porcelain.table(table, separator: '  ') do |o|
        o.field(:resource_label).format { |x| "(resource: #{x})" }
        o.on_empty do |e|
          e.touch!
          n = table.num_resources_seen
          emit(:info, "no remotes found in #{n} config file#{s n}")
        end
        o.on_all { |e| emit(:out, e) unless e.touched? }
      end
      true
    end
  end

  class Cli::Actions::Remote::Rm < Cli::Action
    desc "remove the remote."
    option_syntax do |h|
      on('-r', '--resource NAME', "which config file (e.g. global, local) (default: first found)") do |v|
        h[:resource_name] = v
      end
    end
    def execute remote_name, opts
      b = api.invoke opts.merge(remote_name: remote_name)
      b == false and help(invite_only: true)
      b
    end
  end

  class Cli::Actions::Push < Cli::Action
    desc "push any single file anywhere in the world."
    desc "(scp wrapper)"
    option_syntax do |h|
      on('-n', '--dry-run', 'dry run.') { h[:dry_run] = true }
    end
    def execute remote_name, file, opts
      api.invoke(opts.merge(remote_name: remote_name, file_path:file))
    end
  end
end

