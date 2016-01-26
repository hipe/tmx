module Skylab::Autonomous_Component_System

  module Operation

    class Proc_based_Implementation___

      def initialize p, fo
        @formal = fo
        @_p = p
      end

      def produce_deliverable_ dreq

        ss, modz, arg_st, pp = dreq.to_a

        fo_bx = ( @_formals_box ||= ___build_box )

        o = Home_::Parameter::Normalize.new arg_st, ss, fo_bx

        if 1 == fo_bx.length

          # having only one formal argument is a special case: for these
          # (for now) we do NOT support the use of named argument(s).

          o.current_symbol = fo_bx.at_position( 0 ).name_symbol
        end

        _args = o.to_flat_platform_arguments

        _bc = Callback_::Bound_Call[ _args, @_p, :call, & pp ]

        Here_::Delivery_::Deliverable.new modz, ss, _bc
      end

      def ___build_box
        ACS_::Parameter::Box_via_platform_params_and_metadata[
          @_p.parameters,
          @formal,
        ]
      end
    end
  end
end
