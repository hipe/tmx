module Skylab::Issue


  module Core::SubClient
    # empty
  end



  module Core::SubClient::InstanceMethods

    # (no public methods declared here)

  protected

    def _sub_client_init! request_client
      @error_count ||= 0
      @request_client = request_client
      nil
    end

    def emit type, msg
      request_client.send :emit, type, msg
      nil
    end

    def error msg
      @error_count += 1
      emit :error, msg
      false
    end

    attr_reader :error_count

    def escape_path x
      request_client.send :escape_path, x
    end

    def info msg
      emit :info, msg
      nil
    end

    def invite api_action
      request_client.send :invite, api_action
    end

    attr_reader :request_client

    def _sub_client_clear!                     # expert mode - prolly only use
      @error_count = 0                         # in flyweighting
    end
  end
end
