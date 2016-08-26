require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] non-interactive CLI - without ACS" do

    TS_[ self ]
    use :memoizer_methods
    use :non_interactive_CLI

    context "you can build a CLI from no ACS.." do

      shared_subject :subject_CLI do

        cli = Home_::NonInteractiveCLI.begin
        cli.root_ACS_by do  # #cold-model
          NIL_
        end
        cli.to_classesque
      end

      context "invoke against nothing" do

        given do
          argv
        end

        it "exitstatus" do
          fails
        end

        it "expecting" do
          first_line.should be_expecting_line_unadorned__
        end

        it "usage" do
          second_line.should be_stack_sensitive_usage_line
        end

        it "invite" do
          last_line.should be_invite_with_argument_focus
        end
      end
    end
  end
end
