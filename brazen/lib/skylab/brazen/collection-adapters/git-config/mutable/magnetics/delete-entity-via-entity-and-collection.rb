module Skylab::Brazen

  module CollectionAdapters::GitConfig

    module Mutable

      class Magnetics::DeleteEntity_via_Entity_and_Collection < Common_::MagneticBySimpleModel  # 2x

        # for consistency this magnetic renames as named, but you will
        # note that really it's more of a specialized, low-level helper.

        # although this is currently "anemic"; it feels a little awkward
        # pushing it up so we have left it as-is.

        def will_delete_these_actual_instances a
          @__these_actual_instances = a ; nil
        end

        attr_writer(
          :all_elements,
        )

        def execute

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
      end
    end
  end
end
# :#history-A: simplified away a lot
