module Skylab::Arc

  class GitConfigMagnetics_::EntityProfileIndexer

    # exactly for [#024.H] determining practical equivalence of entities,
    # this implements the act of producing a unique identifier (as a serial
    # integer starting at 1) representing the "practical identity" of an
    # entity, for the purpose of "lining up" entities to each other for
    # re-use in persistence.

    # -

      def initialize

        cache = {}
        counter = 0

        @__did_and_index_via_comparator = -> frozen_a do
          did = false
          # (the below line is where [#024.G] the hash implementation is utilized)
          use_counter = cache.fetch frozen_a do
            counter += 1
            cache[ frozen_a ] = counter
            did = true
            counter
          end
          [ did, use_counter ]
        end

        @_index_via_identifier = [ nil ]  # this way, index == identifier, but 0 is not a valid identifier (OCD)
      end

      def touch_mutable_profile_index_via_entity ent

        # (this is refeferenced as :#code-example:[#024.H])

        _a = ent._comparator_for_practical_equivalence_
        did, d = @__did_and_index_via_comparator[ _a ]

        if did
          @_index_via_identifier.length == d || sanity
          sct = IdentifierIndex__.new d
          @_index_via_identifier.push sct
          sct
        else
          @_index_via_identifier.fetch d
        end
      end
    # -

    # ==

    class IdentifierIndex__

      def initialize d
        @add_occurrence_in_entity = :__add_occurrence_in_entity_initially
        @add_occurrence_in_document = :__add_occurrence_in_document_initially
        @profile_integer = d
      end

      def add_occurrence_in_entity d
        send @add_occurrence_in_entity, d
      end

      def add_occurrence_in_document d_, d
        send @add_occurrence_in_document, d_, d
      end

      def __add_occurrence_in_entity_initially d
        @occurs_in_entity = true
        @add_occurrence_in_entity = :__add_occurrence_in_entity_normally
        @component_locators = []
        send @add_occurrence_in_entity, d
      end

      def __add_occurrence_in_document_initially d_, d
        @occurs_in_document = true
        @add_occurrence_in_document = :__add_occurrence_in_document_normally
        @document_locators = []
        send @add_occurrence_in_document, d_, d
      end

      def __add_occurrence_in_entity_normally d
        @component_locators.push d
        NIL
      end

      def __add_occurrence_in_document_normally d_, d
        @document_locators.push [ d, d_ ]
        NIL
      end

      attr_reader(
        :component_locators,
        :document_locators,
        :occurs_in_document,
        :occurs_in_entity,
        :profile_integer,
      )
    end

    # ==
  end
end
# #born.
