require_relative '../test-support'

module Skylab::GitViz::TestSupport::Models

  describe "[gv] models - hist-tree", wip: true do

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
      _call_API_against_path '/derp/berp/nazoozle/fazoozle'
      _expect_no_ent
    end

    def _call_API_against_path path

      call_API( * _common_x_a,
        :system_conduit, :_s_c_,
        :path, mock_pathname( path ) )
    end

    def _expect_no_ent

      expect_event :next_system_command

      _ev = expect_not_OK_event( :cannot_execute_command ).to_event

      black_and_white( _ev ).should match %r(\ANo such file #{
        }or directory - /[-a-z/]+/nazoozle/fazoozle\z)

      expect_failed
    end

    it "path is file (mocked) - x" do
      _call_API_against_path '/derp/berp/dirzo/move-after'
      __expect_path_is_file
    end

    def __expect_path_is_file

      __expect_command_with_chdir_matching %r(/move-after\z)

      expect_not_OK_event :cannot_execute_command,
        'path is file, must have (or_ ["directory"])'

      expect_failed
    end

    it "path is valid (mock) - o" do
      __using_mock_sys_conduit_call_API_against_path '/derp/berp/dirzo'
      __expect_bunch
    end

    def __expect_bunch
      expect_informational_emissions_for_story_01
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
        :path, mock_pathname( path ),
        :system_conduit, mock_system_conduit )
    end

    define_method :_common_x_a, -> do
      a = [ :hist_tree, :VCS_adapter_name, :git ].freeze
      -> do
        a
      end
    end.call

    def __expect_command_with_chdir_matching rx

      _ev = expect_event( :next_system_command ).to_event
      _ev.any_nonzero_length_option_h.fetch( :chdir ).should match rx
      nil
    end
  end
end
