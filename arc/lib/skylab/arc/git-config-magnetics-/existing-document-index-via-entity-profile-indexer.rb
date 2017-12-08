module Skylab::Arc

  class GitConfigMagnetics_::ExistingDocumentIndex_via_EntityProfileIndexer <
      Common_::MagneticBySimpleModel

    # exactly as described by [#024.F] clusters, break the document up
    # into a series of clusters separated by runs of non-participating
    # sections. reminder: even though this sounds complicated, this is
    # the easy part.

    # to synthesize [#same], for every relevant section after the (any)
    # first relevant section in the document, look at the distance of the
    # "jump" from the previous relevant section to this one, in terms of
    # their offsets into the document (the document being modeled as an
    # array of elements). IFF the jump distance is greater than 1, there is
    # a "run" of non-participating sections (assuming that blank lines/
    # comments are always folded into the current section, and sidestepping
    # what happens at the very beginning of the document) constituting a
    # "page break" between one cluster and the next.
    #
    # then, within each "cluster" there is the 1 or more entities implied
    # by that section in that cluster. allowing that this unmarshaling may
    # fail, initialize in our index a structure reflecting the indexing of
    # the "profile" "identifier" for this entity.
    #
    # the result is some sort of structure encompassing all this, namely
    # both the structure of the document and the practical identity of
    # each entity within that structure.

    # -

      def mutable_entity= me

        @__models_feature_branch = me._models_feature_branch_
        @__config_for_write = me._config_for_write_
        me
      end

      attr_writer(
        :component_association_name_symbol,
        :entity_profile_indexer,
        :listener,
      )

      def execute

        @profile_schematic = []

        ok = __resolve_clusters
        ok &&= __resolve_profile_schematic
        ok && __finish
      end

      def __finish
        remove_instance_variable :@__models_feature_branch
        remove_instance_variable :@entity_profile_indexer
        remove_instance_variable :@listener
        @profile_schematic.map( & :freeze )
        @profile_schematic.freeze
        freeze  # (at writing, leaves only @profile_schematic)
      end

      # -- E: index every relevant entity in the document

      def __resolve_profile_schematic

        ok = true

        _clusters = remove_instance_variable :@__clusters

        _clusters.each_with_index do |cluster, cluster_d|
          @__current_cluster_offset = cluster_d
          @profile_schematic.push []
          cluster.each_with_index do |os, os_d|  # os = offset/section
            @_current_relevant_section = os.section
            ok = __resolve_entity_via_section
            ok || break
            @__current_section_in_cluster_offset = os_d
            __index_current_entity_which_is_in_document
          end
          remove_instance_variable :@__current_cluster_offset
        end

        ok
      end

      def __index_current_entity_which_is_in_document

        csico = remove_instance_variable :@__current_section_in_cluster_offset

        _ce = remove_instance_variable :@__current_entity

        sct = @entity_profile_indexer.touch_mutable_profile_index_via_entity _ce

        sct.add_occurrence_in_document(
          csico,
          @__current_cluster_offset,
        )

        @profile_schematic.last[ csico ] = sct.profile_integer

        NIL
      end

      # -- C: resolve entity via section

      def __resolve_entity_via_section

        if __resolve_model
          __resolve_entity_via_model
        end
      end

      def __resolve_entity_via_model

        _crs = remove_instance_variable :@_current_relevant_section  # yikes
        _st = _crs.assignments.to_stream_of_assignments

        # (for now we need to map assignments to QK's but maybe one day we
        # won't need to #[#br-029.2]:)

        _use_st = _st.map_by do |asmt|

          Common_::QualifiedKnownKnown.via_value_and_symbol(
            asmt.value, asmt.external_normal_name_symbol )
        end

        _cm = remove_instance_variable :@__current_model

        _ent = _cm.define_via_persistable_primitive_name_value_pair_stream_by do |o|
          o.persistable_primitive_name_value_pair_stream = _use_st
          o.listener = @listener
        end

        _store :@__current_entity, _ent
      end

      def __resolve_model

        # excercise [#024.C.3] provision 3: the subsection name (any string)
        # (for sections corresponding to pluralton associations) must
        # isomorph with the class name corresponding to the business class
        # to be used to unserialize the entity.

        _s = @_current_relevant_section.subsection_string
        _sym = _s.gsub( SPACE_, UNDERSCORE_ ).intern
        item = @__models_feature_branch.procure _sym, & @listener
        if item
          # (disregarding item.name)
          @__current_model = item.value
          ACHIEVED_
        end
      end

      # -- B: resolve clusters

      def __resolve_clusters
        st = __to_stream_of_relevant_sections
        os = st.gets  # (offset/section)
        if os
          clusters = [ [ os ] ]
          last_relevant_offset = os.offset
          begin
            os = st.gets
            os || break
            d = os.offset
            if d != last_relevant_offset + 1
              clusters.last.freeze
              clusters.push []
            end
            clusters.last.push os
            last_relevant_offset = d
            redo
          end while above
          clusters.last.freeze
          @__clusters = clusters.freeze ; true
        else
          self._COVER_ME__no_relevant_sections__
        end
      end

      def __to_stream_of_relevant_sections

        # exercise [#024.C.2] provision 2: the section name (not sub-section
        # name) corresponds to an association names. in this method we
        # filter on the section name, looking for only those sections that
        # corresond to the association we are looking for.
        #
        # [#024.C.1] provision 1 holds that *every* section in the document
        # must correspond to an entity (and so class, etc). however, note we
        # don't exercise this provision because we skip over those sections
        # we don't care about. (so hypothetically these sections could be
        # any document section at all (even a non-un-persistable one) and
        # we won't notice any issues there.)

        sym = remove_instance_variable :@component_association_name_symbol

        _cfw = remove_instance_variable :@__config_for_write

        _st = _cfw.sections.TO_DEREFERENCED_ITEM_STREAM_WITH_OFFSETS

        _st.filter_by do |pair|
          sym == pair.section.external_normal_name_symbol
        end
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
    # -

      attr_reader(
        :profile_schematic,
      )

    # ==
    # ==
  end
end
# #born (was stashed for ~6 months)
