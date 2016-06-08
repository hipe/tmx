module Skylab::Callback

  module API
    Looks_like_digraph_module_ = -> x do
      x.singleton_class.method_defined? :listeners_digraph or
        x.singleton_class.private_method_defined? :listeners_digraph
    end
  end

  class API::Formal_Parameter

    attr_reader :ivar

    attr_reader :label

    attr_reader :sym

  private

    def initialize name
      @sym = name
      @ivar = :"@#{ name }"
      @label = name.to_s
    end
  end
end
