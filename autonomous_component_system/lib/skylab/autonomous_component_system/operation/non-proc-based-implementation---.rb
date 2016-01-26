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

        _fo_bx = ___build_formals_box

        _o = ACS_::Parameter::Normalize.new arg_st, ss, _fo_bx

        _oes_p = pp[ ss.fetch( -2 ) ]  # VERY not sure what we want here

        sess = @_implementor_x.new( & _oes_p )

        _o.write_into sess  # throws otherwise

        _bc = Callback_::Bound_Call[ nil, sess, :execute ]

        Here_::Delivery_::Deliverable.new modz, ss, _bc
      end

      def ___build_formals_box

        _sym_a = @_pfoz.symbols

        op_h = @_pfoz.optionals_hash

        fo_bx = Callback_::Box.new

        _sym_a.each do |sym|

          _param = Home_::Parameter.new_by_ do
            @name_symbol = sym
            @parameter_arity = if op_h[ sym ]
              :zero_or_one
            else
              :one
            end
          end

          fo_bx.add sym, _param
        end
        fo_bx
      end
    end
  end
end
