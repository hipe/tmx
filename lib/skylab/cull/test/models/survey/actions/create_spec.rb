require_relative '../../../test-support'

module Skylab::Cull::TestSupport

  describe "[cu] models - survey create" do

    Expect_event_[ self ]

    extend TS_

    it "loads" do

      Cull_::API

    end

    it "ping the top" do
      x = Cull_::API.call :ping, :on_event_selectively, handle_event_selectively
      expect_neutral_event :ping, "hello from cull."
      expect_no_more_events
      x.should eql :hello_from_cull
    end

    it "ping the model node" do
      call_API :survey, :ping
      expect_OK_event :ping, 'cull says (highlight "hello")'
      expect_no_more_events
      @result.should eql :_hi_again_
    end

    it "create on a directory with the thing already" do
      call_API :create, :path, freshly_initted_path
      expect_not_OK_event :directory_exists
      expect_failed
    end

    it "go money" do
      call_API :create, :path, prepare_tmpdir.to_path
      expect_neutral_event :creating_directory
      expect_OK_event :datastore_resource_committed_changes
      expect_OK_event :survey
      expect_succeeded
    end
  end
end
