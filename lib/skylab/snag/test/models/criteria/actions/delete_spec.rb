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

      a = _common

      expect_neutral_event :file_utils_mv_event,
        /\Amv \(pth "[^"]+"\) \(pth "[^"]+"\)\z/

      _ev = expect_OK_event :entity_removed

      black_and_white( _ev ).should eql(
        'removed "zap-tango" from persisted criteria collection' )

      1 == a.length or fail
      a.first.natural_key_string.should eql 'zap-tango'
    end

    it "backend - no" do

      _init_cc_via_path Fixture_tree_[ :some_todos ]

      x = _common

      expect_neutral_event :entity_not_found,
        'persisted criteria collection does not have (val "zap-tango")'

      x.should be_nil
    end

    def _init_cc_via_path path

      @cc = Snag_::Models_::Criteria::Silo_Daemon.__build_collection_via_kernel(
        Snag_.application_kernel_
      ) do | o |
        o.directory_path =  path
      end

      NIL_
    end

    def _common

      @cc.edit(
        :if_present,
        :via, :slug,
        :remove, :criteria, 'zap-tango',
        & handle_event_selectively )
    end
  end
end
