module Skylab::Brazen

  module Autonomous_Component_System

    module Interpretation  # notes in [#083]

      Accept_component_change = -> acs, asc, change_p do  # [mt] ONLY

        # required reading: #INTERP-accept-component-change

        # make a note of any exisiting value before we replace it

        orig_qkn = ACS_::Reflection_::Read[ asc, acs ]

        # what is the new value we are chaning the component to?

        new_component = Change___.via( & change_p ).new_component

        # (we assume A) that we are #ASSUMPTION-A not long-running, and that
        # B) in the typical request, at most one component will change (per
        # ACS, and in general). if one or more of A, B is not true, probably
        # the client should make kind of component change writer..)

        ACS_::Interpretation_::Write_value[ new_component, asc, acs ]  # guaranteed

        # (see "epilogue":)

        if orig_qkn.is_effectively_known  # #INOUT-A, #INOUT-B

          _mutation_p = -> y do
            y.yield :info_channel, [ :info, :component_changed ]
            y.yield :event_class, ACS_.event( :Component_Changed )
            y.yield :event_members,
              :current_component, new_component,
              :previous_component, orig_qkn.value_x,
              :component_association, asc,
              :ACS, acs
          end
        else

          _mutation_p = -> y do
            y.yield :info_channel, [ :info, :component_added ]
            y.yield :event_class, ACS_.event( :Component_Added )
            y.yield :event_members,
              :component, new_component,
              :component_association, asc,
              :ACS, acs
          end
        end

        -> do
          Mutation___.via( & _mutation_p )
        end
      end

      # ~ experimental component signal API

      Component_handler = -> asc, acs, & oes_p do

        oes_p or self._SANITY_no_handler_from_ACS?

        -> * i_a, & ev_p do

          if :component == i_a.first
            acs.send :"receive__#{ i_a * UNDER_UNDER___ }__", asc, & ev_p
          else
            oes_p.call( * i_a, & ev_p )
          end
        end
      end

      CONSTRUCT_STRUCT_VIA_PAIRS___ = -> & defn_p do
        mut = new
        _y = ::Enumerator::Yielder.new do | * x_a |
          x_a.each_slice 2 do | k, v |
            mut[ k ] = v
          end
        end
        defn_p[ _y ]
        mut
      end

      Change___ = ::Struct.new(  # experimental...
        :new_component,
      ) do
        define_singleton_method :via, CONSTRUCT_STRUCT_VIA_PAIRS___
      end

      class Mutation___

        # a "proto event" experiment - maybe mutable ..

        attr_accessor(
          :info_channel,
          :event_class,
          :event_members,
        )

        def self.via & defn_p
          shell = self::Shell___.new self
          _y = ::Enumerator::Yielder.new do | sym, * x_a |
            shell.__send__ sym, * x_a
          end
          defn_p[ _y ]
          shell.flush
        end

        def to_event

          @event_class.new_via_each_pairable @event_members
        end

        def flush_to_mutation_with_context__ higher_x  # see [#bs-028] `flush_to_`

          # add an item of context to the context chain. if this mutation
          # hasn't been made already, this replaces the original "component
          # association" structure with a name function (that can be chained)

          _lower_x = @event_members.fetch :component_association

          _lower_name = _lower_x.name

          _higher_name = higher_x.name

          _new_name = _higher_name.to_linked_list_node_in_front_of _lower_name

          @event_members.replace :component_association, _new_name

          self
        end
      end

      class Mutation___::Shell___ < ::BasicObject

        def initialize cls
          @_cls = cls
        end

        class << self

          def single m
            define_method m do | x |
              ( @_x ||= @_cls.new ).send :"#{ m }=", x ; nil
            end
          end
        end  # >>

        def mutable_struct x
          @_x = x ; nil
        end

        single :info_channel
        single :event_class

        def event_members * x_a
          o = ( @_x ||= @_cls.new )
          o.event_members and self._NO
          bx = Callback_::Box.new
          o.event_members = bx
          x_a.each_slice 2 do | k, v |
            bx.add k, v
          end
          NIL_
        end

        def flush
          @_x
        end
      end

      # ~

      UNDER_UNDER___ = '__'
    end
  end
end
