module Skylab::Snag

  Core::SubClient = ::Module.new

  module Core::SubClient::InstanceMethods

    include Snag_::Lib_::Sub_client[]::InstanceMethods  # #floodgates

                                  # (no public methods declared here)
    def expression_agent
      request_client.expression_agent
    end

  private

    def call_API norm_name, param_h, *a, &b
      request_client.call_API norm_name, param_h, *a, &b
    end
    protected :call_API  # #protected-not-private

    alias_method :val, :kbd
      # (maybe one day synchronized swimming will be in the olympics) [#hl-051]
  end
end
