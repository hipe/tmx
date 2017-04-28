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
        @_associations_ = {}
      end

      def _accept_association_ asc
        @_associations_[ asc.name_symbol ] = asc
      end

      def execute

        sct = with_mutable_digraph_ do
          __money
        end

        sct && sct.user_value
      end

      def __money

        _ = Here_::Magnetics_::Create_or_Retrieve_or_Touch_via_NodeName_and_Collection.call_by do |o|
          o.name_string = @node_name
          o.entity_via_created_element_by = method :__entity_via_node_statement
          o.top_channel_for_created_symbol = :success  # not `info`
          o.verb_lemma_symbol = :create
          o.document = @_mutable_digraph_
          o.listener = _listener_
        end
        _ || NIL_AS_FAILURE_
      end

      def __entity_via_node_statement node_stmt
        Here_.new_flyweight_.reinit_as_flyweight_ node_stmt  # meh..
      end

      # ==
      # ==
    end
  end
end
# #history-A: broke out of main model file (and full rewrite)
