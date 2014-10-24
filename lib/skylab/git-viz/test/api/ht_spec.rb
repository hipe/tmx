require_relative 'test-support'

module Skylab::GitViz::TestSupport::API

  describe "[gv] API - hist-tree" do

    extend TS__ ; use :expect ; use :mock_FS ; use :mock_system ; use :mock_1

    it "absolute path no ent (mocked) - x" do
      _pn = mock_pathname '/this-path-is-not-even-mocked/zang'
      invoke_API_on_pathname _pn
      expect_no_repo
    end

    def expect_no_repo
      expect %i( repo_root_not_found error string ), %r(\ADidn't find \.git #{
        }in this or any parent directory \(looked in 3 dirs\): #{
         }/[-a-z/]+/zang\z)
      expect_failed
    end

    it "abspath no ent, but inside a repo (mocked) - x" do
      _pn = mock_pathname '/derp/berp/nazoozle/fazoozle'
      invoke_API_on_pathname _pn
      expect_no_ent
    end

    def expect_no_ent
      expect %i( next_system command )
      expect %i( cannot_execute_command string ), %r(\ANo such file #{
        }or directory - /[-a-z/]+/nazoozle/fazoozle\z)
      expect_failed
    end

    it "path is file (mocked) - x" do
      _pn = mock_pathname '/derp/berp/dirzo/move-after'
      invoke_API_on_pathname _pn
      expect_path_is_file
    end

    def expect_path_is_file
      expect_command_with_chdir_matching %r(/move-after\z)
      expect %i( cannot_execute_command string),
        /\Apath is file, must have directory\z/
    end

    it "path is valid (mock) - o" do
      _pn = mock_pathname '/derp/berp/dirzo'
      invoke_API_on_pathname_with_mock_sys_cond _pn
      expect_bunch
    end

    def expect_bunch
      expect_informational_emissions_for_mock_1
      expect_result_structure
    end

    def expect_result_structure
      @result.has_slug.should be_nil
      @result.children_count.should eql 3
      one, two, three = @result.children.to_a
      one.slug.should eql "everybody in the room is floating"
      two.slug.should eql "it's just"
      three.slug.should eql "move-after"
    end

    def invoke_API_on_pathname pn
      invoke_API( * common_x_a, :system_conduit, :_s_c_, :pathname, pn )
    end

    def invoke_API_on_pathname_with_mock_sys_cond pn
      invoke_API( * common_x_a,
        :system_conduit, mock_system_conduit, :pathname, pn )
    end

    def common_x_a
      listener
      [ :hist_tree, :VCS_adapters_module,  GitViz::VCS_Adapters_,
         :VCS_adapter_name, :git, :VCS_listener, @listener ]
    end

    def expect_command_with_chdir_matching rx
      expect %i( next_system command ) do |em|
        em.payload_x.any_nonzero_length_option_h.fetch( :chdir ).
          should match rx
      end
    end

    def fixtures_module
      GitViz::TestSupport::VCS_Adapters::Git::Fixtures
    end
  end
end
