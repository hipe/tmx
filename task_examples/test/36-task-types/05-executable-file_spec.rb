require_relative '../test-support'

module Skylab::TaskExamples::TestSupport

  describe "[te] task-types - executable file" do

    TS_[ self ]
    use :memoizer_methods
    use :want_event
    use :task_types

    def subject_class_

      Task_types_[]::ExecutableFile
    end

    context "essential" do

      it "loads" do
        subject_class_
      end
    end

    context "when pointing to an executable file (NASTY)" do

      shared_state_

      it "succeeds" do
        succeeds_
      end

      it "expresses" do

        _rx = /\Aok, executable - .*\/ruby/
        info_expression_message_.should match  _rx
      end

      def _executable_file
        `which ruby`.strip
      end
    end

    context "when pointing to a file not found" do

      shared_state_

      it "fails" do
        fails_
      end

      it "expresses" do

        _rx = /\ANo such file or directory - \(pth /

        error_expression_message_.should match  _rx
      end

      def _executable_file
        ::File.join BUILD_DIR, 'not-a-file'
      end
    end

    context "when pointing to a found, not executable file" do

      shared_state_

      it "fails" do
        fails_
      end

      it "expresses" do

        _rx = /\Aexists but is not executable - \(pth [^ ]+some-file/
        error_expression_message_.should match  _rx
      end

      def _executable_file
        ::File.join FIXTURES_DIR, 'some-file.txt'
      end
    end

    def build_arguments_
      [
        :executable_file, _executable_file,
        :filesystem, real_filesystem_,
      ]
    end

    def context_
      NOTHING_
    end
  end
end
