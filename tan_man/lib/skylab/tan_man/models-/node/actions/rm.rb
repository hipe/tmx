module Skylab::TanMan

  class Models_::Node

    class Actions::Rm

      def definition

        _these = Home_::DocumentMagnetics_::CommonAssociations.to_workspace_related_stream_
        [
          :required, :property, :node_name,
          :properties, _these,
          :flag, :property, :dry_run,
        ]
      end

      def initialize
        extend Home_::Model_::CommonActionMethods
        init_action_ yield
      end

      def execute
        with_mutable_digraph_ do
          __via_mutable_digraph
        end
      end

      def __via_mutable_digraph

        _ob = NodesOperatorBranchFacade_TM.new @_mutable_digraph_

        _ent = _ob.procure_node_removal_via_label__ @node_name, & _listener_

        _ent || NIL_AS_FAILURE_
      end

      Actions = nil

      # ==
      # ==
    end
  end
end
# #history: broke out of main model file (and full rewrite)
