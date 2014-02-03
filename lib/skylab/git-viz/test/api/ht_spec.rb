require_relative 'test-support'

module Skylab::GitViz::TestSupport::API

  describe "[gv] API - hist-tree" do

    extend TS__ ; use :expect

    it "path not found - x" do
      _pn = GitViz.dir_pathname.join 'zang'
      invoke_API_on_pathname _pn
      expect_command_with_chdir_matching %r(/zang\z) if false
      expect %i( cannot_execute_command string),
        %r(\ANo such file or directory - /.+/zang\z)
      expect_failed
    end

    it "path is file - x" do
      _pn = GitViz.dir_pathname.join 'core.rb'
      invoke_API_on_pathname _pn
      expect_command_with_chdir_matching %r(/core\.rb) if false
      expect %i( cannot_execute_command string), TS_::Messages::PATH_IS_FILE
    end

    it "path is valid (mock) - o" do
      _pn = GitViz.dir_pathname.join 'anything-else'
      invoke_API_on_pathname _pn
      expect_no_more_emissions
      @result.has_slug.should be_nil
      @result.children_count.should eql 2
      one, two = @result.children.to_a
      one.slug.should eql "it's just"
      two.slug.should eql "everybody in the room is floating"
    end

    def invoke_API_on_pathname pn
      invoke_API( * common_x_a, :pathname, pn )
    end

    def common_x_a
      listener
      [ :hist_tree, :VCS_adapter_name, :git, :VCS_listener, @listener ]
    end

    def expect_command_with_chdir_matching rx
      expect %i( next_system command ) do |em|
        em.payload_x.any_nonzero_length_option_h.fetch( :chdir ).
          should match rx
      end
    end
  end
end
