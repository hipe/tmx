require_relative '../test-support'

module Skylab::GitViz::TestSupport

  describe "[gv] CLI - hist tree" do

    TS_[ self ]
    use :memoizer_methods
    use :VCS_adapters_git_bundles
    use :my_CLI  # order matters

    context "help screen - expect [#br-042] back-to-front property mutation" do

      shared_subject :state_ do

        invoke 'hi', '-h'
        flush_invocation_to_help_screen_oriented_state
      end

      it "succeeds" do
        state_.exitstatus.should match_successful_exitstatus
      end

      it "these three sections (note singular)" do

        _ = state_.tree.children.reduce [] do | m, node |
          m << node.x.unstyled_header_content
        end

        _.should eql %w( usage option arguments )
      end

      it "args should have these items" do

        _args = state_.tree.children.last

        _ = _args.children.reduce [] do | m, node |
          m << node.x.unstyled_header_content
        end

        _.should eql %w( <width> <path> )
      end
    end

    it "when width is not present" do

      invoke 'hi', 'x'

      on_stream :e
      expect :styled, 'expecting <path>'
      expect_result_for_failure
    end

    it "when width is not valid" do

      invoke 'hi', '--', '-1', 'x'

      expect :styled, 'failed because <width> must be greater than or equal to 1, had -1'
      expect_result_for_failure
    end

    it "DAY VIEW!" do

      _common_prepare

      invoke 'hi', '--', '46', _the_path

      __expect_day_view_dots
    end

    it "SHIFT VIEW!" do

      _common_prepare

      invoke 'hi', '--', '47', _the_path

      __expect_shift_view_dots
    end

    def _common_prepare

      @for_expect_stdout_stderr_prepare_invocation = method :__prepare_invo
      @stderr_for_expect_stdout_stderr = mock_stderr_instance_for_CLI_expectations
    end

    def __prepare_invo invo

      invo.receive_system_conduit stubbed_system_conduit

      invo.receive_filesystem stubbed_filesystem

      NIL_
    end

    define_method :_the_path, -> do
      s = '/m03/repo/dirzo'
      -> do
        s
      end
    end.call

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

      expect_succeed
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

      expect_succeed
    end

    def __FOR_THE_FUTURE_expect_solid_dots

      on_stream :o

      expect " ├everybody in the room is floating |   ⦿ •  "
      expect " ├it's just                         |"
      expect " │ └funky like that                 | ⦿   ⬤  "
      expect " └move-after                        |     ⦿ ●"

      expect_succeed
    end

    def manifest_path_for_stubbed_FS

      at_ :STORY_03_PATHS_
    end

    def manifest_path_for_stubbed_system

      at_ :STORY_03_COMMANDS_
    end
  end
end
