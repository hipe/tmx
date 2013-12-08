module Skylab::TanMan

  class CLI::NamespaceRuntime < Bleeding::Namespace::Inferred
    # to be refactored at [#023]

    TanMan::Sub_Client[ self, :anchored_program_name, :expression_agent ]

    include Core::SubClient::InstanceMethods
    # or core action i.m's
    #

  private

    def initialize client_x, module_with_actions
      # this was the site of a lot of blood
      _namespace_inferred_init module_with_actions
      super client_x
    end

    def normalized_invocation_string # #compat-headless #compat-bleeding
      program_name
    end
  end
end
