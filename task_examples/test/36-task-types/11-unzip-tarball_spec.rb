require_relative '../test-support'

module Skylab::TaskExamples::TestSupport

  describe "[te] task-types unzip tarball" do

    TS_[ self ]
    use :memoizer_methods
    use :want_event
    use :task_types

    def subject_class_
      Task_types_[]::UnzipTarball
    end

    context "with missing requireds" do

      shared_state_

      it "(loads)" do
        subject_class_
      end

      it "whines about missing required fields" do

        want_missing_required_attributes_are_ :build_dir, :filesystem, :unzip_tarball
      end

      def build_arguments_
        EMPTY_A_
      end
    end

    context "with required parameters" do

      def build_arguments_
        [
          :build_dir, _build_dir,
          :filesystem, real_filesystem_,
          :unzip_tarball, _unzip_tarball,
        ]
      end

      context "when tarball does not exist" do

        shared_state_

        def _build_dir
          :_something_trueish_
        end

        def _unzip_tarball
          __tarball_that_does_not_exist
        end

        it "fails" do
          fails_
        end

        it "whines (returns false, emits error)" do

          _be_this = match %r(\bNo such file or directory - \(pth .+not-there\b)

          error_expression_message_.should _be_this
        end
      end

      context "tarball exists and target directory exists (i.e skip)" do

        shared_state_

        def _build_dir
          td = empty_tmpdir_
          td.mkdir "mginy"
          td
        end

        def _unzip_tarball
          _tarball_that_is_proper
        end

        it "succeeds" do
          succeeds_
        end

        it "expresses" do

          _be_this = match %r(\bexists, won't tar extract: .*mginy\b)

          info_expression_message_.should _be_this
        end
      end

      context "tarball path exists and it's not a tarball" do

        shared_state_

        def _build_dir
          the_empty_directory_
        end

        def _unzip_tarball
          __tarball_that_is_not_a_tarball
        end

        it "fails" do
          fails_
        end

        it "expresses" do

          _be_msg = match %r(\bfailed to unzip.*unrecognized archive format)i

          _be_this = be_emission :error, :expression do |y|
            y.fetch( 0 ).should _be_msg
          end
        end
      end

      context "when it is a tarball and the target directory does not exist" do

        shared_state_

        def _build_dir
          empty_tmpdir_
        end

        def _unzip_tarball
          _tarball_that_is_proper
        end

        it "succeeds" do
          succeeds_
        end

        it "expresses shell" do

          _be_this_message = match %r(\bcd [^ ]+\\\[te\\\]; tar -xzvf /.+/mginy\b)

          _be_this = be_emission :info, :expression, :system_command do |y|
            y.fetch( 0 ).should _be_this_message
          end

          first_emission.should _be_this
        end

        it "errput lists etc" do

          expag = common_expression_agent_for_want_emission_

          s_a = []
          emission_array[ 1 .. -1 ].each do |em|
            expag.calculate s_a, & em.expression_proc
          end

          s_a.fetch( 0 ).should eql "x mginy/"
          s_a.fetch( 1 ).should eql "\nx mginy/README\n"  # weird chunking
          2 == s_a.length or fail
        end
      end
    end

    def __tarball_that_is_not_a_tarball
      ::File.join FIXTURES_DIR, 'not-a-tarball.tar.gz'
    end

    def __tarball_that_does_not_exist
      ::File.join FIXTURES_DIR, 'not-there.tar.gz'
    end

    def _tarball_that_is_proper
      ::File.join FIXTURES_DIR, 'mginy-0.0.1.tar.gz'
    end
  end
end
