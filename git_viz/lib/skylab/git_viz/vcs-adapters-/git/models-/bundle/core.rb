module Skylab::GitViz

  module VCS_Adapters_::Git

    class Models_::Bundle

      class << self

        def build_bundle_via relpath, repo, rsx, filesystem, & p

          Here_::Magnetics_::Bundle_via_Path_and_Repository.call(
            relpath,
            repo,
            rsx,
            filesystem,
            & ( p || repo.handle_event_selectively )
          )
        end

        def log_command_
          LOG_CMD___
        end

        def ls_files_command_
          LS_FILES_CMD___
        end
      end  # >>

      def initialize stats, list_of_trails, ci_box, rsx
        @ci_box = ci_box
        @resources = rsx
        @statistics = stats
        @trails = list_of_trails
      end

      attr_reader :ci_box, :statistics, :trails

      def build_matrix_via_repository repo
        Magnetics_::Matrix_via_Bundle.new( self, repo, @resources ).execute
      end

      GIT_EXE = GIT_EXE_

      Here_ = self

      LOG_BASE_CMD_ = %w( log --find-renames --follow --pretty=format:%H -- ).freeze

      LOG_CMD___ = [ GIT_EXE_, * LOG_BASE_CMD_ ].freeze

      LS_FILES_BASE_CMD_ = %w( ls-files -- . ).freeze

      LS_FILES_CMD___ = [ GIT_EXE_, * LS_FILES_BASE_CMD_ ].freeze
    end
  end
end
