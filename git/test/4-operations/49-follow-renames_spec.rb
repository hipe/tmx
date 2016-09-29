require_relative '../test-support'

module Skylab::Git::TestSupport

  describe "[gi] operations - follow renames" do

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
        # (this happens to be identical to our sibling test but it need not stay that way)
        a.first.string == "usage: gizzy [-v] <path>\n" || fail
        a.last.string.include? "some debugging info" or fail
      end
    end

    context "money" do

      given do
        argv 'fileA-4'
      end

      it "succeeds" do
        succeeds
      end

      it "there are 3 renames, at the top" do

        _screen_index.line_indexes_of( :rename ) == [ 0, 1, 2 ] || fail
      end

      it "there is 1 create, as the last line" do

        _screen_index.line_indexes_of( :create ) == [ 3 ] || fail
      end

      it "for this respository, the items should occur in reverse chron order" do

        a = _screen_index.parsed_lines.dup

        a.sort_by! do |pl|
          pl.time
        end

        _act = a.map do |pl|
          pl.line_index
        end

        _act == [ 3, 2, 1, 0 ] || fail
      end

      shared_subject :_screen_index do
        build_screen_index__
      end

      def the_system_conduit_
        TS_::Fixture_Modules::Mock_Processes_02::Build[]
      end
    end

    shared_subject :subject_one_off_CLI_ do
      require_oneoff_as_operation_ 'tmx-git-follow-renames'
    end
  end
end
