module Skylab::Brazen

  module CollectionAdapters::GitConfig

    module Mutable

      class Magnetics::ReplaceEntity_via_Entity_and_Collection < Common_::MagneticBySimpleModel  # 1x, #stowaway

        # there is a list of assignments suggested by the argument stream
        # that (after successful execution) will constitute *all* of the
        # assignments in the entity (but not necessarily in the argument
        # order).
        #
        # the stream's each item is a [#co-004]-shaped name-value structure.
        # the value of each pair is the primitive (unencoded) value to use
        # in the assignment.
        #
        # consider the (any) assignments that already exist in the entity
        # before execution (specifically the names of these assignments):
        #
        #   - for those names in this set that are not in the argument set,
        #     their assignments will be removed from the entity.
        #
        #   - for those names that are *not* in the initial set but are in
        #     the argument set, these suggest assignments that will be
        #     added to the entity.
        #
        #   - for those names in both the initial set and the argument set,
        #     the values of these existing assignments will be changed.
        #
        # this is implemented in a manner intended to preserve whitespace,
        # comments and other formatting of existing elements wherever
        # possible (so for everything but when assignments are removed).
        #
        # (note there are possible gotchas here, depending on what your
        # comments say and where they are placed..)

        # (currently this is only #covered-by [cu], which covers its three
        # major branches in two tests :[#007.1].)

        def will_replace_with_these_name_value_pairs st
          @__these = st
        end

        attr_writer(
          :all_elements,
          :listener,
        )

        def execute

          __flush_new_assignments_to_hash
          __index_the_kerfluffles

          ok = true
          ok &&= _if_these_then_this :@__change_these, :__flush_changes  # must be first
          ok &&= _if_these_then_this :@__remove_these, :__flush_removes
          ok &&= _if_these_then_this :@__add_these, :__flush_adds
          ok
        end

        def _if_these_then_this ivar, m
          a = remove_instance_variable ivar
          if a
            send m, a
          else
            ACHIEVED_
          end
        end

        def __flush_changes offsets

          ok = true
          pairs = @_assignments_hash
          offsets.each do |d|

            _el = @all_elements.fetch d
            _pair = pairs.fetch _el.external_normal_name_symbol

            ok = _assign_by do |o|
              o.offset_of_assignment_to_change = d
              o.mixed_value = _pair.value
            end

            true == ok || self._COVER_ME__not_ok__
          end
          ok
        end

        def __flush_removes a

          a = Magnetics::DeleteEntity_via_Entity_and_Collection.call_by do |o|
            o.will_delete_these_actual_instances a
            o.all_elements = @all_elements
          end

          # (keep this close to #spot1.2)

          a.each do |asmt|  # for eg..

            @listener.call :info, :related_to_assignment_change, :removed do

              Common_::Event.inline_OK_with(
                :removed,
                :removed_assignment, asmt,
              )
            end
          end

          ACHIEVED_
        end

        def __flush_adds a

          ok = true
          pairs = @_assignments_hash
          a.each do |sym|
            _x = pairs.fetch( sym ).value
            ok = _assign_by do |o|
              o.external_normal_name_symbol = sym
              o.mixed_value = _x
            end
            ok || break
          end
          ok
        end

        def _assign_by
          Mutable::Magnetics_::ApplyAssignment_via_Arguments.call_by do |o|
            yield o
            o.all_elements = @all_elements
            o.listener = @listener
          end
        end

        def __index_the_kerfluffles

          change_these_assignments = nil
          remove_these_assignments = nil

          pool = remove_instance_variable :@__pool

          @all_elements.each_with_index do |el, d|
            el.is_assignment || next
            k = el.external_normal_name_symbol
            if pool.delete k
              ( change_these_assignments ||= [] ).push d
            else
              ( remove_these_assignments ||= [] ).push el
            end
          end

          if pool.length.nonzero?
            add_these_assignments = pool.keys
          end

          @__add_these = add_these_assignments
          @__change_these = change_these_assignments
          @__remove_these = remove_these_assignments
          NIL
        end

        def __flush_new_assignments_to_hash

          bx = Common_::Box.new
          pool = {}
          st = remove_instance_variable :@__these
          begin
            pair = st.gets
            pair || break
            k = pair.name_symbol
            pool[ k ] = true
            bx.add k, pair  # keep it wrapped
            redo
          end while above
          @__pool = pool
          @_assignments_hash = bx.h_ ; nil
        end
      end

      class Magnetics::DeleteEntity_via_Entity_and_Collection < Common_::MagneticBySimpleModel  # 2x

        # for consistency this magnetic renames as named, but you will
        # note that really it's more of a specialized, low-level helper.

        # although this is currently "anemic"; it feels a little awkward
        # pushing it up so we have left it as-is.
        # (now it has a stowaway to keep it company)

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
# :#history-A.2: spike "replace entity" (abstracted from another sidesystem)
# :#history-A: simplified away a lot
