module Skylab::Treemap

  class CLI < Home_.lib_.brazen::CLI

    # desc "experiments with R."

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

      def prepare_backstream_call x_a

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
