# frozen_string_literal: true

require_relative '../test-support'

module Skylab::Arc::TestSupport

  describe '[ac] git config magnetics - existing document index via entity profile indexer' do  # #coverpoint2.3

    TS_[ self ]
    use :memoizer_methods
    use :git_config_magnetics

    it 'subject magnetic loads' do
      magnet_100_ || fail
    end

    it 'pluralton list loads' do
      qualified_component_for_story_A_ || fail
    end

    it 'existing document parses' do
      mutable_config_for_story_A_ || fail
    end

    it 'mutable entity hello' do
      mutable_entity_for_story_A_ || fail
    end

    describe '(doing my part for story A)' do

      it 'this one indexer is mutable per-index but must build' do
        mutable_indexer_for_story_A_ || fail
      end

      it 'subject builds' do
        _subject || fail
      end

      it 'profiled clusters looks right per the story' do  # (as seen in a document at coverpoint)

        _ = _subject.TO_CONDENSED
        _ == [[1, 1], [2, 3, 3, 3, 4], [5, 6]] || fail
      end

      it 'profiled clusters array is frozen, as is each item probably' do
        x = _subject.profiled_clusters
        x.frozen? || fail
        x.first.frozen? || fail
      end

      alias_method :_subject, :product_of_magnetic_100_for_story_A_
    end

    # ==

    # ==
    # ==
  end
end
# #born.
