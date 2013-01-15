module Skylab::Snag
  module Core::SubClient
  end

  module Core::SubClient::InstanceMethods
    include Headless::SubClient::InstanceMethods # #floodgates

                                  # (no public methods declared here)
  protected

    def _snag_sub_client_init! request_client
      _headless_sub_client_init! request_client
    end

    def ick x                     # how do you decorate an invalid value?
      request_client.send :ick, x
    end

    def invite api_action
      request_client.send :invite, api_action
    end

    def val x                     # typically emphasize a value
      request_client.send :val, x
    end
  end
end
