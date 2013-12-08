module Skylab::Snag

  module Core::SubClient
  end

  module Core::SubClient::InstanceMethods
    include Headless::SubClient::InstanceMethods # #floodgates

                                  # (no public methods declared here)
  private

    def api_invoke norm_name, param_h, *a, &b
      request_client.send :api_invoke, norm_name, param_h, *a, &b
    end
    protected :api_invoke  # #protected-not-private

    alias_method :val, :kbd
      # (maybe one day synchronized swimming will be in the olympics) [#hl-051]
  end
end
