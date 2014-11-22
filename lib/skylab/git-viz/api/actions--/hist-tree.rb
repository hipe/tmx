module Skylab::GitViz

  class API::Actions__::Hist_Tree < API::Action_

    attribute :pathname, pathname: true, default: '.'

    def execute
      _VCS_front
      GitViz_::Models_::File_Node[
        :pathname, @pathname, :VCS_front, @VCS_front ]
    end
  end
end
