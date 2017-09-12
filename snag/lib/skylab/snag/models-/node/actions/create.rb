module Skylab::Snag

  class Models_::Node

    class Actions::Create

      def definition ; [

        :property, :downstream_reference,

        :required, :property, :upstream_reference,

        :required, :glob, :property, :message,

      ] end

      def initialize
        extend NodeRelatedMethods, ActionRelatedMethods_
        init_action_ yield
        @downstream_reference = nil  # [#026]
      end

      def execute
        if resolve_node_collection_
          __via_node_collection
        end
      end

      def __via_node_collection

        _cx = build_choices_by_ do |o|
          o._snag_downstream_reference_ = @downstream_reference
          o._snag_upstream_reference_ = @upstream_reference
        end

        _last_action = @_node_collection_.edit(
          :using, _cx,
          :add, :node,
            :append, :message, @message,
          & _listener_ )

        _last_action || NOTHING_  # [#007.C]
      end

      Actions = nil

      # ==
      # ==
    end
  end
end
# #history: for years this was a stowaway in what is now the "open" action
