module Skylab::TanMan

  class Models_::Association

    class Actions::Rm

      def definition

        _these = Home_::DocumentMagnetics_::CommonAssociations.all_

        [
          :property, :from_node_label,

          :property, :to_node_label,

          :properties, _these,
          :flag, :property, :dry_run,
        ]
      end

      def initialize
        extend Home_::Model_::CommonActionMethods
        init_action_ yield
        @_associations_ = {}  # read about magic [#xxx]
      end

      def _accept_association_ asc
        @_associations_[ asc.name_symbol ] = asc
      end

      def execute
        with_mutable_digraph_ do
          __via_mutable_digraph
        end
      end

      def __via_mutable_digraph

        _guy = AssocOperatorBranchFacade_.new @_mutable_digraph_

        ent = _guy.procure_remove_association__(
          [ remove_instance_variable( :@from_node_label ),
            remove_instance_variable( :@to_node_label ),
          ],
          & _listener_ )

        if ent
          ent.HELLO_ASSOCIATION
          ent
        else
          NIL_AS_FAILURE_
        end
      end

      # ==
      # ==
    end
  end
end
# #history: abstracted from core silo file, full rewrite
