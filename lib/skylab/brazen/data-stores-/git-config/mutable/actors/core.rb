module Skylab::Brazen

  class Data_Stores_::Git_Config

    Git_Config_::Actors__.class

    module Mutable

      Actors = ::Module.new

      class Actors::Delete < Git_Config_Actor_

        Actor_[ self, :properties,
          :entity,
          :document,
          :on_event_selectively ]

        def execute
          ok = via_entity_resolve_subsection_id
          ok &&= via_subsection_id_resolve_section
          ok &&= via_section_delete_section
          ok
        end

        def resolve_subsection_id
          via_model_class_resolve_section_string
          ok = via_bx_resolve_subsection_string
          ok && via_both_strings_resolve_subsection_id
        end

        def via_bx_resolve_subsection_string
          s = @bx.fetch NAME_
          if s
            s = s.strip  # b.c it has been frozen in the past
            if s.length.nonzero?
              @subsection_s = s
              PROCEDE_
            end
          end
        end

        def via_section_delete_section
          ss = @subsection_id
          subs_s, sect_s = ss.to_a
          _compare_p = -> item do
            if :section_or_subsection == item.symbol_i
              d = sect_s <=> item.internal_normal_name_string
              if d.nonzero? then d else
                subs_s <=> item.subsect_name_s
              end
            else
              -1
            end
          end
          @document.sections.delete_comparable_item ss, _compare_p do |*i_a, & ev_p|
            maybe_send_event_via_channel i_a, & ev_p
            _OK_value_via_top_channel i_a.first
          end
        end
      end
    end
  end
end
