module Skylab::GitViz

  class Models_::File_Node

    Porcelain::Tree[ self ]

    def self.[] * x_a
      node_a = Tree_node_a__.new( x_a ).execute
      node_a and from :path_nodes, node_a
    end

    def self.get_mock_tree
      wat = from :paths, [ "it's just/funky like that", LINE__ ]
      wat.commitpoint_manifest = build_mock_CM
      wat
    end

    LINE__ = "everybody in the room is floating"

    def self.build_mock_CM
      Mock_Commitpoint_Manifest__.new
    end

    def set_node_payload x
      @repo_node = x ; nil
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

    class Tree_node_a__
      Lib_::Basic[]::Set[ self,
        :with_members, %i( pathname VCS_front ).freeze,
        :initialize_basic_set_with_iambic ]

      def initialize x_a
        initialize_basic_set_with_iambic x_a
      end
      def execute
        @repo = @VCS_front.procure_repo_from_path @pathname.expand_path
        @repo and execute_with_repo
      end
    private
      def execute_with_repo
        @repo.get_tree_node_a
      end
    end
  end
end
