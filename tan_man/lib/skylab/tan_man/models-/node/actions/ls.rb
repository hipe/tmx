module Skylab::TanMan

  class Models_::Node

    class Actions::Ls

      def definition
        _these = Home_::DocumentMagnetics_::CommonAssociations.to_workspace_related_stream_  # ..
        [
          :properties, _these,
        ]
      end

      def initialize
        extend Home_::Model_::CommonActionMethods
        init_action_ yield
      end

      def execute
        with_immutable_digraph_ do
          __via_immutable_digraph
        end
      end

      def __via_immutable_digraph

        NodesFeatureBranchFacade_TM.new( @_immutable_digraph_ ).to_node_entity_stream_
      end

      Actions = nil

      # ==
      # ==
    end
  end
end
# #history: broke out of main model file (and full rewrite)
