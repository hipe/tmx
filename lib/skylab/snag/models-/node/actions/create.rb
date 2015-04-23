module Skylab::Snag

  class CLI::Actions::Nodes < CLI::Action_::Box

    box.desc 'make the magic happen'

    desc "Add an \"issue\" line to #{ Snag_::API.manifest_file }"  #[#hl-025]
    desc "Lines are added to the top and are sequentially numbered."

    # desc ' arguments:' #                      DESC # should be styled [#hl-025]

    # argument_syntax '<message>'
    # desc '   <message>                        a one line description of the issue'

    option_parser do |o|
      dry_run_option o
      verbose_option o
    end

    def add message
      call_API( [ :nodes, :add ], {
                 be_verbose: false,
                    dry_run: false,
                    message: message,
                working_dir: working_directory_path
      }.merge( @param_h ) ) do |o|
        o.on_error_event handle_error_event
        o.on_error_string handle_error_string
        o.on_info_event handle_info_event
        o.on_info_line handle_inside_info_string
        o.on_info_string handle_inside_info_string
        o.on_new_node -> node do
          # oops the manifest takes care of it
          # send_info_string "added #{ node.identifier.render } #{ node_msg_smry node }"
        end
       nil
      end
    end
  end
end
# :+#tombstone: `list` method was original conception point of #doc-point [#sl-102])
