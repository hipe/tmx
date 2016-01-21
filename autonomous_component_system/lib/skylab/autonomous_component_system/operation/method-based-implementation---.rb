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
          new.__initial_init_via( qk )
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

      def deliverable_via_selecting_session o
        Build_deliverable___.new( @_single_argument_qk, o ).execute
      end

      class Build_deliverable___

        def initialize qk, o

          # what argument(s) we pass will change for #open [#012]:

          @modz_ = o.modz_
          @selection_stack = o.selection_stack
          @pp_ = o.pp_
          @_qk = qk
        end

        def execute

          _args = ___build_args

          a = @selection_stack

          _receiver = a.fetch( -2 ).value_x

          _method_name = Self_.__method_for_symbol(
            a.fetch( -1 ).as_variegated_symbol )

          # ~

          Here_::Delivery_::Deliverable.new(
            @selection_stack,
            @modz_,
            _args,
            _receiver,
            _method_name,
            & @pp_ )
        end

        def ___build_args

          a = []

          if @modz_
            using_ = @modz_.using
            if using_
              a.concat using_
            end
          end

          a.push @_qk.value_x, @_qk.association

          a
        end
      end

      Self_ = self
    end
  end
end
