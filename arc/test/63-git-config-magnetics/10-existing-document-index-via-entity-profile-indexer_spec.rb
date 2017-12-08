# frozen_string_literal: true

require_relative '../test-support'

module Skylab::Arc::TestSupport

  describe '[ac] git config magnetics - existing document index via entity profile indexer' do  # #coverpoint2.3

    TS_[ self ]
    use :memoizer_methods
    use :git_config_magnetics

    it 'subject magnetic loads' do
      _subject_module || fail
    end

    it 'pluralton list loads' do
      qualified_component_for_story_A_ || fail
    end

    it 'existing document parses' do
      mutable_config_A_ || fail
    end

    it 'mutable entity hello' do
      mutable_entity_A_ || fail
    end

    describe '(case 100)' do

      it 'build mutable entity' do
        _mutable_entity || fail
      end

      it 'this one indexer is mutable per-index but must build' do
        _mutable_indexer || fail
      end

      it 'subject builds' do
        _subject || fail
      end

      it 'profile schematic looks write per the story' do  # (as seen in a document at coverpoint)
        _ = _subject.profile_schematic
        _ == [[1, 1], [2, 3, 3, 3, 4], [5, 6]] || fail
      end

      it 'profile schematic is frozen' do
        x = _profile_schematic
        x.frozen? || fail
        x.first.frozen? || fail
      end

      def _profile_schematic
        _subject.profile_schematic
      end

      shared_subject :_subject do
        _call
      end

      def _qualified_component  # we could thin this away
        qualified_component_for_story_A_
      end

      def _mutable_entity
        mutable_entity_A_
      end

      shared_subject :_mutable_indexer do
        Home_::GitConfigMagnetics_::EntityProfileIndexer.new  # should be 1 of 2 when all is dnne
      end
    end

    def _call

      _qc = _qualified_component
      _sym = _qc.name_symbol
      _me = _mutable_entity
      _mi = _mutable_indexer

      _subject_module.call_by do |o|
        o.mutable_entity = _me
        o.component_association_name_symbol = _sym
        o.entity_profile_indexer = _mi
        o.listener = Home_::Magnetics::QualifiedComponent_via_Value_and_Association::Listener_that_raises_exceptions_
      end
    end

    shared_subject :mutable_entity_A_ do
      _mc = mutable_config_A_
      build_mutable_entity_by_ do |o|
        o._config_for_write_ = _mc
      end
    end

    def _subject_module
      Home_::GitConfigMagnetics_::ExistingDocumentIndex_via_EntityProfileIndexer
    end

    # ==

    # ==
    # ==
  end
end
# #born.
