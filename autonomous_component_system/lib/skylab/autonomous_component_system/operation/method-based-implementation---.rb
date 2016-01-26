module Skylab::Autonomous_Component_System

  module Operation

    class Method_based_Implementation___  # #open :[#012]

      # implement what we now call "transitive operations" (in [#009]):
      #
      # operations like these are intended to implement collection-related
      # operations, like adding and removing items to collections.
      #
      # these operations always involve one receiver (what we now call
      # "the ACS"), one operation name, and probably one argument component
      # (the "deliveree"). (other arguments may be involved pursuant to
      # [#002]#Tenet8 modifiers.)
      #
      # component associations express the set of operations for which those
      # components are valid to be the "deliveree" with the `can` expression.
      #
      # this earliest still-standing incarnation of operation does not
      # support the expression of metadata for the operation as does the
      # newer "formal operation". as such, operations like these are not fit
      # for isomorphing to interfaces.
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
        args.push qk.value_x, qk.association

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
