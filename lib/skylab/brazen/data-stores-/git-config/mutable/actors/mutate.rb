module Skylab::Brazen

  class Data_Stores_::Git_Config

    module Mutable

    module Actors

      class Mutate < Git_Config_Actor_

        Actor_[ self, :properties,
          :entity,
          :mutable_document
        ]

        def execute
          ok = resolve_properties
          ok &&= via_entity_resolve_subsection_identifier
          ok && edit_file
          @result
        end

      private

        def resolve_properties
          scn = @entity.to_normalized_actual_property_scan
          y = []
          while actual = scn.gets
            NAME_ == actual.name_i and next
            actual.value_x.nil? and next
            y.push actual
          end
          if y.length.zero?
            cannot_persist_entity_with_no_properties
          else
            @property_a = y
            PROCEDE_
          end
        end

        def cannot_persist_entity_with_no_properties
          send_not_OK_event_with :cannot_persist_entity_with_no_properties,
            :entity, @entity do |y, o|
              y << "cannot persist entity with no properties (#{ o.entity.class })"
          end
          @result = UNABLE_
        end

        def edit_file
          if @entity.came_from_persistence
            edit_file_via_update_section
          else
            edit_file_via_create_section
          end
        end

        def edit_file_via_create_section
          _a = @subsection_identifier.to_a
          @section = @mutable_document.sections.touch_section( * _a )
          if @section.is_empty
            edit_file_via_create_section_when_section_empty
          else
            edit_file_via_create_section_when_section_not_empty
          end
        end

        def edit_file_via_create_section_when_section_empty
          @verb_i = :created
          write_section
        end

        def edit_file_via_create_section_when_section_not_empty
          _s = @subsection_identifier.description
          send_not_OK_event_with :will_not_clobber_existing_entity,
            :entity_description, _s, :entity, @entity
          @result = UNABLE_
        end

        def edit_file_via_update_section
          @verb_i = :updated
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
          scn = @section.get_body_line_scanner
          y = [] ; x = nil ; y.push x while x = scn.gets ; y
        end

        def when_no_change_in_section
          _s = @subsection_identifier.description
          send_not_OK_event_with :no_change_in_entity,
            :entity_description, _s, :entity, @entity
          @result = UNABLE_
        end

        def write_section
          @property_a.each do |prop|
            @section[ prop.name_i ] = prop.value_x
          end
          @result = ACHEIVED_
        end

        def event_receiver
          @entity
        end
      end
    end
    end
  end
end
