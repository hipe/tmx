require File.expand_path('../api', __FILE__)
require 'skylab/porcelain/core'

module Skylab::TanMan

  class CLI < Bleeding::Runtime
    extend PubSub::Emitter

    emits EVENT_GRAPH
    event_class API::Event

    def initialize
      @singletons = API::Singletons.new
      @stderr = $stderr ; @stdout = $stdout # defaults that might get changed below
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

  module CLI::ActionInstanceMethods
    include API::RuntimeExtensions
    def runtime
      parent # their api to ours
    end
  end

  class CLI
    include CLI::ActionInstanceMethods
  end

  class CLI::Action
    extend Bleeding::ActionModuleMethods
    extend Bleeding::DelegatesTo
    extend PubSub::Emitter
    include CLI::ActionInstanceMethods

    emits(:out, EVENT_GRAPH)
    event_class API::Event

    alias_method :action_class, :class

    delegates_to :action_class, :action_name

    def self.action_name # @todo couches 100
      aliases.first # pathify(to_s.split('::').last)
    end
    def self.invocation_syntax #@todo couches 100
      "#{aliases.first} #{syntax}"
    end

    def api
      @api ||= begin
        require_relative 'api/binding'
        API::Binding.new(self)
      end
    end

    def format_error event
      event.tap do |e|
        if runtime.runtime
          subj, verb, obj = [runtime.runtime.program_name, aliases.first, runtime.aliases.first]
        else
          subj, verb = [runtime.program_name, aliases.first]
        end
        e.message = "#{subj} failed to #{verb}#{" #{obj}" if obj}: #{e.message}"
      end
    end

    def full_action_name_parts
      a = [aliases.first]
      root_id = root_runtime.object_id
      current = self
      loop do
        root_id == current.runtime.object_id and break
        a.push(( current = current.runtime).aliases.first)
      end
      a.reverse
    end

    def initialize
      @api = nil
      on_no_config_dir do |e|
        emit(:error, "couldn't find #{e.touch!.dirname} in this or any parent directory: #{e.from.pretty}")
        emit(:info, "(try #{pre( "#{root_runtime.program_name} " <<
          CLI::Actions::Init.invocation_syntax )} to create it)")
      end
      on_info  { |e| e.message = "#{runtime.program_name} #{action_name}: #{e.message}" }
      on_error { |e| add_invalid_reason( format_error e ) }
      on_all   { |e| runtime.emit(e) unless e.touched? }
    end

    alias_method :on_no_action_name, :full_action_name_parts

    delegates_to :runtime, :text_styler
  end

  module CLI::NamespaceModuleMethods
    include Bleeding::NamespaceModuleMethods
    def build runtime
      CLI::NamespaceRuntime.new(self).build(runtime)
    end
  end

  class CLI::NamespaceRuntime < Bleeding::NamespaceInferred
    include API::RuntimeExtensions
    include CLI::ActionInstanceMethods
  end

  module CLI::Actions
  end

  class CLI::Actions::Status < CLI::Action
    desc "show the status of the config director{y|ies} active at the path."
    include Porcelain::Table::RenderTable
    def invoke path=nil
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
      render_table(table, separator: '  ') do |o|
        o.field(:header).format { |x| hdr x }
        o.on_all { |e| emit(:out, e) }
      end
    end
  end

  class CLI::Actions::Init < CLI::Action
    desc "create the #{API.local_conf_dirname} directory"
    option_syntax { |h| on('-n', '--dry-run', 'dry run.') { h[:dry_run] = true } }
    def invoke path=nil, opts
      api.invoke opts.merge(path: path, local_conf_dirname: API.local_conf_dirname)
    end
  end

  module CLI::Actions::Remote
    extend CLI::NamespaceModuleMethods
    desc "manage remotes."
    summary { ["#{action_syntax} remotes"] }
  end

  class CLI::Actions::Remote::Add < CLI::Action
    option_syntax do |h|
      on('-g', '--global', "add it to the global config file.") { h[:global] = true }
    end
    desc "add the remote."
    def invoke name, host, opts
      args = opts.merge(name: name, host: host)
      args[:resource] = args.delete(:global) ? :global : :local
      b = api.invoke(args)
      b == false and help(invite_only: true)
      b
    end
  end

  class CLI::Actions::Remote::List < CLI::Action
    desc "list the remotes."
    option_syntax do |h|
      on('-v', '--verbose', "show more fields.") { h[:verbose] = true }
    end
    include Porcelain::Table::RenderTable
    def invoke opts
      table = api.invoke(opts) or return false
      render_table(table, separator: '  ') do |o|
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

  class CLI::Actions::Remote::Rm < CLI::Action
    desc "remove the remote."
    option_syntax do |h|
      on('-r', '--resource NAME', "which config file (e.g. global, local) (default: first found)") do |v|
        h[:resource_name] = v
      end
    end
    def invoke remote_name, opts
      b = api.invoke opts.merge(remote_name: remote_name)
      b == false and help(invite_only: true)
      b
    end
  end

  class CLI::Actions::Push < CLI::Action
    desc "push any single file anywhere in the world."
    desc "(scp wrapper)"
    option_syntax do |h|
      on('-n', '--dry-run', 'dry run.') { h[:dry_run] = true }
    end
    def invoke remote_name, file, opts
      api.invoke(opts.merge(remote_name: remote_name, file_path:file))
    end
  end

  class CLI::Actions::Use < CLI::Action
    desc 'selects which (dependency graph) file to edit'
    def invoke path
      api.invoke(path: path)
    end
  end
end

