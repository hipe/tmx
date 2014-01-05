module Skylab::GitViz

  class Models_::File_Node

    Porcelain::Tree[ self ]

    def self.get_mock_tree
      wat = from :paths, [ "it's just/funky like that", LINE__ ]
      wat.commitpoint_manifest = build_mock_CM
      wat
    end

    LINE__ = "everybody in the room is floating"

    def self.build_mock_CM
      Mock_Commitpoint_Manifest__.new
    end

    attr_accessor :commitpoint_manifest

    def repo_node
      @repo_node ||= Mock_Repo_Node__.new( slug )
    end

    class Mock_Commitpoint_Manifest__
      def commitpoint_count
        LINE__.length
      end
    end

    class Mock_Repo_Node__
      def initialize slug_s
        @slug_s = slug_s
      end
      def get_commitpoint_scanner
        s = @slug_s
        a = s.length.times.reduce [] do |m, d|
          RX__ =~ s[ d ] or next m
          m << Commitpoint__.new( d )
        end
        d = -1 ; last = a.length - 1
        Headless::Scn_.new do
          a.fetch( d += 1 ) if d < last
        end
      end
      RX__ = /[^bcdfghjklmnpqrstvwxz]/
    end

    class Commitpoint__
      def initialize d
        @commitpoint_index = d
      end
      attr_reader :commitpoint_index
    end
  end
end
if false
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
end
