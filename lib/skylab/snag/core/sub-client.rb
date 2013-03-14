module Skylab::Snag

  module Core::SubClient
  end

  module Core::SubClient::InstanceMethods
    include Headless::SubClient::InstanceMethods # #floodgates

                                  # (no public methods declared here)
  protected

    def _snag_sub_client_init request_client
      init_headless_sub_client request_client
    end

    def api_invoke norm_name, param_h, *a, &b
      request_client.send :api_invoke, norm_name, param_h, *a, &b
    end

    alias_method :val, :kbd
      # (maybe one day synchronized swimming will be in the olympics) [#hl-051]
  end
end
