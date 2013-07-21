module Skylab::SubTree

  class CLI::Action

    extend SubTree::Core::Action

    include CLI::Styles

    ACTIONS_ANCHOR_MODULE = SubTree::CLI::Actions

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
