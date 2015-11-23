require_relative '../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] CLI canon level 1" do

    extend TS_
    use :CLI_behavior

    # it "  0)  no arguments"

    # it "1.1)  strange argument"

    with_invocation 'status'

    it "1.2)  strange option - ( E I )" do
      invoke '-z'
      expect 'invalid option: -z'
      expect_action_invite_line
      expect_errored
    end

    # it "1.3)  good argument"

    context "action help screen" do

      it "1.4)  good option (help screen)" do
        invoke '-h'
        expect_action_help_screen
      end

      def expect_description
        expect :styled, %r(\Adescription: .+\bstatus\b)
        expect_maybe_a_blank_line
      end

      def expect_these_options
        expect_option :verbose
        expect_option :help, %r(this screen)
      end

      def expect_these_arguments
        expect_item :path, %r(\blocation\b.+), :styled, %r(\bneat\b)
      end

      def expect_environment_variables
        expect_header_line 'environment variable'
        expect_item :BRAZEN_MAX_NUM_DIRS, %r(\bhow far\b)
      end
    end

    it "2)    extra argument - ( E U I )" do
      invoke 'wing', 'wang'
      expect_unexpected_argument 'wang'
      expect_action_usage_line
      expect_action_invite_line
    end

    def prop_syntax
      status_prop_syntax
    end
  end
end
