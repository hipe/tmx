module Skylab::Face

  module API::Action::Service

    # `self.[]` - enhance the API::Action class with this facet.
    # fulfill [#fa-026]. assumes it is behind a module mutex.

    def self.[] target_mod, x_a
      Services::Headless::Plugin.enhance target_mod do
        services_used( * x_a )
      end
      target_mod.send :include, API::Action::Service::Instance_Methods_
        # (we used to `prepend` the above)
      nil
    end
  end

  module API::Action::Service

    module Instance_Methods_

      def has_service_facet  # fulfill [#fa-027]
        true
      end

      def absorb_any_services_from_parameters_notify param_h  # #hacks-only
      end

      def resolve_services metasvcs_x  # a point on the api action lifecycle
        # [#fa-018], raise on failure, undefined on success
        receive_plugin_attachment_notification metasvcs_x
        nil
      end

      def absorb_services *a  # a lower-level alternative to the above
        bx = plugin_metaservices.services_used
        while a.length.nonzero?
          i = a.shift ; x = a.fetch 0 ; a.shift
          svc = bx.fetch i
          :ivar == svc.into_i or fail "sanity - service is not ivar-based."
          instance_variable_set svc.into_ivar, x
        end
        nil
      end
    end
  end
end
