module Skylab::GitViz

  module VCS_Adapters_::Git  # read [#011] the git VCS adapter narrative

    class Front

      def initialize context_mod, listener
        @context_mod = context_mod
        @listener = listener
      end

      def procure_repo_from_pathname pn
        @context_mod::Repo_[ pn, @listener ]
      end

      def ping
        @listener.call :ping do :hello_from_front end ; nil
      end
    end

    DESIST_ = false

    Git = self

    GIT_EXE_ = 'git'.freeze

    IMPLEMENTATION_DIR_ = '.git'.freeze

    PROCEDE_ = true

    MetaHell::MAARS::Upwards[ self ]

    stowaway :Repo_, 'repo-/core'
  end
end
