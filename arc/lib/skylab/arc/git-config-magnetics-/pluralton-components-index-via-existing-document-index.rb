module Skylab::Arc

  class GitConfigMagnetics_::PluraltonComponentsIndex_via_ExistingDocumentIndex < Common_::MagneticBySimpleModel

    # synopsis: relate those entities in the component list with those
    # sections in the document between which there is practical match.
    #
    # mainly, implement:
    #   - [#024.J] initial indexing of the components and the document

    # we exercise [#024.D.3] practical match to say that "the same" entity
    # manifests as both a component of the pluralton group and as a section
    # in the document.
    #
    # when referencing the entity as a component in a pluralton association
    # in business object space, the locator of the entity is simply the
    # numerical offset of the component in the list (starting from `0`).
    #
    # when referencing the entity as a section in the document, we use a
    # two-tuple (pair) of integers: the first is the offset of the [#024.H]
    # cluster in the list of clusters (the "clusterization"), and the second
    # integer is the offset of the section within the cluster.

    # subject is where we associate as "practical matches" nodes from the
    # one side with nodes from the other "destructively" (so, we cannot
    # associate the same section with multiple components, and vice versa).
    #
    # our "work product" includes (in part) some offsets in the form of
    # a "schematic", which is a structure that follows the (er) structure
    # of the original document. they take this form and not a more
    # practical formal so that we can "see" those entities to be associated
    # within the context of the existing document. (see #here1)

    # -

      attr_writer(
        :entity_profile_indexer,
        :existing_document_index,
        :listener,  # MIGHT NOT BE USED #todo
        :qualified_component,
      )

      def execute
        @associated_locators = []
        __work
        __finish
      end

      def __finish
        remove_instance_variable :@entity_profile_indexer
        remove_instance_variable :@existing_document_index
        remove_instance_variable :@listener
        remove_instance_variable :@qualified_component
        @associated_locator_offsets_schematic.map( & :freeze )
        @associated_locator_offsets_schematic.freeze
        @associated_locators.freeze
        freeze
      end

      def __work

        # NOTE - change arrays to hashes, maybe change identities to offset
        # into one or the other structure

        @associated_locator_offsets_schematic = @existing_document_index.profile_schematic.map do |d_a|
          ::Array.new d_a.length
        end

        # for each entity in the new list of components [#024.E] "N"..

        @qualified_component.value.each_with_index do |ent, offset|
          __index_current_component offset, ent
        end

        NIL
      end

      def __index_current_component current_component_offset, current_entity

        sct = @entity_profile_indexer.touch_mutable_profile_index_via_entity(
          current_entity )

        sct.add_occurrence_in_entity current_component_offset

        if sct.occurs_in_document
          __maybe_line_up sct
        end

        NIL
      end

      def __maybe_line_up sct

        # if you're here then the current component is practically
        # equivalent to at least one in the document. (the number of
        # *other* components this component is practically equivalent
        # to is zero or more, some of which we may know of at this point.)

        dox_count = sct.document_locators.length
        ent_count = sct.component_locators.length

        # we line these up one-for-one. once an entity from the one side
        # is associated with one from the other, each of those entities
        # is "used up" (or as we say, they are associated "destructively")

        # (under any given profile, all the matching entities from the
        # document being "used up" is a singular event, (so we don't have
        # to keep checking) but we do so anyway to reduce codesize.)

        if dox_count >= ent_count

          last_d = ent_count - 1
          doc_locator = sct.document_locators.fetch last_d
          ent_locator = sct.component_locators.fetch last_d

          d = @associated_locators.length
          @associated_locators.push AssociatedLocators___.new( ent_locator, doc_locator )

          @associated_locator_offsets_schematic[ doc_locator.first ][ doc_locator.last ] = d
        end

        NIL
      end

      attr_reader(
        :associated_locators,
        :associated_locator_offsets_schematic,  # discussed at #coverpoint2.4
      )
    # -

    # ==

    AssociatedLocators___ = ::Struct.new :component_locator, :document_locator

    # ==
    # ==
  end
end
# #born (was stashed for ~6 months)
