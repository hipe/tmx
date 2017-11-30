require_relative '../test-support'

module Skylab::TaskExamples::TestSupport

  describe "[te] task-types - tarball to" do

    # #significance: the first "real world" use of the "synthesis" dependency

    TS_[ self ]
    use :memoizer_methods
    use :want_event
    use :task_types

    def subject_class_
      Task_types_[]::TarballTo
    end

    context "essential" do

      shared_state_

      it "loads" do
        subject_class_
      end

      it "missung requireds" do
        want_missing_required_attributes_are_(
          :build_dir, :filesystem, :tarball_to, :url )
      end

      def build_arguments_
        EMPTY_A_
      end
    end

    context "with good build args" do

      shared_state_

      def build_arguments_

        # run_file_server_if_not_running_  # NOTE etc

        build_dir = BUILD_DIR
        _tarball_to = ::File.join build_dir, 'ohai'
        _URL = 'http://localhost:1324/mginy-0.0.1.tar.gz'

        [
          :build_dir, build_dir,
          :filesystem, real_filesystem_,
          :tarball_to, _tarball_to,
          :url, _URL,
        ]
      end

      it "succeeds" do
        succeeds_
      end

      it "moved file" do
        state_
        _hi = ::File.join BUILD_DIR, 'ohai'
        file_exists_ _hi or fail
      end

      it "expresses" do

        _be_msg = match %r(\Amv [^ ]+tar\.gz [^ ]+/ohai\z)

        _be_this = be_emission_ending_with :fake_shell do |y|
          expect( y.fetch 0 ).to _be_msg
        end

        expect( last_emission ).to _be_this
      end
    end
  end
end
