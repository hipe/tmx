module Skylab::Snag

  class CLI::Actions::Nodes < CLI::Action::Box

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
          # info "added #{ node.identifier.render } #{ node_msg_smry node }"
        end
       nil
      end
    end


    desc "show the details of issue(s)"

    # action.aliases 'ls', 'show'

    option_parser do |o|

      o.on '-a', '--all', 'show all (even invalid) issues' do
        @param_h[:include_all] = true
      end

      o.regexp_replace_tokens %r(^-(?<num>\d+)$) do |md|   # replace -1, -2 etc
        [ '--max-count', md[:num] ]                        # with this, before
      end                                                  # o.p gets it [#030]
                                                           # (AMAZING HACK)
      o.on '-n', '--max-count <num>',
        "limit output to N nodes (also -<n>)" do |n|
        @param_h[:max_count] = n
      end

      o.on '-v', '--[no-]verbose',
        "`verbose` means yml-like output (default: verbose)" do |v|
        @param_h[:be_verbose] = v
      end

      o.on '-V', '(same as `--no-verbose`)' do
        @param_h[:be_verbose] = false
      end
    end

    option_parser_class CLI::Option::Parser  # use the custom one

    # (this function was original conception point of #doc-point [#sl-102])

    def list identifier_ref=nil
      call_API( [ :nodes, :reduce ], {
              be_verbose: true,
          identifier_ref: identifier_ref,
             working_dir: working_directory_path
          }.merge!( @param_h ) ) do |o|
        o.on_error_event handle_error_event
        o.on_error_string handle_error_string
        o.on_info_event handle_info_event
        o.on_info_string handle_info_string
        o.on_invalid_node do |ev|
          send_info_line '---'
          _s = "##{ invalid_node_message ev }"
          _ev = Snag_::Model_::Event.inflectable_via_string _s
          handle_error_event[ _ev ]
        end
        o.on_output_line handle_payload_line
      end
    end
  end
end
