require_relative '../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] operations - criteria - delete - (NOT FULLY INTEGRATED)" do

    TS_[ self ]
    use :expect_event
    use :my_tmpdir_

    it "backend - yes" do

      # #lends-coverage to [#sy-008.4]

      td = my_tmpdir_.clear
      td.touch 'zap-tango'

      _init_cc_via_path td.to_path

      o = _common

      expect_neutral_event :file_utils_mv_event,
        /\Amv \(pth "[^"]+"\) \(pth "[^"]+"\)\z/

      _em = expect_OK_event :component_removed

      black_and_white( _em.cached_event_value ).should eql(
        'removed criteria "zap-tango" from persisted criteria collection' )

      o.natural_key_string.should eql 'zap-tango'
    end

    it "backend - no" do

      _init_cc_via_path Fixture_tree_[ :some_todos ]

      x = _common

      _em = expect_not_OK_event :component_not_found

      black_and_white( _em.cached_event_value ).should eql(
        'persisted criteria collection does not have criteria "zap-tango"' )

      expect_no_more_events

      x.should eql false
    end

    def _init_cc_via_path path

      _ = invocation_resources_

      @CC = Home_::Models_::Criteria::CriterionCollection___.define do |o|
        o.directory_path = path
        o.invocation_resources = _
      end
      NIL
    end

    def _common

      @CC.edit(
        :assuming, :exists,
        :via, :slug,
        :remove, :criteria, 'zap-tango',
        & handle_event_selectively_ )
    end
  end
end
