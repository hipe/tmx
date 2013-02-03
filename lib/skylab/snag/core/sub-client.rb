module Skylab::Snag
  module Core::SubClient
  end

  module Core::SubClient::InstanceMethods
    include Headless::SubClient::InstanceMethods # #floodgates

                                  # (no public methods declared here)
  protected

    def _snag_sub_client_init request_client
      _headless_sub_client_init request_client
    end

    def api_invoke norm_name, param_h=nil, wiring=nil
      request_client.send :api_invoke, norm_name, param_h, wiring
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

    def wire_action x
      request_client.send :wire_action, x
    end

    def wire_action_for_error x
      request_client.send :wire_action_for_error, x
    end

    def wire_action_for_info x
      request_client.send :wire_action_for_error, x
    end
  end
end
