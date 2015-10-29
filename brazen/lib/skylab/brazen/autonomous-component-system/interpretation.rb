module Skylab::Brazen

  module Autonomous_Component_System

    module Interpretation

      Touch = -> asc, acs, & x_p do

        wv = ACS_::Reflection::Wrapped_value_for[ asc, acs ]
        if wv

          wv.value_x or self._COVER_ME  # nils may haunt us..

        else

          acs_ = Build_empty_child_bound_to_parent[ asc, acs, & x_p ]

          Accept_valid_value___[ acs_, asc, acs ]  # dat

          acs_
        end
      end

      Build_empty_child_bound_to_parent = -> asc, acs, & oes_p do  # 1

        # NOTE this does not assign the child to the parent, it only
        # creates a one-way dependency of child upon parent with the
        # eventing.

        _special_oes_p = -> * i_a, & ev_p do

          if :did == i_a.first
            acs.send :"__receive__#{ i_a * UNDER_UNDER__ }__", & ev_p

          else
            oes_p.call( * i_a, & ev_p )
          end
        end

        asc.component_model.interpret_component(
          Callback_::Polymorphic_Stream.the_empty_polymorphic_stream,
          & _special_oes_p )
      end

      # ~ encapsulate the fragile assumption about ivars

      Accept_valid_value___ = -> x, asc, acs do

        acs.instance_variable_set asc.name.as_ivar, x
        NIL_
      end

      Accepter_for = -> acs do

        -> x, asc do
          acs.instance_variable_set asc.name.as_ivar, x
          NIL_
        end
      end

      # ~

      UNDER_UNDER__ = '__'
    end
  end
end
