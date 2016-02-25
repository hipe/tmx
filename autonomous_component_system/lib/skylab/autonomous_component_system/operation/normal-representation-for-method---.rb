module Skylab::Autonomous_Component_System

  module Operation

    class NormalRepresentation_for_Method___

      # (code-notes in [#027])

      # this is *like* a #[#027] "normal representation" of a formal
      # operation, but read below.

      # implement what we now call "transitive operations" (in [#009]):
      #
      # operations like these are intended to implement collection-related
      # operations, like adding and removing items to collections.
      #
      # these operations always involve one receiver (what we now call
      # "the ACS"), one operation name, and probably one argument component
      # (the "deliveree"). (other arguments may be involved pursuant to
      # [#002]#Tenet7 modifiers.)
      #
      # for any given component there are zero or more operations for which
      # it is valid to pass that component as the "deliveree" to that
      # operation. for example components of association `frizbozz`
      # might be valid deliverees for `add_frizbozz` operations.
      #
      # we express this relationship from the component to the operation
      # with the `can` expression in the component association.
      #
      # unlike the more recently implemented "formal operations", these
      # operations themselves cannot have metadata associated with them.
      # as such, transitive operations are not fit for ismorphing to
      # user interfaces.
      #
      # #open [#012] is the idea of using formal operations to implement
      # these "transitive" operations too, allowing them to be as expressive
      # as the others (and hopefully simplfiying the whole library), SO
      # this node may be "temporary".

      def initialize qk
        @_single_argument_qk = qk
      end

      def deliverable_for_imperative_phrase_ ip

        args = []
        modz = ip.modz_
        ss = ip.selection_stack_

        if modz
          x = modz.using
          if x
            args.concat x
          end
        end

        args.push @_single_argument_qk

        oes_p = nil
        oes_p_p = -> xx do
          oes_p_p = -> _ do
            oes_p
          end
          oes_p = ip.call_handler_
          oes_p_p[ xx ]
        end

        _oes_p_p = -> x_ do
          oes_p_p[ x_ ]
        end

        _m = :"__#{ ss.fetch( -1 ).name.as_variegated_symbol }__component"

        _bc = Callback_::Bound_Call[
          args,
          ss.fetch( -2 ).ACS,  # receiver
          _m,
          & _oes_p_p
        ]

        Here_::Delivery_::Deliverable.new modz, ss, _bc
      end
    end
  end
end
