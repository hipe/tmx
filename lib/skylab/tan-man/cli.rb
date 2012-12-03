require_relative 'core'

Skylab::TanMan::API || nil                     # #preload here, prettier below

module Skylab::TanMan

  module CLI
    extend Autoloader                          # to autoload files under cli/

    def self.new *a, &b
      CLI::Client.new( *a, &b )
    end
  end


  module CLI::Actions
                                  # a box-like module that is all defined here
  end


  class CLI::Actions::Status < CLI::Action
    desc "show the status of the config director{y|ies} active at the path."
    include Porcelain::Table::RenderTable

    option_syntax.help!

    def invoke path=nil
      path ||= begin
                 require 'fileutils'
                 ::FileUtils.pwd #  at [#021]: service.file_utils.pwd
               end
      events_a = api_invoke path: path
      groups = ::Hash.new { |h, k| h[k] = [] }
      events_a.each do |e|
        g = e.is?(:global) ? :global : (e.is?(:local) ? :local : :other)
        groups[g].push e
      end
      table = []
      groups.each do |k, e|
        table.push [ [:header, k], e.first.message ]
        table.concat( e[1..-1].map{ |x| [nil, x.message] } )
      end
      render_table table, separator: '  ' do |o|
        o.field(:header).format { |x| hdr x }
        o.on_all { |e| emit :payload, e }
      end
      true
    end
  end


  class CLI::Actions::Init < CLI::Action
    desc "create the #{API.local_conf_dirname} directory"
    option_syntax { |h| on('-n', '--dry-run', 'dry run.') { h[:dry_run] = true } }
    def invoke path=nil, opts
      api_invoke opts.merge( path: path,
                             local_conf_dirname: API.local_conf_dirname )
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
      b = api_invoke args
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
      table = api_invoke(opts) or return false
      render_table(table, separator: '  ') do |o|
        o.field(:resource_label).format { |x| "(resource: #{x})" }
        o.on_empty do |e|
          e.touch!
          n = table.num_resources_seen
          emit(:info, "no remotes found in #{n} config file#{s n}")
        end
        o.on_all do |e|
          emit(:payload, e) unless e.touched?
        end
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
      b = api_invoke opts.merge( remote_name: remote_name )
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
      api_invoke opts.merge( remote_name: remote_name, file_path: file )
    end
  end


  class CLI::Actions::Use < CLI::Action
    desc 'selects which (dependency graph) file to edit'
    option_syntax.help!
    def invoke path
      api_invoke path: path
    end
  end


  class CLI::Actions::Check < CLI::Action
    desc 'checks if the (dependency graph) file exists and can be parsed.'
    option_syntax.help!
    def invoke dotfile=nil
      api_invoke path: dotfile
    end
  end


  class CLI::Actions::Tell < CLI::Action
    desc "there's a lot you can tell about a man from his choice of words"
    option_syntax do |h|
      on( '-f', '--force',
         'rewrites the cached treetop parser file (#dev)' ) { h[:force] = true }
    end
    def invoke *word, opts
      api_invoke words: word, force: opts[:force]
    end
  end


  module CLI::Actions::Graph
    extend CLI::NamespaceModuleMethods
    desc "do things to graphs."
    summary { ["#{action_syntax} graph"] }
  end


  module CLI::Actions::Graph::Example
    extend CLI::NamespaceModuleMethods
    desc "what graph example to use?"
    summary { ["#{action_syntax} vleeplye"] }
  end


  class CLI::Actions::Graph::Example::Set < CLI::Action
    desc "set the example graph."
    option_syntax.help!
    def invoke name
      api_invoke name: name
    end
  end
end
