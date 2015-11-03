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

        if wv && ! wv.value_x
          wv.value_x.nil? or self._DESIGN_ME_issue_083_INTERP_B_when_falseish
          wv = nil
        end

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

        if wv && ! wv.value_x
          wv.value_x.nil? or self._DESIGN_ME_issue_083_INTERP_B_when_falseish
          wv = nil
        end

        if wv

          wv.value_x

        else

          acs_ = Build_empty_child_bound_to_parent[ asc, acs, & x_p ]

          Accept_valid_value__[ acs_, asc, acs ]  # dat

          acs_
        end
      end

      becbtpn = nil
      Build_empty_child_bound_to_parent = -> asc, acs, & acs_oes_p do

        wv = becbtpn[ asc, acs, & acs_oes_p ]
        if wv
          wv.value_x
        else
          wv
        end
      end

      becbtpn = -> asc, acs, & acs_oes_p do

        # ("build empty child bound to parent normally" ..)

        # (see instream comments - this does not assign child to parent)

        _st = Callback_::Polymorphic_Stream.the_empty_polymorphic_stream

        _cmp_oes_p = Component_handler[ acs, & acs_oes_p ]

        Build_component_normally[ _st, asc, acs, & _cmp_oes_p ]
      end

      class Build_component_normally

        # NOTE this results in a wrapped value, not the component itself!
        # (so that it looks the same whether it's the one or the other means)

        # the only purpose this node serves is to implement :t5 and :t6,
        # and the only node that knows of those tenets is this one.

        # this does not assign child to parent in any way, nor does it check
        # if there is already an existing child in any sort of parent member
        # "slot". if caller wants the child to have a one-way/passive/blind
        # connection to parent, it may do by passing an appropriate handler.

        class << self
          def _call st, asc, acs, & p
            new( st, asc, acs, & p ).execute
          end
          alias_method :[], :_call
          alias_method :call, :_call
        end  # >>

        def initialize st, asc, acs, & p
          @ACS = acs
          @argument_stream = st
          @association = asc
          @_oes_p = p
        end

        def execute
          @_model = @association.component_model
          if @_model.respond_to? :interpret_component
            __via_component_model
          else
            @_model[ @argument_stream, & @_oes_p ]
          end
        end

        def __via_component_model

          cmp = @_model.interpret_component @argument_stream, & @_oes_p
          if cmp

            ok = if cmp.respond_to? :initialize_component
              cmp.initialize_component @association, @ACS
            else
              true
            end

            if ok
              Value_Wrapper[ cmp ]
            else
              ok
            end
          else
            cmp
          end
        end
      end

      Component_handler = -> acs, & oes_p do

        oes_p or self._SANITY_no_handler_from_ACS?

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
