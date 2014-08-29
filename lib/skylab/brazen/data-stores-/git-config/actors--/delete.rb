module Skylab::Brazen

  class Data_Stores_::Git_Config

    class Actors__::Delete < Git_Config_Actor_

      Actor_[ self, :properties,
        :action, :collection ]

      def execute
        init_ivars
        ok = false
        ok = resolve_document_for_write
        ok &&= via_document_and_ss_resolve_entity
        ok &&= delete_section_from_document
        ok and resolve_result_via_write_file @action.action_property_value :dry_run
        # 'ok' might be the number of remaining sections,
        # @result might be the number of bytes written to the file
        ok ? @entity : @result
      end

    private

      def init_ivars
        @class = @action.class.model_class
        @dry_run = @action.action_property_value :dry_run
        @name_x = @action.action_property_value :name
        @to_path = @collection.to_path
        @ss = via_name_and_class_build_subsection_locator
        @verb_i = :deleted
      end

      def delete_section_from_document
        sect_s = @ss.section_s
        subs_s = @ss.subsection_s or self._TEST_ME
        _compare_p = -> item do
          d = sect_s <=> item.normalized_name_s
          if d.nonzero? then d else
            subs_s <=> item.subsect_name_s
          end
        end
        @document.sections.delete_comparable_item @ss, _compare_p, -> ev do
          resolve_result_via_error ev
          UNABLE_
        end
      end

      def listener
        @action
      end
    end
  end
end
