module Skylab::Autonomous_Component_System

  class Singularize___

    class << self
      def _call * a
        new( * a ).execute
      end
      alias_method :[], :_call
      alias_method :call, :_call
    end  # >>

    def initialize sing_ca, plur_sym, plur_ca, acs
      @ACS = acs
      @plural_comp_assoc = plur_ca
      @plural_symbol = plur_sym
      @singular_comp_assoc = sing_ca
    end

    def execute

      pca = @plural_comp_assoc
      sca = @singular_comp_assoc

      pca.component_model = -> arg_st, & x_p do
        dup.___build_value arg_st, & x_p
      end

      nf = Callback_::Name.via_variegated_symbol @plural_symbol
      nf.as_ivar = sca.name.as_ivar
      pca.name = nf
      pca
    end

    def ___build_value arg_st, & x_p

      _x = arg_st.gets_one
      a = ::Array.try_convert _x
      if a
        ok_value_a = []
        ok = true
        a.each_with_index do | x, d |

          _st = Home_::Interpretation::Value_Popper[ x ]

          qk = Home_::Interpretation::Build_value.call(
            _st,
            @singular_comp_assoc,
            @ACS,
            & x_p )

          if qk
            ok_value_a.push qk.value_x
          else
            ok = false
            break
          end
        end
        if ok
          Callback_::Known_Known[ ok_value_a ]
        else
          # assume the callback was called
          ok
        end
      else
        self._COVER_ME_not_array
      end
    end
  end
end
