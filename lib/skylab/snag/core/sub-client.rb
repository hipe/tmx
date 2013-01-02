module Skylab::Snag


  module Core::SubClient
    # empty
  end



  module Core::SubClient::InstanceMethods
    include Headless::SubClient::InstanceMethods # #floodgates

    # (no public methods declared here)

  protected

    def _snag_sub_client_init! request_client
      _headless_sub_client_init! request_client
    end

    def invite api_action
      request_client.send :invite, api_action
    end
  end
end
