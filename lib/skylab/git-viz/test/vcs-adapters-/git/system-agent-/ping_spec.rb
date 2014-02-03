require_relative 'test-support'

module Skylab::GitViz::TestSupport::VCS_Adapters_::Git::System_Agent_

  describe "[gv] VCS adapters git system agent spec" do

    extend TS__ ; use :expect ; use :mock_FS ; use :mock_system

    it "ping when chdiring to a directory - output lines are in scanner" do
      ping_from_path 'wa-da-da-dir'
      expect_pinged
    end

    it "ping when chdiring to a file - x" do
      ping_from_path 'wa-da-da-file'
      expect_ping_command_with_chdir_value 'wa-da-da-file'
      expect_cannot_execute_command_saying TS_::Messages::PATH_IS_FILE
      expect_no_output_scanner
    end

    it "ping when chdiring to a noent - x" do
      ping_from_path 'wa-da-da-not-exist'
      expect_ping_command_with_chdir_value 'wa-da-da-not-exist'
      expect_cannot_execute_command_saying(
        "No such file or directory - wa-da-da-not-exist" )
      expect_no_output_scanner
    end

    def ping_from_path x
      with_system_agent do |sa|
        sa.set_cmd_s_a %w( print -l winz WINZ )
        sa.set_chdir_pathname mock_pathname x
      end
      @scn = @sa.get_any_nonzero_count_output_line_scanner_from_cmd
    end

    def expect_pinged
      expect_next_system_command_for_pinged
      expect_output_lines_for_pinged
    end

    def expect_next_system_command_for_pinged
      expect_ping_command_with_chdir_value 'wa-da-da-dir'
      expect_no_more_emissions
    end

    def expect_ping_command_with_chdir_value x
      expect %i( next_system command ) do |em|
        cmd = em.payload_x
        cmd.command_s_a.should eql %w( print -l winz WINZ )
        cmd.any_nonzero_length_option_h[ :chdir ].should eql x
      end
    end

    def expect_cannot_execute_command_saying s
      expect %i( cannot_execute_command string ), s
    end

    def expect_output_lines_for_pinged
      @scn.gets.should eql 'winz'
      @scn.gets.should eql 'WINZ'
      expect_no_more_emissions
    end

    def expect_no_more_output_lines
      x = @scn.gets
      x and fail "expected no more output lines, had: #{ x.inspect }"
    end

    def expect_no_output_scanner
      @scn.should eql false
    end

    def fixtures_module  # #hook-in, reach up: we don't maintain our own
      Parent_TS__::Fixtures  # fixturs dir, we use that of parent test dir
    end
  end
end
