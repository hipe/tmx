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

        PluraltonComponentsIndex___.new(
          remove_instance_variable( :@_mutable_schema ),
          remove_instance_variable( :@associated_locators ),
        )
      end

      def __work

        # NOTE - change arrays to hashes, maybe change identities to offset
        # into one or the other structure

        @_mutable_schema = @existing_document_index.profiled_clusters.map do |pc|
          ::Array.new pc.profile_offsets.length
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

          @_mutable_schema[ doc_locator.first ][ doc_locator.last ] = d
        end

        NIL
      end
    # -

    # ==

    def self.VIA_CONDENSED(
      associated_schema: nil,
      associations_YUCK: nil
    )
      al_a = []
      _o = -> comp_d, * doc_locator do
        _al = AssociatedLocators___.new comp_d, doc_locator.freeze
        al_a.push _al ; nil
      end
      associations_YUCK[ _o ]
      al_a.freeze

      PluraltonComponentsIndex___.new associated_schema, al_a
    end

    class PluraltonComponentsIndex___
      def initialize mutable_schema, al
        @associated_clusters = AssociatedClusters___.new mutable_schema
        @associated_locators = al
        freeze
      end
      attr_reader(
        :associated_clusters,
        :associated_locators,
      )
    end

    class AssociatedClusters___
      def initialize mutable_schema
        @clusters = mutable_schema.map do |cluster|
          AssociatedCluster___.new cluster.freeze
        end
        freeze
      end
      attr_reader(
        :clusters,
      )
    end

    class AssociatedCluster___
      def initialize mutable_sparse_d_a
        @sparse_associated_offsets = mutable_sparse_d_a.freeze
        freeze
      end
      attr_reader(
        :sparse_associated_offsets,
      )
    end

    class AssociatedLocators___
      def initialize x, xx
        @COMPONENT_OFFSET = x
        @document_locator = xx
        freeze
      end
      attr_reader(
        :COMPONENT_OFFSET,
        :document_locator,
      )
    end

    # ==
    # ==
  end
end
# #born (was stashed for ~6 months)
