require_relative 'test-support'

module Skylab::TanMan::TestSupport::Models::Workspace

  describe "[ta] models - workspace create" do

    extend TS_

    it "holy god" do

      call_API :init,
        :path, empty_work_dir

      expect_OK_event :datastore_resource_committed_changes

      o = TestSupport_::Expect_Line::Scanner.via_line_stream(
        io = ::File.open( expected_config_path ) )

      o.next_line.should match(
        /\A# created by tan man \d{4}-\d\d-\d\d \d\d:\d\d:\d\d/ )

      o.next_line.should be_nil

      io.close

      expect_succeeded

    end
  end
end
