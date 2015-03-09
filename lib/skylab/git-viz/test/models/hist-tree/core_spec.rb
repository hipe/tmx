require_relative '../test-support'

module Skylab::GitViz::TestSupport::Models

  describe "[gv] models - hist-tree", wip: true do

    extend TS_
    use :mock_FS
    use :mock_system
    use :mock_1

    it "absolute path no ent (mocked) - x" do
      _call_API_against_path '/this-path-is-not-even-mocked/zang'
      _expect_no_repo
    end

    def expect_no_repo
      self._FUN
      expect %i( repo_root_not_found error string ), %r(\ADidn't find \.git #{
        }in this or any parent directory \(looked in 3 dirs\): #{
         }/[-a-z/]+/zang\z)
      expect_failed
    end

    it "abspath no ent, but inside a repo (mocked) - x" do
      _call_API_against_path '/derp/berp/nazoozle/fazoozle'
      _expect_no_ent
    end

    def _call_API_against_path path

      call_API( * _common_x_a,
        :system_conduit, :_s_c_,
        :path, path )
    end

    def _expect_no_ent
      self._REDO
      expect %i( next_system command )
      expect %i( cannot_execute_command string ), %r(\ANo such file #{
        }or directory - /[-a-z/]+/nazoozle/fazoozle\z)
      expect_failed
    end

    it "path is file (mocked) - x" do
      _call_API_against_path '/derp/berp/dirzo/move-after'
      __expect_path_is_file
    end

    def __expect_path_is_file
      self._REDO
      __expect_command_with_chdir_matching %r(/move-after\z)
      expect %i( cannot_execute_command string),
        /\Apath is file, must have directory\z/
    end

    it "path is valid (mock) - o" do
      __using_mock_sys_conduit_call_API_against_path '/derp/berp/dirzo'
      __expect_bunch
    end

    def __expect_bunch
      expect_informational_emissions_for_mock_1
      __expect_result_structure
    end

    def __expect_result_structure
      @result.has_slug.should be_nil
      @result.children_count.should eql 3
      one, two, three = @result.children.to_a
      one.slug.should eql "everybody in the room is floating"
      two.slug.should eql "it's just"
      three.slug.should eql "move-after"
    end

    def __using_mock_sys_conduit_call_API_against_path path

      call_API(
        * _common_x_a,
        :path, path,
        :system_conduit, mock_system_conduit,
        :filesysetm, mock_filesystem )
    end

    def _common_x_a
      self._CLEANUP
      [ :hist_tree,
        :VCS_adapters_module, GitViz_::VCS_Adapters_,
        :VCS_adapter_name, :git,
        :VCS_listener, @listener ]
    end

    def __expect_command_with_chdir_matching rx
      expect %i( next_system command ) do |em|
        em.payload_x.any_nonzero_length_option_h.fetch( :chdir ).
          should match rx
      end
    end

    def fixtures_module  # hook-in to mock system, mock FS
      GitViz_::TestSupport::VCS_Adapters::Git::Fixtures
    end
  end
end
