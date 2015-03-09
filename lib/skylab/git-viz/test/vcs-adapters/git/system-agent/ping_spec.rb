require_relative 'test-support'

module Skylab::GitViz::TestSupport::VCS_Adapters::Git::System_Agent

  describe "[gv] VCS adapters - git - system agent - ping" do

    extend TS_
    use :expect_event
    use :mock_FS
    use :mock_system

    it "ping when chdiring to a directory - output lines are in scanner" do
      _ping_from_path 'wa-da-da-dir'
      __expect_pinged
    end

    it "ping when chdiring to a file - x" do
      _ping_from_path 'wa-da-da-file'
      _expect_ping_command_with_chdir_value 'wa-da-da-file'
      _expect_cannot_execute_command_saying Top_TS_::Messages::PATH_IS_FILE
      _expect_no_output_stream
    end

    it "ping when chdiring to a noent - x" do
      _ping_from_path 'wa-da-da-not-exist'
      _expect_ping_command_with_chdir_value 'wa-da-da-not-exist'
      _expect_cannot_execute_command_saying(
        "No such file or directory - wa-da-da-not-exist" )
      _expect_no_output_stream
    end

    def _ping_from_path x
      with_system_agent do |sa|
        sa.set_cmd_s_a %w( print -l winz WINZ )
        sa.set_chdir_pathname mock_pathname x
      end
      @scn = @sa.get_any_nonzero_count_output_line_stream_from_cmd
      nil
    end

    def __expect_pinged
      __expect_next_system_command_for_pinged
      expect_no_more_events
      __expect_output_lines_for_pinged
    end

    def __expect_next_system_command_for_pinged
      _expect_ping_command_with_chdir_value 'wa-da-da-dir'
      expect_no_more_events
    end

    def _expect_ping_command_with_chdir_value x

      expect_OK_event :next_system_command do | cmd |

        cmd.command_s_a.should eql %w( print -l winz WINZ )
        cmd.any_nonzero_length_option_h[ :chdir ].should eql x
      end
    end

    def _expect_cannot_execute_command_saying exp_s
      expect_not_OK_event :cannot_execute_command do | ev |
        black_and_white( ev ).should eql exp_s
      end
    end

    def __expect_output_lines_for_pinged
      @scn.gets.should eql 'winz'
      @scn.gets.should eql 'WINZ'
      @scn.gets.should be_nil
    end

    def _expect_no_output_stream
      @scn.should eql false
    end

    def fixtures_module  # #hook-in, reach up: we don't maintain our own
      Parent_TS__::Fixtures  # fixturs dir, we use that of parent test dir
    end
  end
end
