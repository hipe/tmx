module Skylab::Treemap

  class CLI < Tr_.lib_.brazen::CLI

    # desc "experiments with R."

    class << self

      def new * a

        new_top_invocation a, Tr_.application_kernel_
      end
    end  # >>

    def expression_agent_class

      Tr_.lib_.brazen::CLI.expression_agent_class
    end

    class Action_Adapter < Action_Adapter

      MUTATE_THESE_PROPERTIES = %i(
        stdin stdout stderr )

      def mutate__stdin__properties
        mutable_front_properties.remove :stdin
        NIL_
      end

      def mutate__stdout__properties
        mutable_front_properties.remove :stdout
        NIL_
      end

      def mutate__stderr__properties
        mutable_front_properties.remove :stderr
        NIL_
      end

      def via_bound_action_mutate_mutable_backbound_iambic x_a

        o = @resources
        bp = @back_properties

        if bp.has_name :stdin
          x_a.push :stdin, o.sin
        end

        if bp.has_name :stdout
          x_a.push :stdout, o.sout
        end

        if bp.has_name :stderr
          x_a.push :stderr, o.serr
        end

        ACHIEVED_
      end
    end
  end
end
