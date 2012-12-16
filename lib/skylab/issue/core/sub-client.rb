module Skylab::Issue


  module Core::SubClient
    # empty
  end



  module Core::SubClient::InstanceMethods
    include Headless::SubClient::InstanceMethods # #floodgates

    # (no public methods declared here)

  protected

    def _issue_sub_client_init! request_client
      _headless_sub_client_init! request_client
    end

    def escape_path x
      request_client.send :escape_path, x
    end

    def invite api_action
      request_client.send :invite, api_action
    end

    def _sub_client_clear!                     # expert mode - prolly only use
      @error_count = 0                         # in flyweighting
    end
  end
end
