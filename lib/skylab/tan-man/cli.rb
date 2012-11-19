require_relative 'core'

Skylab::TanMan::API || nil # #preload

module Skylab::TanMan
  class CLI < Bleeding::Runtime                # changes at [#018]
    extend Autoloader                          # to autoload files under cli/
    extend MetaHell::Let                       # used below, temporary #todo
    extend Core::Client::ModuleMethods         # per the pattern

    include Core::Client::InstanceMethods      # per the pattern

    emits Porcelain::Bleeding::EVENT_GRAPH     # b/c granulated UI events
                                               # note this gets merged with
                                               # 'parent' event graph above

    attr_reader :infostream

    attr_reader :paystream

    let :services_runtime do
      TanMan::Service::Runtime.new
    end

    attr_reader :singletons

    def text_styler ; self end

  protected

    def initialize _=nil, paystream=$stdout, infostream=$stderr # patt.[#sl-114]
      @singletons = API::Singletons.new # #todo:refactor to memoize
      @paystream = paystream      # these are just defaults that might ..
      @infostream = infostream    #   .. get changed in the yield below
      if block_given?
        yield self
      else
        on_out { |e| self.paystream.puts e.touch!.message }
        on_all { |e| self.infostream.puts(e.touch!.message) unless e.touched? }
      end
    end
  end


  module CLI::Actions
  end


  class CLI::Actions::Status < CLI::Action
    desc "show the status of the config director{y|ies} active at the path."
    include Porcelain::Table::RenderTable
    def invoke path=nil
      path ||= begin
                 require 'fileutils'
                 ::FileUtils.pwd # #todo temporary
               end
      groups = Hash.new { |h, k| h[k] = [] }
      ee = api_invoke path: path
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
    def invoke path
      api_invoke path: path
    end
  end


  class CLI::Actions::Check < CLI::Action
    desc 'checks if the (dependency graph) file exists and can be parsed.'
    def invoke dotfile=nil
      api_invoke path: dotfile
    end
  end


  class CLI::Actions::Tell < CLI::Action
    desc "there's a lot you can tell about a man from his choice of words"
    def invoke *word
      api_invoke words: word
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
    def invoke name
      api_invoke name: name
    end
  end
end
