require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] models workspace - `status`" do

    TS_[ self ]
    use :models

    it "dir w/o config file - is not failure", wip: true do

      call_API :status, :path, dirs

      _em = expect_OK_event :resource_not_found

      black_and_white( _em.cached_event_value ).should eql(
        '"tanman-workspace/config" not found in dirs' )

      expect_succeeded
    end

    it "partay", wip: true do
      call_API :status, :path, dir( :with_freshly_initted_conf ),
        :config_filename, 'tan-man.conf'
      expect_OK_event :resource_exists
      expect_succeeded
    end
  end
end
# this line is for :+#posterity - "@todo waiting for permute [#056]"
