require_relative 'core'

Skylab::TanMan::API || nil                     # #preload here, prettier below

module Skylab::TanMan

  module CLI
    extend Autoloader                          # to autoload files under cli/

    def self.new *a, &b
      CLI::Client.new( *a, &b )
    end
  end



  module CLI::Actions             # a box-like module that is all defined in
                                  # this file. needs to be created before the
  end                             # Action base class will be created below.



  CLI::Action || nil              # load this class that's defined in another
  class CLI::Action               # file and re-open it here so that we can
                                  # have the below re-usable option definitions
                                  # in this file to keep them all centralized.

    def dry_run_option o
      o.on '-n', '--dry-run', 'dry run.' do param_h[:dry_run] = true end
    end

    def help_option o
      o.on '-h', '--help', 'this screen.' do
        enqueue! :tan_man_original_help
      end
    end

    def verbose_option o
      o.on '-v', '--verbose', 'verbose output.' do param_h[:verbose] = true end
    end
  end



  class CLI::Actions::Status < CLI::Action
    include Porcelain::Table::RenderTable

    desc "show the status of the config director{y|ies} active at the path."

    def build_option_parser
      o = TanMan::Services::OptionParser.new
      help_option o
      o
    end

    def invoke path=nil
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

    def build_option_parser
      o = TanMan::Services::OptionParser.new
      dry_run_option o
      help_option o
      o
    end

    def invoke path=nil
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

    def build_option_parser
      o = TanMan::Services::OptionParser.new
      o.on '-g', '--global', 'add it to the global config file.' do
        param_h[:global] = true
      end
      help_option o
      o
    end

    def invoke name, host
      args = param_h.merge( name: name, host: host )
      args[:resource] = args.delete(:global) ? :global : :local
      result = api_invoke args
      result
    end
  end



  class CLI::Actions::Remote::List < CLI::Action
    include Porcelain::Table::RenderTable

    desc "list the remotes."

    def build_option_parser
      o = TanMan::Services::OptionParser.new
      help_option o
      o.on '-v', '--verbose', 'show more fields.' do
        param_h[:verbose] = true
      end
      o
    end

    def invoke
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

    def build_option_parser
      o = TanMan::Services::OptionParser.new
      help_option o
      o.on '-r', '--resource NAME',
        'which config file (e.g. global, local) (default: first found)' do |v|
        param_h[:resource_name] = v
      end
      o
    end

    def invoke remote_name
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

    def build_option_parser
      o = TanMan::Services::OptionParser.new
      help_option o
      o
    end

    def invoke path
      api_invoke path: path
    end
  end



  class CLI::Actions::Graph::Tell < CLI::Action

    desc "there's a lot you can tell about a man from his choice of words"

    def build_option_parser
      o = TanMan::Services::OptionParser.new
      o.on '-f', '--force',
        'rewrites the cached treetop parser file (#dev)' do
        param_h[:force] = true
      end
      help_option o
      o
    end

    def invoke *word
      api_invoke words: word, force: param_h[:force]
    end
  end



  class CLI::Actions::Graph::Check < CLI::Action

    desc 'checks if the (dependency graph) file exists and can be parsed.'

    def build_option_parser
      o = TanMan::Services::OptionParser.new
      help_option o
      verbose_option o
      o
    end

    def invoke dotfile=nil
      api_invoke path: dotfile, verbose: param_h[:verbose]
    end
  end



  class CLI::Actions::Graph::Push < CLI::Action

    desc "push any single file anywhere in the world."
    desc "(scp wrapper)"

    def build_option_parser
      o = TanMan::Services::OptionParser.new
      dry_run_option o
      help_option o
      o
    end

    def invoke remote_name, file
      api_invoke param_h.merge( remote_name: remote_name, file_path: file )
    end
  end



  class CLI::Actions::Graph::Example < CLI::Action

    desc "what graph example to use? (gets or sets it)"

    def build_option_parser
      o = TanMan::Services::OptionParser.new
      help_option o
      o
    end

    def invoke name=nil
      if name
        api_invoke [:graph, :example, :set], name: name
      else
        api_invoke [:graph, :example, :get]
      end
    end
  end
end
