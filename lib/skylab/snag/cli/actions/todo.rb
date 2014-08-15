module Skylab::Snag

  class CLI::Actions::Todo < CLI::Action::Box

    box.desc 'actions that work with TODO-like tags'

    desc "a report of the @#{}todo's in a codebase"

    option_parser do |o|
      command_option o
      pattern_option o
      name_option o
      o.on '-t', '--tree', 'experimental tree rendering (try -t -t)' do
        @param_h[:tree_level] ||= 0
        @param_h[:tree_level] += 1
      end
      verbose_option o
      nil
    end

    -> do  # `find`

      build_tree = nil

      define_method :find do |path, *paths|
        paths.unshift( path ) ; path = nil
        @param_h[ :paths ] = paths ; paths = nil
        if @param_h.key? :tree_level
          tree_level = @param_h.delete :tree_level
        end
        tree = nil
        res = call_API [ :to_do, :report ], @param_h do |a|
          a.on_info handle_info
          a.on_error handle_error
          a.on_command do |cmd|
            payload cmd
          end
          a.on_number_found do |num|
            info "(found #{ num } item#{ s num })"
          end
          if tree_level
            tree = build_tree[ a, tree_level, request_client ]
          else
            a.on_todo do |t|
              payload t.upstream_output_line
            end
          end
        end
        if tree && res
          res = tree.render
        end
        res
      end

      build_tree = -> action, level, client do
        tree = CLI::ToDo::Tree.new ( level > 1 ), client
        action.on_todo do |todo|
          tree << todo  # with each todo, build the tree
        end
        tree
      end
    end.call


    desc "melt is insanity"

    option_parser do |o|
      dry_run_option o
      name_option o
      pattern_option o
      verbose_option o
    end

    desc do |y|  # #todo - can you melt me
      df = Snag_::API::Actions::ToDo::Melt.attributes[ :paths ][ :default ]
      df.map!(& method( :ick ))
      y << 'arguments:'
      s = "  #{ say { param :path } } the path(s) to search (default: #{ df * ', '})"
      y << s
      nil
    end

    def melt *path
      if path.length.zero?  # triggering dflts to list params is not automatic
        path.concat Snag_::API::Actions::ToDo::Melt.attributes[ :paths ][ :default ]
      end
      call_API [ :to_do, :melt ],
        {           dry_run: false,
                      paths: path,
                 be_verbose: false }.merge!( @param_h ), -> a do
        a.on_payload handle_payload
        a.on_info handle_info
        a.on_raw_info handle_raw_info
        a.on_error handle_error
      end
    end

  private

    turn_DSL_off

    default = -> do
      box = Snag_::API::Actions::ToDo::Report.attributes.
        meta_attribute_value_box :default
      default = -> { box }
      box
    end

    define_method :command_option do |o|
      o.on '--cmd', 'just show the internal grep / find command',
        'that would be used (debugging).' do
        @param_h[:show_command_only] = true
      end
    end

    define_method :name_option do |o|
      o.on '--name <NAME>',
        "the filename patterns to search, can be specified",
        "multiple times to broaden the search #{
          }(default: '#{ default[][:names] * "', '" }')" do |n|
            ( @param_h[:names] ||= [] ).push n
      end
    end

    define_method :pattern_option do |o|
      o.on '-p', '--pattern <PATTERN>',
        "the todo pattern to use (default: '#{ default[][:pattern] }')" do |p|
        @param_h[:pattern] = p
      end
    end
  end
end
