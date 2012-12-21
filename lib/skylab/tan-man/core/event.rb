module Skylab::TanMan

  class Core::Event < PubSub::Event
    # this is all very experimental and subject to change!

    attr_accessor :inflected_with_action_name

    attr_accessor :inflected_with_failure_reason


    def message= msg
      update_attributes! message: msg
    end
  end
end
