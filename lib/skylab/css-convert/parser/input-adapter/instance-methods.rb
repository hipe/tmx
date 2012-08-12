module Skylab::CssConvert
  module Parser::InputAdapter::InstanceMethods
    include My::Headless::SubClient::InstanceMethods
    def initialize request_runtime, upstream, opts=nil, &block
      self.block = block
      self.request_runtime = request_runtime
      self.state = :initial
      self.upstream = upstream
      opts and opts.each { |k, v| send("#{k}=", v) }
    end
    attr_accessor :block
    attr_accessor :state
    attr_accessor :upstream
  end
end
