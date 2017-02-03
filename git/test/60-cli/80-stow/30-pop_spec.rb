require_relative '../../test-support'

module Skylab::Git::TestSupport

  describe "[gi] mode integrations - CLI - models - stow - pop" do

    TS_[ self ]
    use :CLI

    # expect ERR_I, /\A\(while listing stash.+no stashes found in /

    it "try to pop from within unversioned directory (SEE HERE ON FAILURE)" do

      # NOTE this tests relies on there appearing to be a filesystem with
      # an *existent* directory from which between it and the filesystem
      # root (it included) there is never a `.git` directory found.
      #
      # if we were after rotund robustness we would mock the filesystem but
      # we are not yet. in lieu of this:
      #
      # currently,  we *assume* that whatever the topmost tmpdir is that
      # is handed to us by the host system (via the host platform), that
      # that directory will NOT itself "look" versioned, NOR exist under
      # any versioned directory (all the way up to the root of the
      # filesystem).
      #
      # although this assumption may fly in some environment by (almost)
      # pure happenstance, it is by no means guaranteed to be a valid
      # assumption on all systems.

      _path = real_filesystem_.tmpdir_path

      cd_ _path do
        invoke 'stow', 'pop', 'no-see-stow'
      end

      expect :e, /\Afailed because "\.git" not found in \. or \d+ dirs up\z/

      _expect_common_invite_line
      expect_no_more_lines
      @exitstatus.zero? and fail  # `resource_not_found` (11)
    end

    it "for a project SUB-dir, pop a strange stow" do

      _path = ::File.join Fixture_tree_[ :filesystem_1 ], 'proggie'

      cd_ _path do

        invoke 'stow', 'pop', 'wazoozle'
      end

      expect :e, %r(\Acouldn't pop stow because #{
        }there is no stow "wazoozle" in stows collection \.\./Stows\z)

      _expect_common_failure
    end

    it "succeed in poppping a stow (verbose when option)" do

      tmpdir_path = __setup

      _path = ::File.join tmpdir_path, 'projo'

      cd_ _path do
        invoke 'stow', 'pop', 'stow-1'
      end

      expect :e, %r(\Amkdir [^ ]+/zerf\b)
      expect :e, "mv ../Stows/stow-1/zerf/ziff.txt ./zerf/ziff.txt"
      expect_succeed

      st = files_in_ tmpdir_path
      st.gets.should eql './projo/zerf/ziff.txt'
      st.gets.should be_nil
    end

    def __setup

      td = memoized_tmpdir_
      td.prepare

      td.touch_r %w(
        Stows/stow-1/zerf/ziff.txt
        projo/.git/
        projo/wonger/donger/
      )

      td.path
    end

    def _expect_common_failure
      _expect_common_invite_line
      expect_fail
    end

    def _expect_common_invite_line
      expect_specific_invite_line_to :stow, :pop
    end
  end
end
