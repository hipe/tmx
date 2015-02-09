require_relative 'test-support'

module Skylab::TanMan::TestSupport::Models::Workspace

  describe "[ta] models - workspace create" do

    extend TS_

    it "holy god" do

      config_filename = 'xyz'

      call_API :init,
        :path, empty_work_dir,
        :config_filename, config_filename

      _expected_config_path = @ws_pn.join( config_filename ).to_path

      expect_OK_event :datastore_resource_committed_changes

      o = TestSupport_::Expect_Line::Scanner.via_line_stream(
        io = ::File.open( _expected_config_path ) )

      o.next_line.should match(
        /\A# created by tan man \d{4}-\d\d-\d\d \d\d:\d\d:\d\d/ )

      o.next_line.should be_nil

      io.close

      expect_succeeded

    end

    def expected_config_path
      @ws_pn.join( TanMan_::Models_::Workspace.config_filename ).to_path
    end

  end
end
