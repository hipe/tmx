module Skylab::Face

  module API::Action::Service

  end

  class API::Action::Service::Flusher

    # assumes it is behind a module mutex.

    def initialize target, x_a
      @flush = -> do
        Services::Headless::Plugin.enhance target do
          services( * x_a )
        end
        target.send :include, API::Action::Service::InstanceMethods
          # (we used to `prepend` the above)
        nil
      end
    end

    def flush
      @flush.call
    end
  end

  module API::Action::Service::InstanceMethods

    # `resolve_services` - a point on the api action lifecycle [#fa-api-003]
    # raise on failure, undefined on success  #watch:chain
    # this is where #ingestion is implemented.

    def resolve_services svcs
      pstory = self.class.plugin_story
      load_plugin pstory, svcs
      ev = nil
      pstory.services.each do |nn, svc|  # validate and ingest in one pass!
        if svcs.has_service? nn
          if svc.do_ingest
            x = svcs.call_host_service pstory, nn
            ivar = svc.ingest_to_ivar
            if instance_variable_defined? ivar
              fail "sanity - won't clobber existing ivar - #{ ivar }"
            else
              instance_variable_set ivar, x
            end
          end
        else
          ev ||= Services::Headless::Plugin::Service::NameEvent.new
          ev.add svcs.host_descriptor, self, nn
        end
      end
      if ev
        raise Services::Headless::Plugin::Service::NameError,
          instance_exec( & ev.message_function )
      end
      nil
    end
  end
end
