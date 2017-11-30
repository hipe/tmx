require_relative '../../../test-support'

module Skylab::GitViz::TestSupport

  describe "[gv] VCS adapters - git - models - repository" do

    TS_[ self ]
    use :VCS_adapters_git_repository

    it "builds" do
      front_
    end

    it "pings" do

      x = front_.ping

      want_neutral_event :ping, "hello from front."

      expect( x ).to eql :hello_from_front

      want_no_more_events
    end

    it "just go ahead and TRY to give this low-level nerk a relpath" do

      __want_relative_paths_are_not_honored_here do

        init_respository_via_path_ 'anything'
      end
    end

    def __want_relative_paths_are_not_honored_here
      begin
        yield
      rescue Home_::ArgumentError => e
      end
      expect( e.message ).to eql "relative paths are not honored here - anything"
    end

    it "resolve when provide a path that totally doesn't exist - x" do

      init_respository_via_path_ '/totally/doesn-t-exist'

      _ev = start_directory_noent_

      __want_totally_doesnt_exist _ev
    end

    def __want_totally_doesnt_exist ev

      ev.exception or fail
      ev.prop or fail
      expect( ev.start_path ).to eql '/totally/doesn-t-exist'
    end

    it "give it a FILE in a dir that is a repo - WORKS" do

      init_respository_via_path_ '/m02/repo/core.py'

      want_no_more_events

      expect( @repository ).to be_respond_to :fetch_commit_via_identifier
    end

    def manifest_path_for_stubbed_FS
      at_ :STORY_02_PATHS_
    end

    undef_method :stubbed_system_conduit

    def stubbed_system_conduit
      :_none_used_here_
    end
  end
end
