module Skylab::GitViz

  module VCS_Adapters_::Git

    class Models_::Bundle

      class << self

        def build_via_path_and_repo path, repo, & oes_p

          Actors_::Build[ path, repo, & ( oes_p || repo.handle_event_selectively ) ]
        end

        def log_command_

          LOG_CMD___
        end

        def ls_files_command_

          LS_FILES_CMD___
        end
      end  # >>

      def initialize list_of_trails, ci_box
        @ci_box = ci_box
        @trails = list_of_trails
      end

      attr_reader :ci_box, :trails

      def build_matrix_via_repository repo
        Actors_::Build_matrix.new( self, repo ).execute
      end

      Autoloader_[ Actors_ = ::Module.new ]

      Bundle_ = self

      GIT_EXE = GIT_EXE_

      LOG_BASE_CMD_ = %w( log --find-renames --follow --pretty=format:%H -- ).freeze

      LOG_CMD___ = [ GIT_EXE_, * LOG_BASE_CMD_ ].freeze

      LS_FILES_BASE_CMD_ = %w( ls-files -- . ).freeze

      LS_FILES_CMD___ = [ GIT_EXE_, * LS_FILES_BASE_CMD_ ].freeze

    end
  end
end
