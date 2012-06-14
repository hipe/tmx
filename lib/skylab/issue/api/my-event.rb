module Skylab::Issue
  class Api::MyEvent < ::Skylab::PubSub::Event
    def message= msg
      self.payload = msg # for now ..
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

