module Skylab::Brazen

  class Collection_Adapters::Git_Config

    module Mutable

    module Actors

      class Mutate < Git_Config_Actor_

        Attributes_actor_.call( self,
          :entity,
          :mutable_document
        )

        def execute
          ok = __look_at_entity
          ok &&= via_entity_resolve_subsection_id_via_entity_name @name_x
          ok && __produce_and_edit_section
          @result
        end

        def __look_at_entity

          # if there is only one formal property and the number of
          # actual properties is greater than one, ..

          __look_at_formals
          __resolve_pair_array
        end

        def __look_at_formals

          fo = @entity.formal_properties

          if 1 == fo.length
            @use_short_identity = true
          else
            @use_short_identity = false
          end
          nil
        end

        def __resolve_pair_array

          body_pair_a = []
          did_see_name = false
          st = @entity.to_pair_stream_for_persist

          while pair = st.gets
            if NAME_SYMBOL == pair.name_symbol
              did_see_name = true
              @name_x = pair.value_x
              next
            end
            pair.value_x.nil? and next
            body_pair_a.push pair
          end

          if did_see_name
            @body_pair_a = body_pair_a  # zero length ok
            ACHIEVED_

          elsif body_pair_a.length.zero?
            cannot_persist_entity_with_no_properties

          else
            self._CANNOT_persist_entity_with_no_name
          end
        end

        def cannot_persist_entity_with_no_properties
          maybe_send_event :error, :cannot_persist_entity_with_no_properties do
            bld_cannot_persist_entity_with_no_properties_event
          end
          @result = UNABLE_
        end

        def bld_cannot_persist_entity_with_no_properties_event
          build_not_OK_event_with :cannot_persist_entity_with_no_properties,
            :entity, @entity do |y, o|
              y << "cannot persist entity with no properties (#{ o.entity.class })"
          end
        end

        def __produce_and_edit_section
          if @use_short_identity && @body_pair_a.length.zero?
            __go_short
          else
            __go_long
          end
        end

        def __go_short

          h = {
            found_existing: :__go_short_when_existed,
            inserting_item: :__go_short_when_created }

          method = nil
          @section = @mutable_document.sections.touch_section_magnetic(
              @subsection_id.section_s ) do | * i_a |

            method = h.fetch i_a.fetch 1
            nil
          end

          @actual_s = "#{ @name_x }"

          send method
          __go_short_common_finish
        end

        def __go_short_when_created
          # @verb_symbol = :created
        end

        def __go_short_when_existed
          # @verb_symbol = :changed  # LOOK
        end

        def __go_short_common_finish
          @section.set_subsection_name @actual_s
          @result = ACHIEVED_
          nil
        end

        def __go_long
          if @entity.came_from_persistence
            __go_long_whereafter(
              inserting_item: :__go_long_update_when_created,
              found_existing: :__go_long_update_when_updated )
          else
            __go_long_whereafter(
              inserting_item: :__go_long_create_when_created,
              found_existing: :__go_long_create_when_updated )
          end
        end

        def __go_long_whereafter h

          method = nil

          @section = @mutable_document.sections.touch_section(
              * @subsection_id.to_a ) do | * i_a |

            method = h.fetch i_a.fetch 1
            nil
          end

          send method
        end

        def __go_long_create_when_created
          # @verb_symbol = :created
          _into_section_write
          ACHIEVED_
        end

        def __go_long_create_when_updated

          self._RIDE_ME

          s_a = _section_to_line_array
          @section.clear_section
          _into_section_write
          s_a_ = _section_to_line_array

          if s_a == s_a_
            when_no_change_in_section
          else
            # @verb_symbol = :updated
            ACHIEVED_
          end
        end

        def _section_to_line_array
          @section.to_line_stream.to_a
        end

        def when_no_change_in_section
          maybe_send_event :error, :no_change_in_entity do
            bld_no_change_in_section_event
          end
          @result = UNABLE_
        end

        def bld_no_change_in_section_event
          _s = @subsection_id.description
          build_not_OK_event_with :no_change_in_entity,
            :entity_description, _s, :entity, @entity
        end

        def _into_section_write
          @body_pair_a.each do |pair|
            s = pair.name_symbol.to_s
            if s.include? UNDERSCORE_
              pair = pair.with_name_i s.gsub( UNDERSCORE_, DASH_ ).intern
            end
            @section[ pair.name_symbol ] = pair.value_x
          end
          @result = ACHIEVED_
        end

        def maybe_send_event * i_a, & ev_p

          @entity.receive_possible_event_via_channel i_a, & ev_p
        end
      end
    end
    end
  end
end
