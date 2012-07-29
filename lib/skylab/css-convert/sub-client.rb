module Skylab::CssConvert
  module SubClient
  end

  module SubClient::InstanceMethods

    def emit *a
      request_runtime.output_adapter.emit(*a)
    end

    def error m
      emit :error, m
      false
    end

    def initialize request_runtime
      self.request_runtime = request_runtime
    end

    attr_accessor :request_runtime

    def params
      request_runtime.params
    end
  end
end
