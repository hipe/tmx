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

      class GenericEntityForReference_

        def initialize node_name_string
          @_s = node_name_string
        end

        def node_name_string__
          @_s
        end

        def lookup_value_softly_ _
          NOTHING_
        end
      end

      def __via_mutable_digraph

        _hi = GenericEntityForReference_.new @node_name

        _ok = Here_::Magnetics::Create_or_Touch_or_Delete_via_Node_and_Collection.call_by do |o|

          o.entity = _hi
          o.document = @_mutable_digraph_
          o.verb_lemma_symbol = :delete
          o.listener = _listener_
        end

        _ok || NIL_AS_FAILURE_
      end

      # ==
      # ==
    end
  end
end
# #history: broke out of main model file (and full rewrite)
