module Skylab::Brazen

  module Autonomous_Component_System

    module Interpretation  # notes in [#083]

      Accept_component_change = -> ev_p, acs, & oes_p do

        # mainly, store the new component value as a member value.
        # secondarily, emit an appropriate event.

        am = Component_Change___.via( & ev_p )

        asc = am.association
        cmp_ = am.new_component

        # the component doesn't need to know if it has actually been part
        # of the parent as a member or if it was just floating there

        wv = ACS_::Reflection::Wrapped_value_for[ asc, acs ]

        Accept_valid_value__[ cmp_, asc, acs ]  # init or change

        if wv
          oes_p.call :info, :component_changed do

            ACS_.event( :Component_Changed ).new_with(
              :current_component, cmp_,
              :previous_component, wv.value_x,
              :component_association, asc,
              :ACS, acs,
            )
          end
        else
          oes_p.call :info, :component_added do

            ACS_.event( :Component_Added ).new_with(
              :component, cmp_,
              :component_association, asc,
              :ACS, acs,
            )
          end
        end
        NIL_
      end

      Touch = -> asc, acs, & x_p do

        wv = ACS_::Reflection::Wrapped_value_for[ asc, acs ]
        if wv

          wv.value_x or self._COVER_ME  # nils may haunt us..

        else

          acs_ = Build_empty_child_bound_to_parent[ asc, acs, & x_p ]

          Accept_valid_value__[ acs_, asc, acs ]  # dat

          acs_
        end
      end

      Build_empty_child_bound_to_parent = -> asc, acs, & oes_p do

        # NOTE this does not assign the child to the parent, it only
        # creates a one-way dependency of child upon parent with the
        # eventing. more at #note-INTERP-A

        _st = Callback_::Polymorphic_Stream.the_empty_polymorphic_stream

        _special_oes_p = Component_handler[ acs, & oes_p ]

        cmp = asc.component_model.interpret_component _st, & _special_oes_p
        if cmp and cmp.respond_to? :accept_identity_via_component_association
          cmp.accept_identity_via_component_association asc
        end
        cmp
      end

      Component_handler = -> acs, & oes_p do

        -> * i_a, & ev_p do

          if :component == i_a.first
            acs.send :"__receive__#{ i_a * UNDER_UNDER___ }__", & ev_p
          else
            oes_p.call( * i_a, & ev_p )
          end
        end
      end

      # ~ experimental component signal API

      CONSTRUCT_STRUCT_VIA_YIELDS___ = -> & defn_p do
        mut = new
        _y = ::Enumerator::Yielder.new do | * x_a |
          x_a.each_slice 2 do | k, v |
            mut[ k ] = v
          end
        end
        defn_p[ _y ]
        mut
      end

      Component_Change___ = ::Struct.new(  # experimental...
        :new_component,
        :association,
      ) do
        class << self
          define_method :via, CONSTRUCT_STRUCT_VIA_YIELDS___
          private :[]
          private :new
        end  # >>
      end

      # ~ encapsulate the fragile assumption about ivars

      Accept_valid_value__ = -> x, asc, acs do

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

      UNDER_UNDER___ = '__'
    end
  end
end
