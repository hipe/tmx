module Skylab::GitViz
  class Api::HistTree < Api::Action
    attribute :path, :pathname => true, :default => '.'
    def invoke
      require api.root.join('api/model/file-tree')
      Api::Model::FileTree.build_tree(api, self)
    end
  end
end

