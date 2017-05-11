module Skylab::TanMan

  class Models_::Association

    class Actions::Add

      def definition

        _these = Home_::DocumentMagnetics_::CommonAssociations.all_
        [
          :required,
          :property, :from_node_label,

          :required,
          :property, :to_node_label,

          :property, :attrs,  # probably you should mask this out #masking
          :property, :prototype,  # probably you own the responsibility to make this a symbol #masking

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
        with_mutable_digraph_ do
          __via_mutable_digraph
        end
      end

      def __via_mutable_digraph

        h = @attrs
        if h
          h.respond_to? :each_pair or self._SANITY
          _attrs = h
        end

        sym = @prototype
        if sym
          sym.respond_to? :id2name or self._SANITY
          _prototype_name_symbol = sym
        end

        _guy = AssocOperatorBranchFacade_TM.new @_mutable_digraph_

        ent = _guy.touch_association_by_ do |o|

          o.attrs = _attrs
          o.prototype_name_symbol = _prototype_name_symbol

          o.from_and_to_labels(
            remove_instance_variable( :@from_node_label ),
            remove_instance_variable( :@to_node_label ),
          )

          o.listener = _listener_
        end

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
