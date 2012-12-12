module Skylab::TanMan

  class Core::Event < PubSub::Event
    # this is all very experimental and subject to change!

    def message= msg
      update_attributes! message: msg
    end
  end
end
