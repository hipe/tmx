require_relative '../test-support'

module Skylab::TaskExamples::TestSupport

  describe "[te] task-types - executable" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_event
    use :task_types

    def subject_class_
      Task_types_[]::Executable
    end

    context "essential" do

      it "loads" do
        subject_class_
      end
    end

    context "when checking an executable not in path (NASTY)" do

      shared_state_

      it "fails" do
        fails_
      end

      it "expresses" do
        _rx = /\Anot in PATH: not-an-executable\z/
        error_expression_message_.should match _rx
      end

      def _executable
        'not-an-executable'
      end
    end

    context "when checking an executable in the path (FRAGILE)" do

      shared_state_

      it "succeeds" do
        succeeds_
      end

      it "expresses" do

        _rx = /\bruby\z/
        info_expression_message_.should match _rx
      end

      def _executable
        'ruby'
      end
    end

    def build_arguments_
      [ :executable, _executable ]
    end
  end
end
