module Skylab::TreetopTools

  module Parser::InputAdapter::InstanceMethods

    include LIB_.sub_client::InstanceMethods

    def initialize request_client, upstream, opts=nil, &block
      @block = block
      @request_client = request_client
      @state = :initial
      @upstream = upstream
      if opts
        opts.each_pair do |i, x|
          send :"#{ i }=", x
        end
      end
    end

    attr_accessor :block

    attr_reader :entity_noun_stem

    alias_method :entity_noun_stem_ivar, :entity_noun_stem

    def entity_noun_stem
      entity_noun_stem_ivar || default_entity_noun_stem
    end

    attr_writer :entity_noun_stem

    attr_accessor :state

    attr_accessor :upstream
  end
end
