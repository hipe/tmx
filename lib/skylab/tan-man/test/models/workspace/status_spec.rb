require_relative 'test-support'

module Skylab::TanMan::TestSupport::Models::Workspace

  describe "[tm] models workspace - `status`" do

    extend TS_

    it "dir w/o config file - is not failure" do
      call_API :status, :path, dirs
      ev = expect_OK_event :resource_not_found
      black_and_white( ev ).should eql '"tanman-workspace/config" not found in dirs'
      expect_no_more_events
      expect_succeeded
    end

    it "partay" do
      call_API :status, :path, dir( :with_freshly_initted_conf ),
        :config_filename, 'tan-man.conf'
      expect_OK_event :resource_exists
      expect_succeeded
    end
  end
end
# this line is for :+#posterity - "@todo waiting for permute [#056]"
