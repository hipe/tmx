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
        res = call_API [ :to_do, :report ], @param_h do |o|
          o.on_error_event handle_error_event
          o.on_error_string handle_error_string
          o.on_command_string do |cmd_s|
            send_payload_line cmd_s
          end
          o.on_number_found do |num|
            send_info_line "(found #{ num } item#{ s num })"
          end
          if tree_level
            tree = build_tree[ o, tree_level, listener ]
          else
            o.on_todo do |t|
              send_payload_line t.upstream_output_line
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
      a = Snag_::API::Actions::ToDo::Melt.attributes[ :paths ][ :default ]
      expression_agent.calculate do
        a = a.map( & method( :ick ) )
        y << 'arguments:'
        y << "  #{ par :path }#{
          }#{ SPACE_ * 20 }the path(s) to search (default: #{ a * ', '})"
      end
    end

    def melt *path
      if path.length.zero?  # triggering dflts to list params is not automatic
        path.concat Snag_::API::Actions::ToDo::Melt.attributes[ :paths ][ :default ]
      end
      call_API [ :to_do, :melt ],
        {           dry_run: false,
                      paths: path,
                 be_verbose: false,
                working_dir: working_directory_path
        }.merge!( @param_h ),
       -> o do
        o.on_error_event handle_error_event
        o.on_error_string handle_error_string
        o.on_info_event handle_info_event
        o.on_info_line handle_info_line
        o.on_info_string handle_inside_info_string
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
