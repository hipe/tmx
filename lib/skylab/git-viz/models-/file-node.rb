module Skylab::GitViz

  class Models_::File_Node

    GitViz::Lib_::Porcelain[]::Tree[ self ]

    def self.[] * x_a
      node_a = Tree_node_a__.new( x_a ).execute
      node_a and from :path_nodes, node_a
    end

    def set_node_payload x
      @repo_trail = x ; nil
    end

    attr_reader :repo_trail

    attr_accessor :commitpoint_manifest

    class Tree_node_a__

     GitViz::Lib_::Basic_Set[ self,
        :with_members, %i( pathname VCS_front ).freeze,
        :initialize_basic_set_with_iambic ]

      def initialize x_a
        initialize_basic_set_with_iambic x_a
      end
      def execute
        ok = procure_repo
        ok &&= procure_bunch
        ok && turn_that_bunch_into_whatever
      end
    private
      def procure_repo
        @repo = @VCS_front.procure_repo_from_pathname @pathname
        @repo && true
      end
      def procure_bunch
        @bunch = @repo.build_hist_tree_bunch
        @bunch && true
      end
      def turn_that_bunch_into_whatever
        _a = @bunch.get_trail_scanner.to_a
        _a
      end
    end
  end
end
