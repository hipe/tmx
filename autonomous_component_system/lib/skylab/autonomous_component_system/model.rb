module Skylab::Autonomous_Component_System

  # ->

    Model = ::Module.new

    Model::Via_mutable_module = -> xx do
      self._K_FUN_EASY
    end

    Model::Via_normalization = -> n11n do

      -> arg_st, & oes_p_p do

        # interesting conundrum .. we see it as outside of the model's
        # scope to have to know the name etc for the thing it's validating
        # (experimentally)..

        _oes_p = oes_p_p[ nil ]  # there is no entity to link up with

        _kn = Common_::KnownKnown[ arg_st.gets_one ]

        _x = n11n.normalize_knownness _kn do | * i_a, & ev_p |

          # (hi.)
          _oes_p[ * i_a, & ev_p ]
        end

        _x
      end
    end
  # -
end
