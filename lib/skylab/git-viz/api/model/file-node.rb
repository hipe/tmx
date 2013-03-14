require 'skylab/porcelain/tree/node'

module Skylab::GitViz
  class API::Model::FileNode < ::Skylab::Porcelain::Tree::Node
    attr_accessor :file
  end
end
