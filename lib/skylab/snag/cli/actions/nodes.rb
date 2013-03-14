module Skylab::Snag

  class CLI::Actions::Nodes < CLI::Action::Box

    box.desc 'make the magic happen'

    desc "Add an \"issue\" line to #{ Snag::API.manifest_path }" #[#hl-025]
    desc "Lines are added to the top and are sequentially numbered."

    # desc ' arguments:' #                      DESC # should be styled [#hl-025]

    # argument_syntax '<message>'
    # desc '   <message>                        a one line description of the issue'

    option_parser do |o|
      dry_run_option o
      verbose_option o
    end

    def add message
      api_invoke( [ :nodes, :add ], {
                 be_verbose: false,
                    dry_run: false,
                    message: message,
      }.merge( param_h ) ) do |a|
        a.on_error handle_error
        a.on_info handle_info
        a.on_raw_info handle_raw_info
        a.on_new_node -> node do
          # oops the manifest takes care of it
          # info "added #{ node.identifier.render } #{ node_msg_smry node }"
        end
       nil
      end
    end

    # --*--

    desc "show the details of issue(s)"

    # action.aliases 'ls', 'show'

    option_parser do |o|

      o.on '-a', '--all', 'show all (even invalid) issues' do
        param_h[:include_all] = true
      end

      o.regexp_replace_tokens %r(^-(?<num>\d+)$) do |md|   # replace -1, -2 etc
        [ '--max-count', md[:num] ]                        # with this, before
      end                                                  # o.p gets it [#030]
                                                           # (AMAZING HACK)
      o.on '-n', '--max-count <num>',
        "limit output to N nodes (also -<n>)" do |n|
        param_h[:max_count] = n
      end

      o.on '-v', '--[no-]verbose',
        "`verbose` means yml-like output (default: verbose)" do |v|
        param_h[:be_verbose] = v
      end

      o.on '-V', '(same as `--no-verbose`)' do
        param_h[:be_verbose] = false
      end
    end

    option_parser_class CLI::Option::Parser  # use the custom one

    # (this function was original conception point of #doc-point [#sl-102])

    def list identifier_ref=nil
      api_invoke( [ :nodes, :reduce ],
        {     be_verbose: true,
          identifier_ref: identifier_ref }.merge!( param_h ) ) do |a|
        a.on_output_line handle_payload
        a.on_info        handle_info
        a.on_error       handle_error
        a.on_invalid_node do |e|
          info '---'
          e2 = API::Events::Lingual.new :esg, # hack  # #todo
            nil, @downstream_action,  # no stream name / what we collapsed to
            "##{ invalid_node_message e }"
          handle_error[ e2 ]  # whether or not it is an error is sort of a
        end                   # soft design concern
      end
    end
  end
end
