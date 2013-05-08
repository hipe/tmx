module Skylab::PubSub

  module API
    extend MAARS
  end

  API::FUN = -> do

    o = { }

    o[:looks_like_emitter_module] = -> x do
      x.singleton_class.method_defined? :emits or
        x.singleton_class.private_method_defined? :emits
    end

    ::Struct.new( * o.keys ).new( * o.values )

  end.call

  class API::Formal_Parameter

    attr_reader :ivar

    attr_reader :label

    attr_reader :sym

  protected

    def initialize name
      @sym = name
      @ivar = :"@#{ name }"
      @label = name.to_s
    end
  end
end
