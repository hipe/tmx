require_relative '../../../test-support'

module Skylab::Git::TestSupport

  describe "[gi] models - stow - actions - pop" do

    extend TS_
    use :models_stow_support

    context "(one)" do

      it "bad stow name" do

        _stoz = Fixture_tree_[ :stashiz ]

        _against 'n.s', 'n.s', 'stow-wadoodle', _stoz

        _ev = expect_not_OK_event :entity_not_found

        black_and_white( _ev ).should match(
          /\Astows collection at «[^»]+» does not have stow "stow-wadoodle"\z/ )

        expect_failed
      end
    end

    context "(two)" do

      it "move the stashed files back, prunes empty dir in stow tree" do

        _path = _pop_into_working_dir_Y_stow_X '.', 'project', 'dingle'

        __expect_these_paths _path
        __expect_these_events
      end

      def __expect_these_paths td_path

        st = dirs_in_ ::File.join td_path, 'stoz'

        st.gets.should eql './beta'
        st.gets.should be_nil

        st = files_in_ td_path
        st.gets.should eql './project/one-dir/one-file.txt'
        st.gets.should eql './project/two-dir/three-dir/three-file.txt'
        st.gets.should eql './project/two-file.txt'
        st.gets.should eql './stoz/beta/whatever.txt'
        st.gets.should be_nil
      end

      def __expect_these_events

        expect_neutral_event :mkdir
        expect_neutral_event :mkdir
        expect_neutral_event :mkdir
        expect_neutral_event :file_utils_mv_event
        expect_neutral_event :file_utils_mv_event
        expect_neutral_event :file_utils_mv_event
        expect_no_more_events
      end

      def _prepared_tmpdir

        td = memoized_tmpdir_
        td.prepare
        td.touch_r %w(
          stoz/dingle/one-dir/one-file.txt
          stoz/dingle/two-dir/three-dir/three-file.txt
          stoz/dingle/two-file.txt
          stoz/beta/whatever.txt
          project/.git/
        )
        td
      end
    end

    context "(three)" do

      it "from a sub-reddit, looks upward to use your project dir" do

        path = _pop_into_working_dir_Y_stow_X 'dir-2', 'proj-1', 'sto-1'

        expect_neutral_event :mkdir
        expect_neutral_event :file_utils_mv_event
        expect_succeeded

        st = dirs_in_ path
        st_ = files_in_ path
        st.gets.should eql './proj-1'
        st.gets.should eql './proj-1/.git'
        st.gets.should eql './proj-1/dir-1'
        st.gets.should eql './proj-1/dir-2'
        st.gets.should eql './stoz'
        st.gets.should be_nil

        st = st_
        st.gets.should eql './proj-1/dir-1/file-1.txt'
        st.gets.should be_nil
      end

      def _prepared_tmpdir

        td = memoized_tmpdir_
        td.prepare
        td.touch_r %w(
          stoz/sto-1/dir-1/file-1.txt
          proj-1/.git/
          proj-1/dir-2/
        )
        td
      end
    end

    def _pop_into_working_dir_Y_stow_X curr_relpath, proj_relpath, stow

      td = _prepared_tmpdir

      path = td.path

      _stows_dir = ::File.join path, 'stoz'
      _proj_path = ::File.join path, proj_relpath

      _against curr_relpath, _proj_path, stow, _stows_dir

      path
    end

    def _against curr_relpath, proj_path, stow_name, stows_dir

      call_API( :stow, :pop,
        :stow_name, stow_name,
        :current_relpath, curr_relpath,
        :project_path, proj_path,
        :stows_path, stows_dir,
        :system_conduit, real_system_conduit_,
        :filesystem, real_filesystem_,  # needs full monty
      )
      NIL_
    end
  end
end