module Skylab::PubSub

  module API
    extend MAARS
  end

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
