module Skylab::Autonomous_Component_System

  # ->

    Model = ::Module.new

    Model::Via_mutable_module = -> xx do
      self._K_FUN_EASY
    end

    Model::Via_normalization = -> n11n do

      -> arg_st, & oes_p do

        _qkn = Callback_::Qualified_Knownness.via_value_and_symbol(
          arg_st.gets_one,
          :argument,
        )

        n11n.normalize_qualified_knownness _qkn do | * i_a, & ev_p |

          if oes_p
            oes_p[ * i_a, & ev_p ]
          else
            raise ev_p[].to_exception
          end
        end
      end
    end
  # -
end
