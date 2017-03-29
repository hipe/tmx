module Skylab::Brazen

  class Models_::Workspace

    class Actions::Status < Home_::Action

      # (incidentally a hotbed of event experimentation for #emission-as-result..)

      # <-
    edit_entity_class(

      :branch_description, -> y do
        y << "get status of a workspace"
      end,

      :inflect, :verb, 'determine',

      :promote_action,

      :after, :init,

      :description, -> y do

        prp = action_reflection.front_properties.fetch :max_num_dirs

        if prp.has_primitive_default
          _dflt = " (default: #{ ick prp.primitive_default_value })"
        end

        y << "how far up do we look?#{ _dflt }"
      end,

      :non_negative_integer,
      :default, '1',
      :property, :max_num_dirs,

      :flag, :property, :verbose,

      :property_object, COMMON_PROPERTIES_[ :config_filename ],

      :description, -> y do
        y << "the location of the workspace"
        y << "it's #{ highlight 'really' } neat"
      end,
      :required, :property, :path,
    )
    # ->

      def produce_result

        h = @argument_box.h_

        ws = silo_module.edit_entity @kernel, handle_event_selectively do | o |

          o.edit_with(
            :surrounding_path, h.fetch( :path ),
            :config_filename, h.fetch( :config_filename ),
          )
        end

        if ws
          @_workspace = ws
          ___via_workspace
        else
          ws
        end
      end

      def ___via_workspace

        em = nil

        # experimental pattern: "the slot" is a conceptual buffer of only one
        # item. it always contains the most recently received emission. when
        # each new emission arrives, if the slot is occupied (which will be
        # the case for every reception but the first), that cached emission
        # is emitted at that moment. (this is the only way that emissions are
        # emitted.) if an emission is in the slot when the method finishes
        # (which willl be the case if we received more than zero emissions),
        # that emission serves at the result for the method call.

        emit_emission = -> do
          x = em ; em = nil
          @on_event_selectively.call( * x.category, & x.emission_value_proc )
          UNRELIABLE_
        end

        push = -> i_a, & ev_p do
          em && emit_emission[]
          em = Common_::Emission.via_category i_a, & ev_p
          NIL_
        end

        _oes_p = -> * i_a, & ev_p do

          # whether this is the final or an intermediate emission ..

          if :resource_not_found == i_a.last
            ___mollify push, i_a, & ev_p
          else
            push[ i_a, & ev_p ]
          end
          UNRELIABLE_
        end

        _ok = @_workspace.resolve_nearest_existent_surrounding_path(
          @argument_box.fetch( :max_num_dirs ),
          :prop, formal_properties.fetch( :path ),
          & _oes_p )

        if _ok
          em && emit_emission[]
          __when_found

        elsif em
          __wrap em
        end
      end

      def ___mollify push, i_a, & ev_p

        # change the semantic weight of these events from the performer -
        # when it is a status inquiry, this case is not a failure.

        i_a[ 0 ] = :info

        push.call i_a do
          _original_event = ev_p[]
          _ = _original_event.new_with :ok, ACHIEVED_
          _
        end
      end

      def __wrap em

        # to be able to pass off emissions as result values, in our case
        # it might need access to our own expag so it has to be self-
        # expressive ..

        Common_::Emission.via_category em.category do

          @on_event_selectively[ * em.category, & em.emission_value_proc ]

          NIL_  # important
        end
      end

      def __when_found

        Common_::Emission.of :info, :resource_existed do
          ___build_event
        end
      end

      def ___build_event

        _ev = build_OK_event_with(
          :resource_existed,
          :config_path, @_workspace.existent_config_path,
          :is_completion, true,

        ) do | y, o |
          y << "resource exists - #{ pth o.config_path }"
        end

        _ev
      end
    end
  end
end
