module Skylab::Issue
  class Api::MyEvent < ::Skylab::PubSub::Event
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
    attr_accessor :minsky_frame
    # silly fun
    def noun
      @minsky_frame.class.inflected_noun
    end
    def verb
      @minsky_frame.class.verb_stem
    end
  end
end

