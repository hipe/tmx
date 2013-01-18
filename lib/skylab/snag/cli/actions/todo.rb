module Skylab::Snag

  class CLI::Actions::Todo < CLI::Action::Box

    cli_box_dsl_original_desc 'actions that work with TODO-like tags'

    desc "a report of the @#{ }todo's in a codebase"

    option_parser do |o|
      d = Snag::API::Actions::ToDo::Report.attributes.with :default

      o.on '-p', '--pattern <PATTERN>',
        "the todo pattern to use (default: '#{ d[:pattern] }')" do |p|
        param_h[:pattern] = p
      end

      o.on '--name <NAME>',
        "the filename patterns to search, can be specified",
        "multiple times to broaden the search #{
          }(default: '#{ d[:names] * "', '" }')" do |n|
            ( param_h[:names] ||= [] ).push n
      end

      o.on '--cmd', 'just show the internal grep / find command',
         'that would be used (debugging).' do
        param_h[:show_command_only] = true
      end

      o.on '-t', '--tree', 'experimental tree rendering' do
        param_h[:show_tree] = true
      end

      nil
    end

    def find *path
      res = nil
      action = api_build_wired_action [:to_do, :report]
      action.on_number_found do |e|
        info "(found #{ e.count } item#{ s e.count })"
      end
      if param_h.delete :show_tree
        tree = CLI::ToDo::Tree.new action, request_client
      end
      res = action.invoke( { paths: path }.merge param_h )
      if tree
        res = tree.render
      end
      res
    end
  end
end
