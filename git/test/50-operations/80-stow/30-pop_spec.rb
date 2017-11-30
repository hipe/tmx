require_relative '../../test-support'

module Skylab::Git::TestSupport

  describe "[gi] operations - stow - pop" do

    TS_[ self ]
    use :stow

    context "(one)" do

      it "bad stow name" do

        _stoz = Fixture_tree_[ :stashiz ]

        _against 'n.s', 'n.s', 'stow-wadoodle', _stoz

        _em = want_not_OK_event :component_not_found

        _em = black_and_white _em.cached_event_value

        expect( _em ).to match(
          /\Athere is no stow "stow-wadoodle" in stows collection «[^»]+»\z/ )

        want_fail
      end
    end

    context "(two)" do

      it "move the stashed files back, prunes empty dir in stow tree" do

        _path = _pop_into_working_dir_Y_stow_X '.', 'project', 'dingle'
        __want_these_paths _path
        __want_these_events
      end

      def __want_these_paths td_path

        _st = dirs_in_ ::File.join td_path, 'stoz'

        want_these_lines_in_array_ _st do |y|
          y << './beta'
        end

        _st = files_in_ td_path
        want_these_lines_in_array_ _st do |y|
          y << './project/one-dir/one-file.txt'
          y << './project/two-dir/three-dir/three-file.txt'
          y << './project/two-file.txt'
          y << './stoz/beta/whatever.txt'
        end
      end

      def __want_these_events

        want_neutral_event_ :mkdir
        want_neutral_event_ :mkdir
        want_neutral_event_ :mkdir
        want_neutral_event_ :file_utils_mv_event
        want_neutral_event_ :file_utils_mv_event
        want_neutral_event_ :file_utils_mv_event
        want_no_more_events
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

        want_neutral_event :mkdir
        want_neutral_event_ :file_utils_mv_event
        want_succeed

        _dirs_st = dirs_in_ path
        _files_st = files_in_ path

        want_these_lines_in_array_ _dirs_st do |y|
          y << './proj-1'
          y << './proj-1/.git'
          y << './proj-1/dir-1'
          y << './proj-1/dir-2'
          y << './stoz'
        end

        want_these_lines_in_array_ _files_st do |y|
          y << './proj-1/dir-1/file-1.txt'
        end
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
      )
      NIL_
    end
  end
end
