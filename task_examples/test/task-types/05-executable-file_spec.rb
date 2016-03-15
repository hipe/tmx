require_relative '../test-support'

module Skylab::TaskExamples::TestSupport

  describe "[te] task-types - executable file", wip: true do

    TS_[ self ]
    use :task_types

    def subject_class_

      Task_types_[]::ExecutableFile
    end

    context "with empty build args" do

      it "raises an exception complaining of missing required attributes" do

        expect_missing_required_attributes_are_ :executable_file
      end

      def build_arguments_
        EMPTY_H_
      end
    end

    context "when pointing to an executable file" do

      shared_state_

      it "succeeds" do
        succeeds_
      end

      it "expresses" do

        _rx = /executable: .*\/ruby/
        expect_only_ :info, _rx
      end

      def executable_file
        `which ruby`.strip
      end
    end

    context "when pointing to a file not found" do

      shared_state_

      it "fails" do
        fails_
      end

      it "expresses" do

        _rx = /executable does not exist.*not-a-file/
        expect_only_ :info, _rx
      end

      def executable_file
        ::File.join BUILD_DIR, 'not-a-file'
      end
    end

    context "when pointing to a found, not executable file" do

      shared_state_

      it "fails" do
        fails_
      end

      it "expresses" do

        _rx = /exists but is not executable.*some-file/
        expect_only_ :info, _rx
      end

      def executable_file
        ::File.join FIXTURES_DIR, 'some-file.txt'
      end
    end

    def build_arguments_
      {
        executable_file: executable_file,
      }
    end

    def context_
      NIL_
    end
  end
end
