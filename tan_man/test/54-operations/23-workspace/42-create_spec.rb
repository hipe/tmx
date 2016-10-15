require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] models - workspace create" do

    TS_[ self ]
    use :models

    it "holy god" do

      config_filename = 'xyz'

      call_API :init,
        :path, empty_work_dir,
        :config_filename, config_filename

      _expected_config_path = @ws_pn.join( config_filename ).to_path

      expect_committed_changes_

      o = TestSupport_::Expect_Line::Scanner.via_line_stream(
        io = ::File.open( _expected_config_path ) )

      o.next_line.should match(
        /\A# created by tan man \d{4}-\d\d-\d\d \d\d:\d\d:\d\d/ )

      o.next_line.should be_nil

      io.close

      @result.existent_surrounding_path  # should respond

    end

    def expected_config_path
      @ws_pn.join( Home_::Models_::Workspace.config_filename ).to_path
    end

  end
end
