  class CLI::Actions::Node < CLI::Action_::Box

    box.desc 'actions that act on a given node'

    desc 'close a node (remove tag #open and add tag #done)'

    option_parser do |o|
      dry_run_option o
      verbose_option o
    end

    def close node_ref
      call_API [ :node, :close ], {
                    dry_run: false,
                   node_ref: node_ref,
                 be_verbose: false,
                working_dir: working_directory_path
        }.merge( @param_h ) do |a|
        a.on_error_event handle_error_event
        a.on_error_string handle_error_string
        a.on_info_event handle_info_event
      end
    end
  end
