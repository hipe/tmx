module Skylab::Face

  module API::Action::Service

    # `self.[]` - enhance the API::Action class with this facet.
    # fulfill [#fa-026]. assumes it is behind a module mutex.

    def self.[] target_mod, x_a
      Services::Headless::Plugin.enhance target_mod do
        services( * x_a )
       end
      target_mod.send :include, API::Action::Service::InstanceMethods
        # (we used to `prepend` the above)
      nil
    end
  end

  module API::Action::Service::InstanceMethods

    def has_service_facet
      true
    end
    # public. fulfill [#fa-027]

    # `resolve_services` - a point on the api action lifecycle [#fa-018]
    # raise on failure, undefined on success  #watch:chain
    # this is where #ingestion is implemented.

    def resolve_services svcs
      load_plugin svcs
      ev = nil
      @plugin_story.services.each do |nn, svc|  # validate and ingest in one pass!
        if svcs.provides_service? nn
          if svc.do_ingest
            ivar = svc.ivar_to_ingest_as
            if instance_variable_defined? ivar
              fail "sanity - won't clobber existing ivar - #{ ivar }"
            else
              instance_variable_set ivar,
                svcs.call_host_service( @plugin_story, nn )
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
