module Skylab::MyTree
  class API::Action
    extend Headless::Parameter::Definer
    extend Headless::Action::ModuleMethods
    extend Headless::CLI::Action::ModuleMethods # play with dsl, look!

    include Headless::CLI::Action::InstanceMethods # look!; sub-client
    include Headless::Parameter::Controller::InstanceMethods  # after s.c above
      # b.c of h.l's `formal_attributes`/`formal_parameters` compat. hook

    ACTIONS_ANCHOR_MODULE = -> { API::Actions }

    def default_action
      :process
    end
  end
end
