module Skylab::GitViz

  module VCS_Adapters_::Git  # read [#011] the git VCS adapter narrative

    class << self

      def repository
        Git_::Models_::Repository
      end
    end  # >>

    class Front

      class << self

        def via_system_conduit sc, & p
          new sc, & p
        end

        private :new
      end  # >>

      def initialize sc, & p
        @listener = p
        @system_conduit = sc
      end

      def new_repository_via path, system, filesystem

        models::Repository.new_via(
          path,
          system,
          filesystem,
          & @listener )
      end

      def models
        Git_::Models_
      end

      def ping

        @listener.call :payload, :expression, :ping do | y |
          y << "hello from front."
        end

        :hello_from_front
      end
    end

    DESIST_ = false

    Git_ = self

    GIT_EXE_ = 'git'.freeze

    GIT_GENERAL_ERROR_ = 128

    VENDOR_DIR_ = '.git'.freeze

  end
end
