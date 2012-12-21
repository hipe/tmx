module Skylab::Issue
  class API::MyEvent < PubSub::Event
    def message= msg # parent class doens't provide this
      if payload.kind_of?(Hash)
        payload.key?(:message) or _define_attr_accessors!(:message)
        payload[:message] = msg
      else
        self.payload = msg
      end
    end
    # with out this it derps over by doing payload.to_s
    def to_s # it derps over on payload.to_s without this
      message # ich muss sein
    end
    # silly fun
    attr_accessor :inflection
    def noun
      inflection.inflected.noun
    end
    def verb
      inflection.stems.verb
    end
  end
end
