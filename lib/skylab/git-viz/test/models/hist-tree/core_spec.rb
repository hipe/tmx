require_relative '../test-support'

module Skylab::GitViz::TestSupport::Models

  describe "[gv] models - hist-tree" do

    extend TS_
    use :expect_event
    use :mock_FS
    use :mock_system

    it "absolute path no ent (mocked) - x" do

      _call_API_against_path '/this-path-is-not-even-mocked/zang'

      __expect_no_repo
    end

    def __expect_no_repo

      ev = expect_not_OK_event( :repo_root_not_found ).to_event

      ev.num_times_looked.should eql 3
      ev.path.should eql '/this-path-is-not-even-mocked/zang'

      expect_failed
    end

    it "abspath no ent, but inside a repo (mocked) - x" do

      _call_API_against_path '/m03/repo/nazoozle/fazoozle'

      expect_failed_by :errno_enoent
    end

    it "path is file (mocked) - x" do

      _call_API_against_path "/m03/repo/dirzo/it's just/funky like that"

      expect_failed_by :wrong_ftype
    end

    it "path is valid (mock) - o" do

      __using_mock_sys_conduit_call_API_against_path '/m03/repo/dirzo'
      __expect_bundle
    end

    def __using_mock_sys_conduit_call_API_against_path path

      call_API(
        * _common_x_a,
        :path, mock_pathname( path ),
        :system_conduit, mock_system_conduit )
    end

    define_method :_common_x_a, -> do
      a = [ :hist_tree, :VCS_adapter_name, :git ].freeze
      -> do
        a
      end
    end.call

    def __expect_bundle

      bndl = @result

      bndl.trails.length.should eql 3
      # see tombstone below
    end

    def _call_API_against_path path

      call_API( * _common_x_a,
        :system_conduit, :_s_c_,
        :path, mock_pathname( path ) )
    end

    def manifest_path_for_mock_FS
      GIT_STORY_03_PATHS_
    end

    def manifest_path_for_mock_system
      GIT_STORY_03_COMMANDS_
    end
  end
end
# :+#tombstone: testing the tree model
