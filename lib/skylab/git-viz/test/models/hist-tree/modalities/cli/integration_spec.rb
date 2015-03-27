require_relative '../../../test-support'

module Skylab::GitViz::TestSupport::Models

  describe "[gv] VCS adapters - git - models - hist-tree - CLI - integration" do

    extend TS_
    use :bundle_support
    use :expect_CLI  # order matters

    it "help screen - expect [#br-042] back-to-front property mutation" do

      invoke 'hi', '-h'

      screen = GitViz_.lib_.brazen.test_support.CLI::Expect_Section.
        tree_via_line_stream(
          sout_serr_line_stream_for_contiguous_lines_on_stream :e )

      screen.children.map { |cx| cx.x.unstyled_header_content }.should eql(
        [ 'usage', 'options', 'arguments' ] )

      args = screen.children.last
      args.children.map { |cx| cx.x.unstyled_header_content }.should eql(
        %w( width path ) )

      expect_result_for_success
    end

    it "when width is not present" do

      invoke 'hi', 'x'

      on_stream :e
      expect :styled, 'expecting <path>'
      expect_result_for_failure
    end

    it "when width is not valid" do

      invoke 'hi', '--', '-1', 'x'

      expect :styled, '<width> must be greater than or equal to 1, had \'-1\''
      expect_result_for_failure
    end

    it "DAY VIEW!" do

      _common_prepare

      invoke 'hi', '--', '46', _the_pathname

       __expect_day_view_dots
    end

    it "SHIFT VIEW!" do

      _common_prepare

      invoke 'hi', '--', '47', _the_pathname

      __expect_shift_view_dots
    end

    def _common_prepare

      @for_expect_stdout_stderr_prepare_invocation = method :__prepare_invo
      @for_expect_stdout_stderr_use_this_as_stderr = mock_stderr_instance
    end

    def __prepare_invo invo
      invo.receive_environment( { __system_conduit__: mock_system_conduit } )
      NIL_
    end

    def _the_pathname
      mock_pathname '/m03/repo/dirzo'
    end

    # ~ expects

    def __expect_day_view_dots

      on_stream :o

      expect "                                     1J  "
      expect "                                     9a3M"
      expect "                                     9nro"
      expect "                                     9 dn"
      expect " ├everybody in the room is floating | •• "
      expect " ├it's just                         |"
      expect " │ └funky like that                 |• ⬤ "
      expect " └move-after                        |  ●●"

      expect_succeeded
    end

    def __expect_shift_view_dots

      on_stream :o

      expect "                                     1         "
      expect "                                     9J28 38 M8"
      expect "                                     9anA rA oA"
      expect "                                     9ndM dM nM"
      expect " ├everybody in the room is floating |   •  •   "
      expect " ├it's just                         |"
      expect " │ └funky like that                 |•     ⬤   "
      expect " └move-after                        |      ●  ●"

      expect_succeeded
    end

    def __FOR_THE_FUTURE_expect_solid_dots

      on_stream :o

      expect " ├everybody in the room is floating |   ⦿ •  "
      expect " ├it's just                         |"
      expect " │ └funky like that                 | ⦿   ⬤  "
      expect " └move-after                        |     ⦿ ●"

      expect_succeeded
    end

    def manifest_path_for_mock_FS
      GIT_STORY_03_PATHS_
    end

    def manifest_path_for_mock_system
      GIT_STORY_03_COMMANDS_
    end
  end
end
