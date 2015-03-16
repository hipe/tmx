module Skylab::GitViz

  module VCS_Adapters_::Git  # read [#011] the git VCS adapter narrative

    class Front

      def initialize context_mod, oes_p, & extra_p
        @context_mod = context_mod
        @on_event_selectively = oes_p
        yield self
        freeze
      end

      def set_system_conduit x
        @system_conduit = x ; nil
      end

      def procure_repo_from_pathname pn
        @context_mod::Repo_.build_repo pn, @on_event_selectively do | repo |
          repo.system_conduit = @system_conduit
        end
      end

      def ping
        @on_event_selectively.call :payload, :expression, :ping do | y |
          y << "hello from front."
        end
        :hello_from_front
      end
    end

    DESIST_ = false

    Git = self

    GIT_EXE_ = 'git'.freeze

    IMPLEMENTATION_DIR_ = '.git'.freeze

  end
end
