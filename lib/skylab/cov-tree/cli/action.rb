module Skylab::CovTree

  class CLI::Action

    extend CovTree::Core::Action

    include CLI::Styles

    ACTIONS_ANCHOR_MODULE = CovTree::CLI::Actions

    def initialize supernode
      @infostream = supernode.infostream
      @pen = supernode.pen
      super
    end

  private

    def api_action_class
      API::Actions.const_fetch local_normal_name
    end
  end
end
