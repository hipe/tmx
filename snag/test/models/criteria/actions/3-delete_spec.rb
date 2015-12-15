require_relative '../../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - criteria - delete - (NOT FULLY INTEGRATED)" do

    extend TS_
    use :expect_event
    use :my_tmpdir_

    it "backend - yes" do

      td = my_tmpdir_.clear
      td.touch 'zap-tango'

      _init_cc_via_path td.to_path

      o = _common

      expect_neutral_event :file_utils_message,
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

      @cc = Home_::Models_::Criteria::Silo_Daemon.__build_collection_via_kernel(
        Home_.application_kernel_
      ) do | o |
        o.directory_path =  path
      end

      NIL_
    end

    def _common

      @cc.edit(
        :assuming, :exists,
        :via, :slug,
        :remove, :criteria, 'zap-tango',
        & handle_event_selectively_ )
    end
  end
end
