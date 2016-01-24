module Skylab::Zerk::TestSupport

  class Fixture_Top_ACS_Classes::Class_22_Uggs

    def initialize
      @_nf = Callback_::Name.via_variegated_symbol :ugg
      @_oes_p = nil
    end

    def _recv_etc & p
      @_oes_p = p
    end

    attr_reader :_did_run_

    def __looks_like_proc_but_no_operations__component_association

      @_did_run_ = true

      -> x do
        self._this_is_never_run_
      end
    end

    def __shoestring_length__component_association

      yield :can, :abrufen, :stellen   # (german for 'get' and 'set' MAYBE)

      -> st, & oes_p do

        x = st.gets_one

        via_integer = -> d do
          # (more validation here .. etc)
          Callback_::Known_Known[ d ]
        end

        if x.respond_to? :bit_length
          via_integer[ x ]
        else
          md = /\A-?[0-9]+\z/.match x
          if md
            via_integer[ md[ 0 ].to_i ]
          else
            oes_p.call :error, :expression, :nope do | y |
              y << "doesn't look like integer: #{ x.inspect }"
            end
            false
          end
        end
      end
    end

    def __abrufen__primitivesque_component_operation_for qkn

      -> do

        if qkn.is_known_known
          if qkn.is_effectively_known
            [ :_was_known_huddaugh_, qkn.value_x ]
          else
            :_nilff_
          end
        else
          :_was_not_known_
        end
      end
    end

    def __stellen__primitivesque_component_operation_for qkn

      -> length do

        _vp = ACS_::Interpretation::Value_Popper[ length ]

        wv = qkn.association.component_model[ _vp, & @_oes_p ]
        if wv
          instance_variable_set qkn.name.as_ivar, wv.value_x
          :_you_did_it_
        else
          wv
        end
      end
    end
  end
end
