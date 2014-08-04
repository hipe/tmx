module Skylab::GitViz

  class Models_::File_Node

    GitViz::Lib_::Tree[].enhance_with_module_methods_and_instance_methods self

    def self.[] * x_a
      Build_Tree_Node__.build_tree_node x_a do |bld|
        file_node = from :path_nodes, bld.get_trail_a
        file_node.commitpoint_manifest = bld.commitpoint_mani
        file_node
      end
    end

    def set_node_payload x
      @repo_trail = x ; nil
    end

    attr_reader :repo_trail

    attr_accessor :commitpoint_manifest

    def some_commitpoint_manifest
      @commitpoint_manifest or fail 'sanity'
    end

    class Build_Tree_Node__

     GitViz::Lib_::Basic_Set[ self,
        :with_members, %i( pathname VCS_front ).freeze,
        :initialize_basic_set_with_iambic ]

      def self.build_tree_node x_a, & p
        new( x_a, p ).build_tree_node
      end

      def initialize x_a, p
        initialize_basic_set_with_iambic x_a
        @client_p = p
      end

      def build_tree_node
        pre_execute && @client_p[ self ]
      end

    private

      def pre_execute
        procure_repo && procure_bunch
      end
      def procure_repo
        @repo = @VCS_front.procure_repo_from_pathname @pathname
        @repo && true
      end
      def procure_bunch
        @bunch = @repo.build_hist_tree_bunch
        @bunch && true
      end

    public

      def get_trail_a
        @bunch.get_trail_scanner.to_a
      end

      def commitpoint_mani
        @repo.sparse_matrix
      end
    end
  end
end
