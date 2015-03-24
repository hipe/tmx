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
        [ 'usage', 'options', 'argument' ] )

      screen.children.last.only_child.x.line_content.should eql 'path'

      expect_result_for_success
    end

    it "see dots (mocked) (note tree cosmetics appear broken)" do

      @for_expect_stdout_stderr_prepare_invocation = method :__prepare_invo
      @for_expect_stdout_stderr_use_this_as_stderr = mock_stderr_instance

      invoke 'hi', mock_pathname( '/m03/repo/dirzo' )
      __expect_dots
      expect_succeeded
    end

    def __prepare_invo invo
      invo.receive_environment( { __system_conduit__: mock_system_conduit } )
      NIL_
    end

    def __expect_dots

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
