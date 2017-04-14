module Skylab::Brazen

  module CollectionAdapters::GitConfig

    class Mutable::Magnetics::PersistEntity_via_Entity_and_Collection < Common_::MagneticBySimpleModel

      # (the general algorithm here is outined in the test file: #cov2.3)

      # batch updating is not an interesting problem to us at the moment
      # so this assumes that we are updating only one entity per model
      # per invocation (and so we make the "diminshing pool" anew)

      def be_update_not_create
        @_execute = :__execute_via_update ; nil
      end

      def be_create_not_update
        @_execute = :__execute_via_create ; nil
      end

      attr_writer(
        :entity,
        :facade,
        :persist_these,
        :listener,
      )

      def execute

        # touch the mutable document before indexing the elements to delete

        _x = @facade.entity_collection.with_mutable_document ( nil && @listener ) do
          send @_execute
        end
        _x  # hi. #todo
      end

      def __execute_via_update

        if __resolve_corresponding_section_for_update

          __make_a_diminishing_pool_of_the_list_of_persistent_attributes

          __for_every_assignment_in_that_section do

            if __the_assignment_is_not_in_the_list
              __add_this_to_a_list_of_unrecognized_assignments

            else
              __remove_the_corresponding_name_from_the_diminishing_pool

              if __the_assignment_is_effectively_nil_in_the_entity
                __add_this_to_the_list_of_assignments_to_remove

              else
                __add_this_to_the_list_of_assignments_to_change
              end
            end
          end

          __for_every_attribute_remaining_in_the_diminishing_pool do
            _add_this_to_the_list_of_assignments_to_add
          end

          if __there_were_unrecognized_assignments
            __whine_about_the_unrecognized_assignments
          else
            __flush_the_removes
            _ok = __flush_the_changes
            _ok &&= __flush_the_adds_for_update
            _ok  # hi. #todo
          end
        else
          __whine_about_how_the_section_wasnt_found
        end
      end

      def __execute_via_create

        if _resolve_corresponding_section
          __whine_about_how_the_section_already_exists
        else
          ok = __resolve_new_section
          ok &&= __flush_the_adds_for_create
          # (we don't check for an empty list. it can be empty.
          # we have a natural key string to add in any case.)
          ok && __add_the_created_section
        end
      end

      # -- G.

      def __add_the_created_section
        _sect = remove_instance_variable :@_section
        @facade.entity_collection.document_.accept_section_ _sect
      end

      # a quick note about events and eventualities: it reads most
      # "elegantly" to say: we are done lining up our assignment deletes,
      # adds and changes; now we have only to "flush" them, which cannot
      # fail, right? well unfortunately no:
      #
      # the truth is it's possible they could still fail because of an
      # encoding error (i.e some values cannot be encoded in a config (e.g
      # `nil`, arbitrary (non-"primitive") objects)).
      #
      # at first we were willing to let these manifest as hard errors
      # (exceptions) so that we could maintain our "elegance" of these being
      # true "flushers" (i.e that cannot fail).
      #
      # but the clincher was we want to express the informational emissions
      # that these guys emit (create, add) and so in the spirit of elegance
      # we want to pass our listener in as-is (without writing a special
      # filter) so we lose the provision of it failing "hard" on encoding
      # errors, so we're back to square one with needing to allow for the
      # possibility that some of these might fail "softly". whew!

      def __flush_the_changes
        ok = true
        a = remove_instance_variable :@_list_of_assignments_to_change
        if a
          a.each do |asmt|
            _m = asmt.external_normal_name_symbol
            _x = @entity.send _m
            ok = @_section.assign _x, asmt.external_normal_name_symbol, & @listener
            ok || break
          end
        end
        ok && ACHIEVED_  # don't result in the assignment structure
      end

      def __flush_the_adds_for_update
        _for_every_non_nil_actual_attribute do |x, sym|
          @_section.assign x, sym, & @listener
        end
      end

      def __flush_the_adds_for_create

        # for a create we need never search for an appropriate insertion
        # point for each assignment provided that we start out with the
        # list of attributes already in the desired order :#spot1.1

        @_list_of_assignments_to_add = @persist_these

        _for_every_non_nil_actual_attribute do |x, sym|

          _ok = @_section.assign_by_ do |o|
            o.mixed_value = x
            o.external_normal_name_symbol = sym
            o.will_append
            o.listener = @listener
          end

          _ok  # hi. #todo
        end
      end

      def _for_every_non_nil_actual_attribute
        ok = true
        a = remove_instance_variable :@_list_of_assignments_to_add
        if a
          a.each do |sym|
            x = @entity.send sym
            x.nil? && next
            ok = yield x, sym
            ok || break
          end
        end
        # don't confuse things by resulting in (e.g) a status structure
        # for one particular assignment. our result should be an aggregate.
        ok && true
      end

      def __flush_the_removes
        a = remove_instance_variable :@_list_of_assignments_to_remove
        if a
          @_section.assignments.delete_assignments_via_assignments__ a
        end
        NIL
      end

      # -- F.

      def __whine_about_the_unrecognized_assignments

        asmt_a = @_list_of_unrecognized_assignments

        @listener.call :error, :expression, :unrecognized_assignments do |y|

          _scn = Scanner_[ asmt_a ]

          simple_inflection do

            buffer = oxford_join _scn do |asmt|
              "'#{ asmt.external_normal_name_symbol }'"
            end

            y << "cannot update: section in document has unrecognized #{ n "assignment" }: #{ buffer }"
          end
        end
        UNABLE_
      end

      def __there_were_unrecognized_assignments
        @_list_of_unrecognized_assignments
      end

      # -- E.

      def __we_will_add_the_attributes_in_alphabetical_order
        @_list_of_assignments_to_add = xx
      end

      def _add_this_to_the_list_of_assignments_to_add
        ( @_list_of_assignments_to_add ||= [] ).push @_current_attribute_symbol
        NIL
      end

      def __add_this_to_the_list_of_assignments_to_change
        ( @_list_of_assignments_to_change ||= [] ).push @_current_assignment
        NIL
      end

      def __add_this_to_the_list_of_assignments_to_remove
        ( @_list_of_assignments_to_remove ||= [] ).push @_current_assignment
        NIL
      end

      def __add_this_to_a_list_of_unrecognized_assignments
        ( @_list_of_unrecognized_assignments ||= [] ).push @_current_assignment
        NIL
      end

      # -- D.

      def __for_every_attribute_remaining_in_the_diminishing_pool & p

        @_current_attribute_symbol = nil
        remove_instance_variable( :@_pool ).keys.each do |attribute_sym|
          @_current_attribute_symbol = attribute_sym
          yield
        end
        remove_instance_variable :@_current_attribute_symbol ; nil
      end

      def __the_assignment_is_effectively_nil_in_the_entity

        _m = @_current_assignment.external_normal_name_symbol
        _hi = @entity.send _m
        _hi.nil?
      end

      def __the_assignment_is_not_in_the_list

        ! @_list_has_item[ @_current_assignment.external_normal_name_symbol ]
      end

      # -- C.

      def __remove_the_corresponding_name_from_the_diminishing_pool

        _k = @_current_assignment.external_normal_name_symbol

        # (neither our pseudocode nor our code dictates what to do for
        #  multiset ..)

        _did = @_pool.delete _k
        _did || self._COVER_ME__multiset__
        NIL
      end

      def __for_every_assignment_in_that_section

        st = @_section.assignments.to_stream_of_assignments
        @_current_assignment = nil
        begin
          asmt = st.gets
          asmt || break
          @_current_assignment = asmt
          yield
          redo
        end while above
        remove_instance_variable :@_current_assignment
        NIL
      end

      def __make_a_diminishing_pool_of_the_list_of_persistent_attributes

        @_pool = ::Hash[ @persist_these.map { |sym| [ sym, true ] } ]

        @_list_has_item = @_pool.dup.freeze

        # (sneak these in here too:)

        @_list_of_assignments_to_add = nil
        @_list_of_assignments_to_change = nil
        @_list_of_assignments_to_remove = nil
        @_list_of_unrecognized_assignments = nil
        NIL
      end

      # -- B.

      def __resolve_corresponding_section_for_update
        if _resolve_corresponding_section
          @_section = remove_instance_variable( :@_section_lookup ).section
          ACHIEVED_
        end
      end

      def _resolve_corresponding_section
        _nat_key = @entity._natural_key_string_
        lookup = @facade.lookup_section_ _nat_key
        @_section_lookup = lookup
        @_section_lookup.did_find
      end

      def __resolve_new_section
        _ = @facade.build_section_as_EC_facade_by__ do |o|
          o.unsanitized_subsection_name_string = @entity._natural_key_string_
          o.listener = @listener
        end
        _store :@_section, _
      end

      def __whine_about_how_the_section_wasnt_found

        lu = @_section_lookup

        @listener.call :error, :expression, :component_not_found do |y|
          y << "cannot update: no existing #{ lu.description_under self }"
          y << lu.to_one_line_of_further_information_under( self )
        end
        UNABLE_
      end

      def __whine_about_how_the_section_already_exists

        lu = @_section_lookup

        @listener.call :error, :expression, :entity_exists do |y|
          y << "cannot create: #{ lu.description_under self } already exists"
        end
        UNABLE_
      end

      # -- A.

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      # ==
      # ==
    end
  end
end
# #history-A: full rewrite: use more complete algorithm, wean off attr actor
