module Skylab::Treemap
  class API::Event < PubSub::Event

  protected

    def initialize tag, *payload
      if payload.size == 2 and ::Hash === payload.last
        h = payload.pop
        h[:message] = payload.first
        super tag, h
      else
        super tag, *payload
      end
    end
  end
end
