module Skylab::GitViz

  module VCS_Adapters_::Git

    class Repo_::Hist_Tree__

      class Bunch__::Trail__

        class Begin__ < Git::System_Agent_

          def initialize trail, & oes_p
            @file_relpath = trail.file_relpath
            @repo = trail.repo ; @trail = trail
            super oes_p do |sa|
              sa.set_chdir_pathname @repo.get_focus_dir_absolute_pn
              sa.set_cmd_s_a [ GIT_EXE_, * INNER_CMD_S_A__, trail.file_relpath ]
              sa.set_system_conduit @repo.system_conduit
            end
          end
          INNER_CMD_S_A__ = %w( log --follow --pretty=tformat:%H -- ).freeze
        public
          def execute
            @scn = get_any_nonzero_count_output_line_stream_from_cmd
            @scn and exec_with_nonzero_stream
          end
        private
          def exec_with_nonzero_stream
            sha_s = @scn.gets or fail "sanity - nonzero scanner?"
            begin
              sha = Repo_::SHA_.some_instance_from_string sha_s
              begin_and_add_filediff_with_SHA sha
              sha_s = @scn.gets
            end while sha_s
            @trail
          end
          def begin_and_add_filediff_with_SHA sha
            @repo.SHA_notify sha
            _filediff = @trail.build_filediff sha
            @trail.add_filediff _filediff ; nil
          end
        end
      end
    end
  end
end
