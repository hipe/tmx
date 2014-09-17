module Skylab::Brazen

  class Data_Stores_::Git_Config

    Git_Config_::Actors__.class

    module Mutable

      Actors = ::Module.new

      class Actors::Delete < Git_Config_Actor_

        Actor_[ self, :properties,
          :entity,
          :document,
          :event_receiver ]

        def execute
          ok = via_entity_resolve_subsection_identifier
          ok &&= via_subsection_identifier_resolve_section
          ok &&= via_section_delete_section
          ok
        end

        def resolve_subsection_identifier
          via_model_class_resolve_section_string
          ok = via_bx_resolve_subsection_string
          ok && via_both_strings_resolve_subsection_identifier
        end

        def via_bx_resolve_subsection_string
          s = @bx.fetch NAME_
          if s
            s = s.strip  # b.c it has been frozen in the past
            if s.length.nonzero?
              @subsection_string = s
              PROCEDE_
            end
          end
        end

        def via_section_delete_section
          ss = @subsection_identifier
          sect_s, subs_s = ss.to_a
          _compare_p = -> item do
            d = sect_s <=> item.normalized_name_s
            if d.nonzero? then d else
              subs_s <=> item.subsect_name_s
            end
          end
          @document.sections.delete_comparable_item ss, _compare_p, -> ev do
            send_event ev
            UNABLE_
          end
        end
      end
    end
  end
end
