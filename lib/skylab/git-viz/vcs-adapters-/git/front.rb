module Skylab::GitViz

  module VCS_Adapters_::Git  # read [#011] the git VCS adapter narrative

    class Front

      def initialize context_mod, listener, & extra_p
        @context_mod = context_mod
        @listener = listener
        yield self
        freeze
      end

      def set_system_conduit x
        @system_conduit = x ; nil
      end

      def procure_repo_from_pathname pn
        @context_mod::Repo_.build_repo pn, @listener do |repo|
          repo.system_conduit = @system_conduit
        end
      end

      def ping
        @listener.maybe_receive_event :ping, :hello_from_front
        nil
      end
    end

    DESIST_ = false

    Git = self

    GIT_EXE_ = 'git'.freeze

    IMPLEMENTATION_DIR_ = '.git'.freeze

  end
end
