require File.expand_path('../file-node', __FILE__)

module Skylab::GitViz::Api::Model
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

    def from_files files
      _root = new
      files.reduce(new) do |root, native_status_file|
        root.find!(native_status_file.path.to_s.split(SEPARATOR)) do |node|
          node.file = native_status_file
        end
        root
      end
    end
  end
end

