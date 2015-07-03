require_relative '../../../test-support'

module Skylab::Git::TestSupport

  describe "[gi] models - stow - actions - pop" do

    extend TS_
    use :models_stow_support

    it "move the stashed files back, prunes empty dir in stow tree" do

      td = __prepared_tmpdir

      path = td.path

      _stows_dir = ::File.join path, 'stows'
      _working_directory = ::File.join path, 'working-dir'

      call_API( :stow, :pop,
        :stow_name, 'dingle',
        :directory, _working_directory,
        :stows_path, _stows_dir,
        :system_conduit, Home_.lib_.open_3,
        :filesystem, Home_.lib_.system.filesystem,  # needs full monty
      )

      __expect_this path

      expect_neutral_event :mkdir
      expect_neutral_event :file_utils_mv_event
      expect_neutral_event :mkdir
      expect_neutral_event :mkdir
      expect_neutral_event :file_utils_mv_event
      expect_neutral_event :file_utils_mv_event
      expect_no_more_events
    end

    def __expect_this td_path

      _exp_s = <<-HERE.unindent
        ./stows
        ./stows/beta
        ./stows/beta/whatever.txt
        ./stows/dingle
        ./stows/dingle/four-dir-never-see
        ./stows/dingle/four-dir-never-see/fifth-dir-empty
        ./working-dir
        ./working-dir/one-dir
        ./working-dir/one-dir/one-file.txt
        ./working-dir/two-dir
        ./working-dir/two-dir/three-dir
        ./working-dir/two-dir/three-dir/three-file.txt
        ./working-dir/two-file.txt
      HERE

      _act_s = `cd #{ td_path } ; find . -mindepth 1`

      _act_s.should eql _exp_s
    end

    def __prepared_tmpdir

      td = memoized_tmpdir_
      td.prepare
      td.touch_r %w(
        stows/dingle/one-dir/one-file.txt
        stows/dingle/two-dir/three-dir/three-file.txt
        stows/dingle/four-dir-never-see/fifth-dir-empty/
        stows/dingle/two-file.txt
        stows/beta/whatever.txt
        working-dir/ )
      td
    end
  end
end
