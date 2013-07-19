require File.expand_path('../file-node', __FILE__)

module Skylab::GitViz::API::Model
  class FileTree < FileNode
  end

  module FileTree::Constants
    SEPARATOR = '/'
  end

  class << FileTree
    include FileTree::Constants

    def build *a, &b
      FileNode.build(*a, &b)
    end

    def build_tree api, data
      repo = api.vcs.repo(data.path) or return repo
      files = repo.native.status
      o = from_files files
      o
    end

    # [ `from_files` #tombstone ]
  end
end

