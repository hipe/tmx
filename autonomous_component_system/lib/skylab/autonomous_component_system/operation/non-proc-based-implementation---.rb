module Skylab::Autonomous_Component_System

  module Operation

    class NonProc_based_Implementation___

      def initialize pfoz, x, fo
        @formal = fo
        @_implementor_x = x
        @_pfoz = pfoz
      end

      def produce_deliverable_ dreq

        ss, modz, arg_st, pp = dreq.to_a

        _fo_st = ___build_formals_stream

        o = Home_::Parameter::Normalize.new ss, _fo_st

        p = @formal.parameters_from_proc_
        if p
          o.parameters_value_reader = p.call
        else
          o.argument_stream = arg_st
        end

        _receiver = ss.fetch( -2 )
        _oes_p = pp[ _receiver ]  # TOTALLY up in the air, but look OK .. #at [#010]
        sess = @_implementor_x.new( & _oes_p )

        ok = o.write_into sess  # usu just throws, but might change [#028]#A

        if ok
          _bc = Callback_::Bound_Call[ nil, sess, :execute ]
          Here_::Delivery_::Deliverable.new modz, ss, _bc
        else
          ok
        end
      end

      def ___build_formals_stream

        # (if your parameters include a false-ish key, shame on you)

        op_h = @_pfoz.optionals_hash

        Callback_::Stream.via_nonsparse_array( @_pfoz.symbols ).map_by do |sym|

          Home_::Parameter.new_by_ do
            @name_symbol = sym
            @parameter_arity = if op_h[ sym ]
              :zero_or_one
            else
              :one
            end
          end
        end
      end

      def moduleish
        @_implementor_x
      end
    end
  end
end
