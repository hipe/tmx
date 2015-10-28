module Skylab::Brazen

  module Autonomous_Component_System

    module Interpretation

      Build_empty_child_bound_to_parent = -> asc, acs, & oes_p do

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

      Accepter_for = -> acs do

        # assign a *valid* value as an ivar after validation has succeeded.
        -> x, asc do
          acs.instance_variable_set asc.name.as_ivar, x
          NIL_
        end
      end

      UNDER_UNDER__ = '__'
    end
  end
end
