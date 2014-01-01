module Skylab::GitViz
  class API::Actions::HistTree < API::Action
    attribute :path, :pathname => true, :default => '.'
    def invoke
      require api.root.join('api/model/file-tree')
      API::Model::FileTree.build_tree(api, self)
    end
  end
end
