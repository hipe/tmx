require_relative '../../test-support'

module Skylab::Git::TestSupport

  describe "[gi] operations - stow - save" do

    TS_[ self ]
    use :stow

    context "(one)" do

      it "move the untracked files to a stash dir" do

        path = _save_via_3 'foo', '.', 'calc'

        want_neutral_event :command
        want_neutral_event :mkdir
        want_neutral_event :mkdir
        want_neutral_event_ :file_utils_mv_event
        want_neutral_event_ :file_utils_mv_event
        want_neutral_event_ :file_utils_mv_event

        st = dirs_in_ path
        st.gets.should eql './calc'
        st.gets.should eql './calc/.git'
        st.gets.should eql './calc/dippy'
        st.gets.should eql './Stoz'
        st.gets.should eql './Stoz/foo'
        st.gets.should eql './Stoz/foo/dippy'
        st.gets.should be_nil

        st = files_in_ path
        st.gets.should eql './calc/some-versioned-file.txt'
        st.gets.should eql './Stoz/foo/dippy/doopy.txt'
        st.gets.should eql './Stoz/foo/dippy/floopy.txt'
        st.gets.should eql './Stoz/foo/lippy.txt'
        st.gets.should be_nil
      end

      def _my_mock_system_conduit directory

        mock_system_conduit_where_(

          directory,
          git_ls_files_others_,

        ) do | i, o, e |

          o << "lippy.txt\n"
          o << "dippy/doopy.txt\n"
          o << "dippy/floopy.txt\n"
          0
        end
      end
    end

    context "(two)" do

      it "from the not-root of a project, make it all work" do

        path = _save_via_3 'bar', 'dippy', 'calc'

        want_neutral_event :command
        want_neutral_event :mkdir  # make the "bar" stow directory
        want_neutral_event :mkdir  # make the "dippy" diretory under that
        want_neutral_event_ :file_utils_mv_event  # move the one file

        st = dirs_in_ ::File.join( path, 'calc' )

        st.gets.should eql "./.git"
        st.gets.should eql "./dippy"
        st.gets.should be_nil

        st = files_in_ path
        st.gets.should eql "./calc/lippy.txt"
        st.gets.should eql "./calc/some-versioned-file.txt"
        st.gets.should eql "./Stoz/bar/dippy/doopy.txt"
        st.gets.should eql "./Stoz/bar/dippy/floopy.txt"
        st.gets.should be_nil
      end

      def _my_mock_system_conduit directory

        mock_system_conduit_where_(

          directory,
          git_ls_files_others_,

        ) do | i, o, e |

          o << "doopy.txt\n"
          o << "floopy.txt\n"
          0
        end
      end
    end

    def _save_via_3 stow_name, curr_relpath, proj_relpath

      td = _my_prepare

      path = td.to_path

      proj_path = ::File.join path, proj_relpath
      _stows_path = ::File.join path, 'Stoz'

      _chdir = if DOT_ == curr_relpath
        proj_path
      else
        ::File.join proj_path, curr_relpath
      end

      @SYSTEM_CONDUIT = _my_mock_system_conduit _chdir

      call_API( :stow, :save,
        :stow_name, stow_name,
        :current_relpath, curr_relpath,
        :project_path, proj_path,
        :stows_path, _stows_path,
      )

      path
    end

    def _my_prepare

      td = memoized_tmpdir_
      td.prepare

      td.mkdir 'Stoz'
      td.touch_r %w(
        calc/.git/
        calc/lippy.txt
        calc/dippy/doopy.txt
        calc/dippy/floopy.txt
        calc/some-versioned-file.txt
      )
      td
    end

    def prepare_subject_API_invocation invo
      sy = remove_instance_variable :@SYSTEM_CONDUIT
      invo.invocation_resources.send :define_singleton_method, :system_conduit do
        sy
      end
      invo
    end
  end
end
