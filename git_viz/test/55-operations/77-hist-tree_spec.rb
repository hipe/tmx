require_relative '../../test-support'

module Skylab::GitViz::TestSupport

  describe "[gv] models - hist-tree" do

    TS_[ self ]
    use :models_support_hist_tree_model_support

    it "absolute path no ent (mocked) - x" do

      _call_API_against_path '/this-path-is-not-even-mocked/zang'
      start_directory_noent_
    end

    it "abspath no ent, but inside a repo (mocked) - x" do

      _call_API_against_path '/m03/repo/nazoozle/fazoozle'
      start_directory_noent_
    end

    it "path is file (mocked) - x" do

      _call_API_against_path "/m03/repo/dirzo/it's just/funky like that"
      expect_failed_by :wrong_ftype
    end

    it "path is valid (mock) - o" do

      call_API_for_hist_tree_against_path_ '/m03/repo/dirzo'
      __expect_bundle
    end

    def __expect_bundle

      _mbndl = @result

      _mbndl.bundle.trails.length.should eql 3
      # see tombstone below
    end

    def _call_API_against_path path

      call_API( * hist_tree_head_iambic_,
        :path, path,
        :system_conduit, :_s_c_,
        :filesystem, stubbed_filesystem,
      )
    end

    def manifest_path_for_stubbed_FS
      at_ :GIT_STORY_03_PATHS_
    end

    def manifest_path_for_stubbed_system
      at_ :GIT_STORY_03_COMMANDS_
    end
  end
end
# :+#tombstone: testing the tree model
