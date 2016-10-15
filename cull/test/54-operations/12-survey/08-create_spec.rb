require_relative '../../test-support'

module Skylab::Cull::TestSupport

  describe "[cu] operations - survey - create" do

    TS_[ self ]
    use :expect_event

    it "loads" do
      Home_::API
    end

    it "ping the top" do
      x = Home_::API.call :ping, :on_event_selectively, event_log.handle_event_selectively
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
      call_API :create, :path, freshly_initted_path_
      expect_not_OK_event :directory_exists
      expect_failed
    end

    it "go money" do

      call_API :create, :path, prepare_tmpdir.to_path

      em = @result
      expect_neutral_event :creating_directory
      expect_OK_event_ :collection_resource_committed_changes

      em.category.should eql [ :info, :created_survey ]

      ev = em.emission_value_proc.call
      ev.ok or fail
      ev.path or fail
      ev.is_completion or fail
    end
  end
end
