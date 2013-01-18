module Skylab::Snag

  class CLI::Actions::Nodes < CLI::Action::Box
    extend Headless::CLI::Box::DSL

    cli_box_dsl_original_desc 'make the magic happen'

    desc "Add an \"issue\" line to #{ Snag::API.manifest_file_name }" #[#hl-025]
    desc "Lines are added to the top and are sequentially numbered."

    # desc ' arguments:' #                      DESC # should be styled [#hl-025]

    # argument_syntax '<message>'
    # desc '   <message>                        a one line description of the issue'

    option_parser do |o|
      dry_run_option o
      verbose_option o
    end

    def add message
      api_invoke [:nodes, :add], {
        dry_run: false, message: message, verbose: false
      }.merge( param_h )
    end

    # --*--

    desc "show the details of issue(s)"

    # action.aliases 'ls', 'show'

    option_parser do |o|
      o.on '-a', '--all', 'show all (even invalid) issues' do
        param_h[:all] = true
      end

      # @todo we would love to have -1, -2 etc

      o.on '-n', '--max-count <num>', "limit output to N nodes" do |n|
        param_h[:max_count] = n
      end

      o.on '-v', '--[no-]verbose',
        "`verbose` means yml-like output (default: verbose)" do |v|
        param_h[:verbose] = v
      end

      o.on '-V', '(same as `--no-verbose`)' do
        param_h[:verbose] = false
      end
    end

    def list identifier_ref=nil
      action = api_build_wired_action [:nodes, :reduce]

      # (below was original conception point of #doc-point [#sl-102])

      action.on_invalid_node do |e|
        info '---'
        error "error on line #{ e.line_number }-->#{ e.line }<--"

        e.message = "failed to parse line #{ e.line_number } because #{
          }#{ e.invalid_reason_string } (in #{ escape_path e.pathname })"
      end

      action.invoke( {
        identifier_ref: identifier_ref,
        verbose: true
      }.merge! param_h )
    end
  end
end
