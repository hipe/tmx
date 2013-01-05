module Skylab::TreetopTools
  module Parser::InputAdapter::InstanceMethods
    include ::Skylab::Headless::SubClient::InstanceMethods
    def initialize request_client, upstream, opts=nil, &block
      self.block = block
      self.request_client = request_client
      self.state = :initial
      self.upstream = upstream
      opts and opts.each { |k, v| send("#{k}=", v) }
    end
    attr_accessor :block
    def entity_noun_stem
      (@entity_noun_stem ||= nil) || default_entity_noun_stem
    end
    attr_writer :entity_noun_stem
    attr_accessor :state
    attr_accessor :upstream
  end
end
