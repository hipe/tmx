module Skylab::Face

  module API::Action::Service

  end

  class API::Action::Service::Flusher

    # assumes it is behind a module mutex.

    def initialize target, i_a
      @flush = -> do
        Services::Headless::Plugin.enhance target do
          services( *i_a )
        end

        target.send :prepend, API::Action::Service::Prepended_Methods_

          # for fun what we are doing is allowing ourselves to call `super`
          # to get up to the host class..

        nil
      end
    end

    def flush
      @flush.call
    end
  end

  module API::Action::Service::Prepended_Methods_

    def init api_client
      init_as_plugin api_client
      super  # important!
    end
    private :init

    def init_as_plugin api_client
      # allow this to be overridden for shenanigans
      load_plugin self.class.plugin_story, api_client.plugin_services
    end
    private :init_as_plugin
  end
end
