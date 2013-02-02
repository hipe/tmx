require_relative 'core'

Skylab::TanMan::API || nil                     # #preload here, prettier below

module Skylab::TanMan

  module CLI
    extend MetaHell::Autoloader::Autovivifying::Recursive
                                  # (we need the above to be so before this file
                                  # finishes loading!)
    def self.new *a, &b
      CLI::Client.new( *a, &b )
    end
  end



  module CLI::Actions             # although all its containees may be in this
    extend MetaHell::Boxxy        # file, they may need boxxy's `const_fetch`
  end                             # for shenanigans. `Action` below requires
                                  # the existence of `Actions`



  CLI::Action || nil              # load this class that's defined in another
  class CLI::Action               # file and re-open it here so that we can
                                  # have the below re-usable option definitions
                                  # in this file to keep them all centralized.

    def dry_run_option o
      o.on '-n', '--dry-run', 'dry run.' do param_h[:dry_run] = true end
    end

    def help_option o
      o.on '-h', '--help', 'this screen.' do
        enqueue :tan_man_original_help
      end
    end

    def verbose_option o
      o.on '-v', '--verbose', 'verbose output.' do param_h[:verbose] = true end
    end
  end



  class CLI::Actions::Status < CLI::Action
    include Porcelain::Table::RenderTable

    desc "show the status of the config director{y|ies} active at the path."

    def process path=nil
      path ||= services.file_utils.pwd # at [#021]: services.file_utils.pwd
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

    desc "create the #{ API.local_conf_dirname } directory"

    option_parser do |o|
      dry_run_option o
      help_option o
    end

    def process path=nil
      api_invoke param_h.merge( path: path,
                                local_conf_dirname: API.local_conf_dirname )
    end
  end



  module CLI::Actions::Remote
    extend CLI::NamespaceModuleMethods
    desc "manage remotes."
    summary { ["#{action_syntax} remotes"] }
  end



  class CLI::Actions::Remote::Add < CLI::Action

    desc "add the remote."

    option_parser do |o|
      o.on '-g', '--global', 'add it to the global config file.' do
        param_h[:global] = true
      end
      help_option o
    end

    def process name, host
      args = param_h.merge( name: name, host: host )
      args[:resource] = args.delete(:global) ? :global : :local
      result = api_invoke args
      result
    end
  end



  class CLI::Actions::Remote::List < CLI::Action
    include Porcelain::Table::RenderTable

    desc "list the remotes."

    option_parser do |o|
      help_option o
      o.on '-v', '--verbose', 'show more fields.' do
        param_h[:verbose] = true
      end
    end

    def process
      result = nil # not false - we never do convention [#hl-109] invite
      begin
        table = api_invoke( param_h ) or break
        render_table table, separator: '  ' do |o|
          o.field(:resource_label).format { |x| "(resource: #{x})" }
          o.on_empty do |e|
            e.touch!
            n = table.num_resources_seen
            emit :info, "no remotes found in #{n} config file#{s n}"
          end
          o.on_all do |e|
            emit( :payload, e ) unless e.touched?
          end
        end
        result = true
      end while nil
      result
    end
  end



  class CLI::Actions::Remote::Rm < CLI::Action

    desc "remove the remote."

    option_parser do |o|
      help_option o
      o.on '-r', '--resource NAME',
        'which config file (e.g. global, local) (default: first found)' do |v|
        param_h[:resource_name] = v
      end
    end

    def process remote_name
      result = api_invoke param_h.merge( remote_name: remote_name )
      result
    end
  end



  module CLI::Actions::Graph
    extend CLI::NamespaceModuleMethods
    desc "do things to graphs."
    summary { ["#{action_syntax} graph"] }
  end



  class CLI::Actions::Graph::Use < CLI::Action

    desc 'selects which (dependency graph) file to edit'

    def process path
      api_invoke path: path
    end
  end



  class CLI::Actions::Graph::Tell < CLI::Action

    desc "there's a lot you can tell about a man from his choice of words"

    option_parser do |o|
      dry_run_option o
      o.on '-f', '--force', 'sometimes required by the action' do
        param_h[:force] = true
      end
      o.on '-g', 'rebuilds the Tell grammar (#dev)' do
        param_h[:rebuild_tell_grammar] = true
      end
      help_option o
      verbose_option o
    end

    def process *word
      api_invoke( { words: word }.merge param_h )
    end
  end



  class CLI::Actions::Tell < CLI::Action       # YIKES look how ridiculous
                                               # this "shortcut" is! (neat too)

    desc( * CLI::Actions::Graph::Tell.desc_lines )

    @option_parser_blocks = CLI::Actions::Graph::Tell.option_parser_blocks

    def process *word
      api_invoke [:graph, :tell], { words: word }.merge( param_h )
    end
  end


  class CLI::Actions::Graph::Association < CLI::Action::Box
    desc "low-level manipulation of associations (#dev)"
    desc "(for normal use use `tell`)"

  end


  class CLI::Actions::Graph::Check < CLI::Action

    desc 'checks if the (dependency graph) file exists and can be parsed.'

    option_parser do |o|
      help_option o
      verbose_option o
    end

    def process dotfile=nil
      api_invoke( { path: dotfile, verbose: false }.merge param_h )
    end
  end



  class CLI::Actions::Graph::Push < CLI::Action

    desc "push any single file anywhere in the world."
    desc "(scp wrapper)"

    option_parser do |o|
      dry_run_option o
      help_option o
    end

    def process remote_name, file
      api_invoke param_h.merge( remote_name: remote_name, file_path: file )
    end
  end



  class CLI::Actions::Graph::Starter < CLI::Action

    desc "what graph starter file to use? (gets or sets it)"

    def process name=nil
      if name
        api_invoke [:graph, :starter, :set], name: name
      else
        api_invoke [:graph, :starter, :get]
      end
    end
  end



  class CLI::Actions::Graph::Meaning < CLI::Action::Box
    desc "associate words with node attributes"

  end


  class CLI::Actions::Graph::Node < CLI::Action::Box
    desc "do things to nodes"

  end


  class CLI::Actions::Graph::Which < CLI::Action
    desc "which dotfile?"

    def process
      api_invoke
    end
  end
end
