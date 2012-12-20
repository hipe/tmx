module Skylab::MyTree
  class API::Action
    extend Headless::Parameter::Definer
    extend Headless::Action::ModuleMethods

    include Headless::Parameter::Controller::InstanceMethods
    include Headless::CLI::Action::InstanceMethods # look!; sub-client

    ANCHOR_MODULE = API::Actions

    def default_action
      :process
    end
  end
end
