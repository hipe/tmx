require_relative '../test-support'

module Skylab::TaskExamples::TestSupport

  describe "[te] task-types - executable" do

    TS_[ self ]
    use :task_types

    def subject_class_
      Task_types_[]::Executable
    end

    context "requires some things" do

      it "and raises hell when it doesn't have them" do

        expect_missing_required_attributes_are_ :executable
      end

      def executable
        NIL_
      end
    end

    context "when checking an executable not in path (NASTY)" do

      shared_state_

      it "fails" do
        fails_
      end

      it "expresses" do
        _rx = /not in PATH: not-an-executable/
        expect_only_ :styled, :info, _rx
      end

      def executable
        'not-an-executable'
      end
    end

    context "when checking an executable in the path (FRAGILE)" do

      shared_state_

      it "succeeds" do
        succeeds_
      end

      it "expresses" do

        _rx = /\bruby$/
        expect_only_ :info, _rx
      end

      def executable
        'ruby'
      end
    end

    def build_arguments_
      { executable: executable }
    end

    def context_
      NIL_
    end
  end
end
