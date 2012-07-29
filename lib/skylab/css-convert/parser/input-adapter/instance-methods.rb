module Skylab::CssConvert
  module Parser::InputAdapter::InstanceMethods
    include CssConvert::SubClient::InstanceMethods
    def initialize request_runtime, upstream, opts=nil
      self.request_runtime = request_runtime
      self.state = :initial
      self.upstream = upstream
      opts and opts.each { |k, v| send("#{k}=", v) }
    end
    attr_accessor :state
    attr_accessor :upstream
  end
end
