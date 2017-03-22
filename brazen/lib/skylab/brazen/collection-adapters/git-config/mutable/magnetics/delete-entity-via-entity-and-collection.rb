module Skylab::Brazen

  class Collection_Adapters::Git_Config

    Git_Config_::Actors__.class

    module Mutable

      Actors = ::Module.new

      class Actors::Delete < Git_Config_Actor_

        Attributes_actor_.call( self,
          :entity,
          :document,
        )

        def initialize & oes_p
          @on_event_selectively = oes_p
        end

        def execute
          ok = via_entity_resolve_subsection_id__
          ok &&= via_subsection_id_resolve_section_
          ok &&= __via_section_delete_section
          ok
        end

        def resolve_subsection_id
          via_model_class_resolve_section_string
          ok = __via_bx_resolve_subsection_string
          ok && via_both_strings_resolve_subsection_id_
        end

        def __via_bx_resolve_subsection_string
          s = @bx.fetch NAME_SYMBOL
          if s
            s = s.strip  # b.c it has been frozen in the past
            if s.length.nonzero?
              @subsection_s = s
              ACHIEVED_
            end
          end
        end

        def __via_section_delete_section
          ss = @subsection_id
          subs_s, sect_s = ss.to_a
          _compare_p = -> item do
            if :section_or_subsection == item.category_symbol
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
