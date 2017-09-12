module Skylab::TanMan

  module Models_::Graph

    class Actions::Use

      def definition

        _these = Home_::DocumentMagnetics_::CommonAssociations.to_workspace_related_stream_

        [
          :property, :starter,
          :property, :created_on,

          :properties, _these,

          :required, :property, :digraph_path,
        ]
      end

      def initialize
        @dry_run = false  # ..
        extend Home_::Model_::CommonActionMethods
        init_action_ yield
      end

      def execute
        with_mutable_workspace_ do
          __via_mutable_workspace
        end
      end

      def __via_mutable_workspace

        path = Here___::WriteGraph_to_Bytestore_via_Graph_and_Workspace___.call_by do |o|
          o.digraph_path = @digraph_path
          o.mutable_workspace = @_mutable_workspace_
          o.template_values_provider = self
          o.is_dry_run = @dry_run
          o.microservice_invocation = @_microservice_invocation_
          o.filesystem = _invocation_resources_.filesystem
          o.listener = _listener_
        end

        if path # #cov1.5
          [ :_result_from_use_TM_, path ]
        else
          NIL_AS_FAILURE_  # #cov1.2
        end
      end

      def dereference_template_variable__ sym

        send :"__template_value_for__#{ sym }__"
      end

      def __template_value_for__created_on__

        @created_on || ::Time.now.utc.to_s
      end

      # ==

      Actions = nil
      Here___ = self

      # ==
      # ==
    end

    # ==
  end
end
# #history-A.2: this used to be the core "graph" file, became the "use" action node.
# #history-A: ween off of [br]
