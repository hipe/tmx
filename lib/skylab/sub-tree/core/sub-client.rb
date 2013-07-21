module Skylab::SubTree


  module Core::SubClient
    # nothing
  end



  module Core::SubClient::InstanceMethods
    include Headless::SubClient::InstanceMethods # #floodgates

    def pre x
      request_client.pre x
    end
  end
end
