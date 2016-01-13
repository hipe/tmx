require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] non-interactive CLI - 01. no ACS" do

    TS_[ self ]
    use :memoizer_methods
    use :non_interactive_CLI

    context "you can build a CLI from no ACS.." do

      shared_subject :subject_CLI do

        cli = Home_::NonInteractiveCLI.begin
        cli.root_ACS = -> & _oes_p do
          NIL_
        end
        cli.to_classesque
      end

      context "invoke against nothing" do

        given do
          argv
        end

        it "expecting" do
          _ = expectation :styled, :e, 'expecting <action>'
          first_line.should match_ _
        end

        it "usage" do
          _ = expectation :styled, :e, "usage: 'xyzi <action> [..]'"
          second_line.should match_ _
        end

        it "invite" do
          _ = expectation :styled, :e, "use 'xyzi -h' to see available arguments"
          third_and_final_line.should match_ _
        end

        it "exitstatus" do
          expect_result_for_failure
        end
      end
    end
  end
end
