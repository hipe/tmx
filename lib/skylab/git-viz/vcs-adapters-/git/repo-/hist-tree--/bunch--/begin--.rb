module Skylab::GitViz

  module VCS_Adapters_::Git

    class Repo_::Hist_Tree__

      Bunch__::Begin__ = Simple_Agent_.new :bunch, :listener do

        def execute
          @scn = self.class::Get_ls_files_scanner__[ @bunch, @listener ]
          @scn && exec_with_each_file_line
        end

      private

        def exec_with_each_file_line
          trail_a = nil ; line = @scn.gets or self.sanity
          begin
            trail = @bunch.begin_trail line, @listener
            trail and (( trail_a ||= [] )) << trail
            line = @scn.gets
          end while line
          trail_a
        end
      end

      class Bunch__::Begin__

        class Get_ls_files_scanner__ < Git::System_Agent_

          def self.[] bunch, listener
            new( bunch, listener ).execute
          end

          def initialize bunch, listener
            repo = bunch.repo
            super listener do |sa|
              sa.set_cmd_s_a [ GIT_EXE_, 'ls-files', '--', '.' ]
              sa.set_chdir_pathname repo.get_focus_dir_absolute_pn
              sa.set_system_conduit repo.system_conduit
            end
          end
        public
          def execute
            get_any_nonzero_count_output_line_stream_from_cmd
          end
        end
      end
    end
  end
end
