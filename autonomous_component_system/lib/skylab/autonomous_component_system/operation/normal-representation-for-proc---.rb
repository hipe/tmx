module Skylab::Autonomous_Component_System

  module Operation

    class Proc_based_Implementation___

      def initialize p, fo
        @formal = fo
        @_p = p
      end

      def produce_deliverable_ dreq

        ss, modz, arg_st, pp = dreq.to_a

        _fo_st = ___build_formals_stream

        o = Home_::Parameter::Normalize.new ss, _fo_st
        p = @formal.parameters_from_proc_
        if p
          self._NEVER_BEEN_NEEDED
        end

        o.argument_stream = arg_st

        args = o.to_flat_platform_arglist  # usu throws but might change [#028]#A

        if args
          _bc = Callback_::Bound_Call[ args, @_p, :call, & pp ]
          Here_::Delivery_::Deliverable.new modz, ss, _bc
        else
          args
        end
      end

      def ___build_formals_stream
        ACS_::Parameter::
          Formal_Parameter_Stream_via_Platform_Parameters_and_Formal_Operation[
          @_p.parameters,
          @formal,
        ]
      end
    end
  end
end
