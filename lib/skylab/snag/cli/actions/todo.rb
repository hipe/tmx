module Skylab::Snag

  class CLI::Actions::Todo < CLI::Action::Box

    cli_box_dsl_original_desc 'actions that work with TODO-like tags'

    desc "a report of the @#{ }todo's in a codebase"

    option_parser do |o|
      command_option o
      pattern_option o
      name_option o
      o.on '-t', '--tree', 'experimental tree rendering (try -t -t)' do
        param_h[:show_tree] ||= 0
        param_h[:show_tree] += 1
      end
      verbose_option o
      nil
    end

    def find *path
      res = nil
      action = api_build_wired_action [:to_do, :report]
      action.on_number_found do |e|
        info "(found #{ e.count } item#{ s e.count })"
      end
      if int = param_h.delete( :show_tree )
        tree = CLI::ToDo::Tree.new request_client, action, ( int > 1 )
      end
      res = action.invoke( { paths: path }.merge param_h )
      if tree
        res = tree.render
      end
      res
    end

    # --*--

    desc "melt is insanity"

    option_parser do |o|
      dry_run_option o
      name_option o
      pattern_option o
      verbose_option o
    end

    def melt *path
      action = api_build_wired_action [:to_do, :melt]
      action.invoke( {
        dry_run: false, paths: path, verbose: false
      }.merge param_h )
    end

  protected

    dsl_off

    d = -> do
      x = Snag::API::Actions::ToDo::Report.attributes.with :default
      d = -> { x }
      x
    end

    define_method :command_option do |o|
      o.on '--cmd', 'just show the internal grep / find command',
        'that would be used (debugging).' do
        param_h[:show_command_only] = true
      end
    end

    define_method :name_option do |o|
      o.on '--name <NAME>',
        "the filename patterns to search, can be specified",
        "multiple times to broaden the search #{
          }(default: '#{ d[][:names] * "', '" }')" do |n|
            ( param_h[:names] ||= [] ).push n
      end
    end

    define_method :pattern_option do |o|
      o.on '-p', '--pattern <PATTERN>',
        "the todo pattern to use (default: '#{ d[][:pattern] }')" do |p|
        param_h[:pattern] = p
      end
    end
  end
end
