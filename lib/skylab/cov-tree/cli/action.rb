module Skylab::CovTree

  class CLI::Action
    extend CovTree::Core::Action

    include CLI::Styles

    ACTIONS_ANCHOR_MODULE = CovTree::CLI::Actions

  protected

    def api_action_class
      API::Actions.const_fetch normalized_name
    end
  end
end
