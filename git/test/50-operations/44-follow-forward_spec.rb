require_relative '../test-support'

module Skylab::Git::TestSupport

  describe "[gi] operations - follow forward" do

    TS_[ self ]
    use :memoizer_methods
    use :one_off_as_operation

    it "loads" do
      subject_one_off_CLI_
    end

    context "help screen" do

      given do
        argv '-h'
      end

      it "succeeds" do
        succeeds
      end

      it "content is probably fine" do
        a = lines
        a.first.string == "usage: gizzy [-v] <path>\n" || fail
        a.last.string.include? "some debugging info" or fail
      end
    end

    context "money" do

      given do
        argv 'fileA-2'
      end

      it "succeeds" do
        succeeds
      end

      it "looks right (2 lines)" do
        expect_part_ "renamed to fileA-3"
        expect_part_ "renamed to fileA-4"
        expect_no_more_output_lines_
      end

      def the_system_conduit_
        TS_::Fixture_Modules::Mock_Processes_01::Build[]
      end
    end

    shared_subject :subject_one_off_CLI_ do
      require_oneoff_as_operation_ 'tmx-git-follow-forward'
    end
  end
end
