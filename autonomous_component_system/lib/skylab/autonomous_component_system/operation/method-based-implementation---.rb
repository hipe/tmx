module Skylab::Autonomous_Component_System

  module Operation

    class Method_based_Implementation___

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

      class << self

        def begin__ qk
          new.__initial_init_via qk
        end

        def __method_for_symbol sym
          :"__#{ sym }__component"
        end

        private :new
      end  # >>

      def __initial_init_via qk
        @_single_argument_qk = qk
        self
      end

      def deliverable_ dreq  # look like formal not an implemenation

        ss, modz, _, pp = dreq.to_a

        qk = @_single_argument_qk

        if modz
          using_ = modz.using
        end

        args = []
        if using_
          args.concat using_
        end
        args.push qk

        _receiver = ss.fetch( -2 ).value_x

        _method_name = Self_.__method_for_symbol(
          ss.fetch( -1 ).name.as_variegated_symbol )

        _bc = Callback_::Bound_Call[ args, _receiver, _method_name, & pp ]

        Here_::Delivery_::Deliverable.new modz, ss, _bc
      end

      Self_ = self
    end
  end
end
