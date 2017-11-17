module Skylab::TanMan

  class Models_::Node

    class Actions::Add

      def definition

        _these = Home_::DocumentMagnetics_::CommonAssociations.all_

        [
          :required, :property, :node_name,
            # not normalized here "on the surface" - we let the deepestmost
            # performer validate it at the end of the line. do not consider
            # it robust - it has been covered for some HTML escaping only

          :properties, _these,
          :flag, :property, :dry_run,
        ]
      end

      def initialize
        extend Home_::Model_::CommonActionMethods
        init_action_ yield
        @_associations_ = {}  # #[#031]
      end

      def execute

        sct = with_mutable_digraph_ do
          __money
        end

        sct && sct.user_value
      end

      def __money

        _fb = Here_::NodesFeatureBranchFacade_TM.new @_mutable_digraph_

        _ = _fb.node_by_ do |o|

          o.unsanitized_label_string = @node_name
          o.top_channel_for_created_symbol = :success  # not `info`
          o.verb_lemma_symbol = :create
          o.listener = _listener_
        end

        _ || NIL_AS_FAILURE_
      end

      Actions = nil

      # ==
      # ==
    end
  end
end
# #history-A: broke out of main model file (and full rewrite)
