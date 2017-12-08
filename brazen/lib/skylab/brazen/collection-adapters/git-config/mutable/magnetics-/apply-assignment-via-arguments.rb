module Skylab::Brazen

  module CollectionAdapters::GitConfig

    module Mutable

      class Magnetics_::ApplyAssignment_via_Arguments < Common_::MagneticBySimpleModel

        def initialize
          @_mutex_for_position = nil
          @_via_new_assignment = nil
          @external_normal_name_symbol = nil
          super
        end

        def offset_of_assignment_to_change= d
          remove_instance_variable :@_mutex_for_position
          @_status = ACHIEVED_  # (because we aren't touching)
          @_via_new_assignment = :_maybe_change_existing
          @offset_of_assignment_to_change = d
        end

        def will_append
          remove_instance_variable :@_mutex_for_position
          @_via_new_assignment = :__via_new_assignment_append
        end

        attr_writer(
          :all_elements,
          :external_normal_name_symbol,
          :listener,
          :mixed_value,
        )

        def execute

          # assume that the subject is used to implement `[]=` as well as
          # other writers. new in this edition `[]=` may not emit emissions.
          # (no more "hot" models). for such calls we want to raise
          # exceptions when something is seriously wrong (a name or value
          # is invalid and cannot be stored in the document (without
          # corrupting it)) but we want to ignore informational emissions
          # (this name/value was inserted, this other one was replaced). so:

          @listener ||= LISTENER_THAT_RAISES_ALL_NON_INFO_EMISSIONS_

          if __resolve_new_assignment
            send( @_via_new_assignment || :__via_new_assignment_touch )
          end
        end

        def __via_new_assignment_touch
          @_status = __touch
          if @_status.did_add
            _when_added
          else
            __when_found_existing
          end
        end

        def __touch

          norm_s = @_new_assignment.internal_normal_name_string

          _comparator = -> el do
            if IS_ASSIGNMENT_.fetch el._category_symbol_
              el.internal_normal_name_string <=> norm_s
            else
              -1  # say "comes before" so you keep looking for one after
            end
          end

          _ = This_::Magnetics::
          TouchComparableElement_via_Element_and_Comparator_and_Elements.call_by do |o|
            o.element = @_new_assignment
            o.comparator = _comparator
            o.all_elements = @all_elements
          end
          _  # hi. #todo
        end

        def __via_new_assignment_append
          @_status = StatusAdded_.new true, @all_elements.length
          @all_elements.push @_new_assignment
          _when_added
        end

        def __resolve_new_assignment

          use_sym = @external_normal_name_symbol
          if ! use_sym
            # (snuck in here)
            @_existing_assignment = @all_elements.fetch @offset_of_assignment_to_change
            use_sym = @_existing_assignment.external_normal_name_symbol
          end

          _ = This_::Magnetics_::Assignment_via_DirectDefinition.call_by do |o|
            o.external_normal_name_symbol = use_sym
            o.mixed_value = @mixed_value
            o.listener = @listener
          end

          _store :@_new_assignment, _
        end

        # --

        def __when_found_existing

          @_existing_assignment = @_status.existing_element
          @offset_of_assignment_to_change = @_status.offset
          _maybe_change_existing
        end

        def _maybe_change_existing
          existing_x = @_existing_assignment.value
          _new_x = @_new_assignment.value
          if existing_x == _new_x
            __when_no_change
          else
            __big_slam existing_x
          end
        end

        def __big_slam prev_x  # #cov1.2

          # we used to do just this:
          #
          #     @_existing_assignment.value = new_x
          #
          # what we do instead below is the subject of [#008.G]

          n_d, n_w, v_d, v_w, fro_line = @_existing_assignment.to_string_math_five_
          ___, ___, vd2, vw2, froline2 = @_new_assignment.to_string_math_five_

          # assume that the two names match so there is no need to alter it.
          # rather, what we are doing is amazing in its terrible way:

          new_line = fro_line.dup
          new_line[ v_d, v_w ] = froline2[ vd2, vw2 ]

          # we lift those bytes of the string representatino of the new
          # value and splice them into (and over) the old bytes.

          # because "new assignment" was created for this operation (we
          # assume), it's OK to mutate it. keep in mind it has the correct
          # unmarshaled value too.

          @_new_assignment.accept_five_ n_d, n_w, vd2, vw2, new_line.freeze

          @all_elements[ @offset_of_assignment_to_change ] = @_new_assignment

          __when_changed prev_x
        end

        # --
        # -- events

        def __when_no_change
          @listener.call :info, :related_to_assignment_change, :no_change do
            __build_no_change_event
          end
          @_status
        end

        def __when_changed prev_x
          @listener.call :info, :related_to_assignment_change, :changed do
            __build_change_event prev_x
          end
          @_status
        end

        def _when_added
          @listener.call :info, :related_to_assignment_change, :added do
            __build_added_event
          end
          @_status
        end

        # ~

        def __build_no_change_event
          _ev = Common_::Event.inline_OK_with(
            :no_change_in_value,
            :existing_assignment, @_existing_assignment,
          )
          _ev  # hi. #todo
        end

        def __build_change_event prev_x
          _ev = Common_::Event.inline_OK_with(
            :value_changed,
            :existing_assignment, @_existing_assignment,
            :previous_value, prev_x,
          )
          _ev  # hi. #todo
        end

        def __build_added_event

          _ev = Common_::Event.inline_OK_with(
            :added_value,
            :new_assignment, @_new_assignment,
          )
          _ev  # hi. #todo
        end

        # (a "build deleted event" is here: #spot1.2)

        define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

        # ==
        # ==
      end
    end
  end
end
# #history-A: broke out of central "mutable" node (spiritually) during heavy refactor
