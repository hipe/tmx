module Skylab::GitViz

  module VCS_Adapters_::Git

    class Repo_::Hist_Tree__

      class Bunch__::Begin__

        Callback_::Actor.call self, :properties, :bunch

        def execute
          @st = self.class::Get_ls_files_scanner__[ @bunch, & @on_event_selectively ]
          @st && __via_upstream_lines_etc
        end

        def __via_upstream_lines_etc

          line = @st.gets or self._SANITY
          trail_a = nil

          begin
            trail = @bunch.begin_trail line, & @on_event_selectively
            if trail
              trail_a ||= []
              trail_a.push trail
            end
            line = @st.gets
            line ? redo : break
          end while nil

          trail_a
        end
      end

      class Bunch__::Begin__

        class Get_ls_files_scanner__ < Git::System_Agent_

          class << self
            def [] bunch, & oes_p
              new( bunch, & oes_p ).execute
            end
          end  # >>

          def initialize bunch, & oes_p
            repo = bunch.repo
            super oes_p do | sa |
              sa.set_cmd_s_a [ GIT_EXE_, 'ls-files', '--', '.' ]
              sa.set_chdir_pathname repo.get_focus_dir_absolute_pn
              sa.set_system_conduit repo.system_conduit
            end
          end

          def execute
            get_any_nonzero_count_output_line_stream_from_cmd
          end
        end
      end
    end
  end
end
