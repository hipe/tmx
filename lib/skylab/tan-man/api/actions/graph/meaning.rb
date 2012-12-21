module Skylab::TanMan
  module API::Actions::Graph::Meaning
    # this will get sexed by the autoloader
  end



  class API::Actions::Graph::Meaning::Forget < API::Action
    extend API::Action::Parameter_Adapter
  end



  class API::Actions::Graph::Meaning::Learn < API::Action
    extend API::Action::Parameter_Adapter

    PARAMS = [:create, :name, :value]

  protected

    def execute
      info "why sure"
      error "helf"

      # emit :info, 'neat'
      nil
    end
  end



  class API::Actions::Graph::Meaning::List < API::Action
    extend API::Action::Parameter_Adapter
  end
end
