module Skylab::CovTree


  module Core::SubClient
    # nothing
  end



  module Core::SubClient::InstanceMethods

    def escape_path x
      request_client.escape_path x
    end

    def pre x
      request_client.pre x
    end
  end
end
