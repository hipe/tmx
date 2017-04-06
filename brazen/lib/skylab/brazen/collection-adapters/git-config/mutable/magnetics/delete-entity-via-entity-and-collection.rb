module Skylab::Brazen

  class CollectionAdapters::GitConfig

    module Mutable

      class Magnetics::DeleteEntity_via_Entity_and_Collection < Common_::MagneticBySimpleModel

        # this is part of siblinghood of magnetics that is oriented towards
        # "entities" (that is, using config document as a store for business
        # entities). these magnets try to interface in the general terms of
        # business modeling (collections, entities) rather that the library-
        # specific concepts like document elements (e.g "sections") etc.
        #
        # however we needed a lower-level magnet to do the latter kind of
        # work and this file was looking pretty anemic so we have shoehorned
        # these new responsibilities into this one where once they crowded
        # the model nodes.
        #
        # as it turns out, it looks like the higher-level responsibilities
        # of this subject have become #disassociated from code anyway..

        # (once subclassed GitConfigMagnetic_)

        def will_delete_these_actual_instances a
          @__these_actual_instances = a
          @_execute = :__execute_in_batch_mode
        end

        attr_writer(
          :all_elements,
        )

        def execute
          send @_execute
        end

        if false
        Attributes_actor_.call( self,
          :entity,
          :document,
        )

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

          _compare_p = -> el do

            if el.is_section_or_subsection
              d = sect_s <=> el.internal_normal_name_string
              if d.nonzero? then d else
                subs_s <=> el.subsection_string
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

        end  # if false

        def __execute_in_batch_mode

          a = remove_instance_variable :@__these_actual_instances
          h = {}
          a.each do |el|
            h[ el.object_id ] = true
          end

          new_array = []
          will_have_deleted = []
          @all_elements.each do |el|
            _yes = h.delete el.object_id
            if _yes
              will_have_deleted.push el
            else
              new_array.push el
            end
          end

          if h.length.zero?
            @all_elements.replace new_array
            will_have_deleted.freeze
          else
            self._COVER_ME__did_not_find_some_of_these_items_in_the_collection__
          end
        end

        # ==
        # ==
      end
    end
  end
end
