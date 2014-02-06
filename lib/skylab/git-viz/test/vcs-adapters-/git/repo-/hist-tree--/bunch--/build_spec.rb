require_relative 'test-support'

module Skylab::GitViz::TestSupport::VCS_Adapters_::Git::Repo_::Hist_Tree__

  describe "[gv] vcs adapters git repo hist-tree bunch build" do

    extend TS__ ; use :expect ; use :mock_FS ; use :mock_system

    context "for no-ent path under repo" do

      it "repo builds with this no-ent path" do
        repo
      end

      it "but if you try to get the hist tree node array - x" do
        @result = repo.build_hist_tree_bunch
        expect_next_system_command_emission
        expect_no_such_file_or_directory_from_system_agent(
          '/derp/berp/wazoozle/canoodle' )
        expect_failed
      end

      def mock_repo_argument_pathname
        mock_pathname '/derp/berp/wazoozle/canoodle'
      end

      def expect_no_such_file_or_directory_from_system_agent s
        expect %i( cannot_execute_command string ),
          "No such file or directory - #{ s }"
      end
    end

    context "for path that is file under repo" do

      it "it complains about how the path is a file - x" do
        @result = repo.build_hist_tree_bunch
        expect_next_system_command_emission
        expect_path_is_file_emission
        expect_failed
      end

      def mock_repo_argument_pathname
        mock_pathname '/derp/berp/dirzo/move-after'
      end

      def expect_path_is_file_emission
        expect %i( cannot_execute_command string ), TS_::Messages::PATH_IS_FILE
      end
    end

    context "but if that path is a directory under the repo" do

      it "oh nelly furtado watch out" do
        @bunch = repo.build_hist_tree_bunch
        expect_this_many_system_commands 8
        expect_this_many_statements_about_omissions 2
        expect_constituency
      end

      def mock_repo_argument_pathname
        mock_pathname '/derp/berp/dirzo'
      end

      _NEXT_SYSTEM_COMMAND = %i( next_system command ).freeze

      define_method :expect_this_many_system_commands do |d|
        expect_this_many_of_this d, _NEXT_SYSTEM_COMMAND
      end

      _STATEMENTS_OF_OMISSION =
        %i( info string omitting_informational_commitpoint ).freeze

      define_method :expect_this_many_statements_about_omissions do |d|
        expect_this_many_of_this d, _STATEMENTS_OF_OMISSION
      end

      def expect_this_many_of_this d, a
        d.times do
          expect a
        end
      end

      def expect_constituency
        @trail_a = @bunch.get_trail_scanner.to_a
        @trail_a.length.should eql 3
        @trail = @trail_a.shift
        expect_trail
      end
      def expect_trail
        @filediff_a = @trail.get_filediff_scanner.to_a
        @filediff = @filediff_a.shift
        expect_filediff
      end
      def expect_filediff
        @filediff.counts.num_insertions.should eql 3
        @filediff.counts.num_deletions.should eql 2
        @filediff.commitpoint_index.should eql 2
      end
    end

    def fixtures_module
      my_fixtures_module
    end
  end
end
