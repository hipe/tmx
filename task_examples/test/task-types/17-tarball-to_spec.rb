require_relative '../test-support'

module Skylab::TaskExamples::TestSupport

  describe "[te] task-types - tarball to", wip: true do

    TS_[ self ]
    use :memoizer_methods
    use :task_types

    def subject_class_
      Task_types_[]::TarballTo
    end

    context "with bad build args" do

      it "throws an exception about what it needs" do

        _rx = /missing required attributes:? from, tarball_to/

        expect_strong_failure_with_message_ _rx
      end

      def build_arguments_
        NOTHING_
      end
    end

    context "with good build args (no interpolation)" do

      shared_state_

      it "succeeds" do
        succeeds_
      end

      it "expresses" do
        expect_only_ :shell, /curl -o.*tar\.gz.*tar\.gz/
      end

      def before_execution_

        run_file_server_if_not_running_
        prepare_build_directory_
        NIL_
      end

      def _tarball_to
        ::File.join BUILD_DIR, 'ohai'
      end

      _URL = 'http://localhost:1324/mginy-0.0.1.tar.gz'.freeze

      define_method :build_arguments_ do
        [
          :from, _URL,
          :tarball_to, _tarball_to,
        ]
      end
    end

    h = nil
    define_method :context_ do
      h ||= {
        build_dir: BUILD_DIR,
      }.freeze
    end
  end
end
