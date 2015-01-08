module Skylab::Brazen

  class Data_Stores_::Git_Config

    module Mutable

    module Actors

      class Mutate < Git_Config_Actor_

        Actor_.call self, :properties,
          :entity,
          :mutable_document,
          :on_event_selectively

        def execute
          ok = resolve_properties
          ok &&= via_entity_resolve_subsection_id_via_entity_name @name_x
          ok && edit_file
          @result
        end

      private

        def resolve_properties
          scn = @entity.to_normalized_actual_property_scan_for_persist
          body_pair_a = []
          did_see_name = false
          while pair = scn.gets
            if NAME_ == pair.name_symbol
              did_see_name = true
              @name_x = pair.value_x
              next
            end
            pair.value_x.nil? and next
            body_pair_a.push pair
          end
          if did_see_name
            @body_pair_a = body_pair_a  # zero length ok
            PROCEDE_
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

        def edit_file
          if @entity.came_from_persistence
            edit_file_via_update_section
          else
            edit_file_via_create_section
          end
        end

        def edit_file_via_create_section
          _a = @subsection_id.to_a
          @section = @mutable_document.sections.touch_section( * _a )
          if @section.is_empty
            edit_file_via_create_section_when_section_empty
          else
            edit_file_via_create_section_when_section_not_empty
          end
        end

        def edit_file_via_create_section_when_section_empty
          @verb_symbol = :created
          write_section
        end

        def edit_file_via_create_section_when_section_not_empty
          maybe_send_event :error, :will_not_clobber_existing_entity do
            bld_will_not_clobber_existing_entity_event
          end
          @result = UNABLE_
        end

        def bld_will_not_clobber_existing_entity_event
          _s = @subsection_id.description
          build_not_OK_event_with :will_not_clobber_existing_entity,
            :entity_description, _s, :entity, @entity
        end

        def edit_file_via_update_section
          @verb_symbol = :updated
          y = get_section_body_lines
          @section.clear_section
          write_section
          y_ = get_section_body_lines
          if y == y_
            when_no_change_in_section
          else
            write_section
          end
        end

        def get_section_body_lines
          scn = @section.get_body_line_stream
          y = [] ; x = nil ; y.push x while x = scn.gets ; y
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

        def write_section
          @body_pair_a.each do |pair|
            s = pair.name_symbol.to_s
            if s.include? UNDERSCORE_
              pair = pair.with_name_i s.gsub( UNDERSCORE_, DASH_ ).intern
            end
            @section[ pair.name_i ] = pair.value_x
          end
          @result = ACHIEVED_
        end

        def maybe_send_event * i_a, & ev_p
          @entity.maybe_receive_event_via_channel i_a, & ev_p
        end
      end
    end
    end
  end
end
