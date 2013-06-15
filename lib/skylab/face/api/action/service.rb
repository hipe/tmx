module Skylab::Face

  module API::Action::Service

    # `self.[]` - enhance the API::Action class with this facet.
    # fulfill [#fa-026]. assumes it is behind a module mutex.

    def self.[] target_mod, x_a
      Services::Headless::Plugin.enhance target_mod do
        services_used( * x_a )
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
    # this is close to where #ingestion happens.

    def resolve_services metasvcs_x
      receive_plugin_attachment_notification metasvcs_x
      nil
    end
  end
end
