module Skylab::Snag

  class Models::Manifest

    class Agent_Adapter__

      # so we can keep track of what "services" the agents need

      MEMBER_A_ = [
        :all_nodes_p,
        :file_utils_p,
        :pathname,
        :manifest_file_p,
        :render_lines_p,
        :tmpdir_p
      ].freeze

      Snag_::Lib_::Basic_Fields[ :client, self,
        :globbing, :absorber, :initialize,
        :field_i_a, MEMBER_A_ ]

      attr_reader( * MEMBER_A_ )

      def all_nodes
        @all_nodes_p.call
      end

      def render_line_a node, *identifier_d
        @render_lines_p[ node, *identifier_d ]
      end

      def get_subset_a
        h = self.class::BASIC_FIELDS_H_
        SUBSET_A_.reduce [] do |m, i|
          m << i << instance_variable_get( h.fetch i )
        end
      end

      _intrinsic = [ :render_lines_p, :all_nodes_p ]

      SUBSET_A_ = ( MEMBER_A_ - _intrinsic ).freeze
    end
  end
end
