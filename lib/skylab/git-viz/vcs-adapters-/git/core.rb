module Skylab::GitViz

  module VCS_Adapters_::Git  # read [#011] the git VCS adapter narrative

    class << self

      def repository
        Git_::Models_::Repository
      end
    end  # >>

    class Front

      class << self

        def new_via_system_conduit sc, & oes_p
          new sc, & oes_p
        end

        private :new
      end  # >>

      def initialize sc, & oes_p
        @on_event_selectively = oes_p
        @system_conduit = sc
      end

      def new_repository_via_pathname pn

        models::Repository.new_via_pathname(
          pn, @system_conduit, & @on_event_selectively )
      end

      def models
        Git_::Models_
      end

      def ping
        @on_event_selectively.call :payload, :expression, :ping do | y |
          y << "hello from front."
        end
        :hello_from_front
      end
    end

    Autoloader_[ Actors_ = ::Module.new ]

    Autoloader_[ Models_ = ::Module.new ]

    DESIST_ = false

    Git_ = self

    GIT_EXE_ = 'git'.freeze

    GIT_GENERAL_ERROR_ = 128

    VENDOR_DIR_ = '.git'.freeze

  end
end
