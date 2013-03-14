module Skylab::Snag

  class CLI::Action::Box < CLI::Action

    include Headless::CLI::Box::DSL::InstanceMethods

    def initialize request_client, _=nil  # (namespace sheet, not interesting)
      init_headless_cli_box_dsl request_client
    end                           # rc is nil when box needs a charged graph
                                  # of children to describe

    extend Headless::CLI::Box::DSL::ModuleMethods  # `method_added`, keep at end

    cli_box_dsl_leaf_action_superclass CLI::Action  # but this after above
  end
end
