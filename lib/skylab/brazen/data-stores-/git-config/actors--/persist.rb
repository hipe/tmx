module Skylab::Brazen

  class Data_Stores_::Git_Config

    module Actors__

      class Persist < Git_Config_Actor_

        Actor_[ self, :properties,
          :entity,
          :collection,
          :kernel ]

        Entity_[]::Event::Merciless_Prefixing_Sender[ self ]

        def execute
          @to_path = @collection.to_path ; @collection = nil
          ok = prepare_values
          ok &&= resolve_document_for_write
          ok &&= edit_file
          ok and resolve_result_via_write_file @dry_run
          @result
        end

      private

        def prepare_values
          via_entity_init_action_properties
          instance_variable_defined?( :@dry_run ) or self._MISSING_ACTION_PROPERTY
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
          resolve_result_via_error :cannot_persist_entity_with_no_properties,
            :entity, @entity, :is_positive, false
          UNABLE_
        end

        def edit_file
          @ss = Construe_subsection__[ @entity ]
          if @entity.came_from_persistence
            edit_file_via_update_section
          else
            edit_file_via_create_section
          end
        end

        def edit_file_via_create_section
          @section = @document.sections.touch_section( * @ss.to_a )
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
          resolve_result_via_error_with :will_not_clobber_existing_entity,
            :entity_description, @ss.to_description_s, :entity, @entity
          UNABLE_
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
          resolve_result_via_error_with :no_change_in_entity,
            :entity_description, @ss.to_description_s, :entity, @entity
          UNABLE_
        end

        def write_section
          @property_a.each do |prop|
            @section[ prop.name_i ] = prop.value_x
          end
          ACHEIVED_
        end

        def listener
          @entity
        end
      end
    end
  end
end
