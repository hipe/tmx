# frozen_string_literal: true

require_relative '../test-support'

module Skylab::Arc::TestSupport

  describe '[ac] git config magnetics - existing document index via entity profile indexer' do

    TS_[ self ]
    use :memoizer_methods
    use :git_config_magnetics

    it 'subject magnetic loads' do
      magnet_300_ || fail
    end

    it '(story A)', slow: true do  # slow because uses real diff

      _exp = product_of_magnetic_300_for_story_A_MOCKED_
      _act = build_product_of_magnetic_300_for_story_A_OF_PARTIALLY_MOCKED_SOURCES___

      _act == _exp || fail  # recursive equals would be nice
    end

    # ==

    # ==
    # ==
  end
end
# #born (to cover work that was stashed ~6 months ago)
