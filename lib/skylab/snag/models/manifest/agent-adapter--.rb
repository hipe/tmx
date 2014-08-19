module Skylab::Snag

  class Models::Manifest

    class Agent_Adapter__

      # so we can keep track of what "services" the agents need

      def initialize * x_a
        process_iambic_fully x_a
      end

      def all_nodes
        @all_nodes.call
      end

      def build_file_utils * x_a
        @file_utils[ x_a ]
      end

      def manifest_file
        @manifest_file.call
      end

      def render_line_a identifier_d, node
        @render_line_a[ identifier_d, node ]
      end

      def produce_tmpdir * x_a
        @produce_tmpdir[ x_a ]
      end

      Snag_::Lib_::Entity[][ self, -> do
        o :properties,
            :all_nodes,
            :file_utils,
            :manifest_file,
            :render_line_a,
            :produce_tmpdir
      end ]
    end
  end
end
