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
  end
end
