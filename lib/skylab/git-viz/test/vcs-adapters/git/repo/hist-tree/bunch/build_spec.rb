require_relative 'test-support'

module Skylab::GitViz::TestSupport::VCS_Adapters::Git::Repo::Hist_Tree

  describe "[gv] VCS adapters - git - repo - hist-tree - bunch - build" do

    extend TS_
    use :expect_event
    use :mock_FS
    use :mock_system
    use :mock_1

    context "for no-ent path under repo" do

      it "repo builds with this no-ent path" do
        repo
      end

      it "but if you try to get the hist tree node array - x" do

        @result = repo.build_hist_tree_bunch
        expect_next_system_command_emission_
        __expect_no_such_file_or_directory_from_system_agent(
          '/derp/berp/wazoozle/canoodle' )
        expect_failed
      end

      def mock_repo_argument_pathname  # local #hook-out
        mock_pathname '/derp/berp/wazoozle/canoodle'
      end

      def __expect_no_such_file_or_directory_from_system_agent s

        expect_not_OK_event :cannot_execute_command do | ev |
          black_and_white( ev ).should eql "No such file or directory - #{ s }"
        end
      end
    end

    context "for path that is file under repo" do

      it "it complains about how the path is a file - x" do
        @result = repo.build_hist_tree_bunch
        expect_next_system_command_emission_
        expect_path_is_file_emission
        expect_failed
      end

      def mock_repo_argument_pathname  # local #hook-out
        mock_pathname '/derp/berp/dirzo/move-after'
      end

      def expect_path_is_file_emission

        expect_not_OK_event :cannot_execute_command do | ev |
          black_and_white( ev ).should eql Top_TS_::Messages::PATH_IS_FILE
        end
      end
    end

    context "but if that path is a directory under the repo" do

      it "oh nelly furtado watch out" do
        @bunch = repo.build_hist_tree_bunch
        expect_informational_emissions_for_mock_1
        __expect_constituency
      end

      def mock_repo_argument_pathname  # local #hook-out
        mock_pathname '/derp/berp/dirzo'
      end

      def __expect_constituency
        @trail_a = @bunch.immutable_trail_array
        @trail_a.length.should eql 3
        @trail = @trail_a.fetch 0
        __expect_trail
      end

      def __expect_trail
        @filediff_a = @trail.get_filediff_stream.to_a
        @filediff = @filediff_a.shift
        __expect_filediff
      end

      def __expect_filediff
        @filediff.counts.num_insertions.should eql 3
        @filediff.counts.num_deletions.should eql 2
        @filediff.commitpoint_index.should eql 2
      end
    end

    def fixtures_module  # #hook-out
      my_fixtures_module
    end
  end
end
