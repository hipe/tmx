module Skylab::TanMan

  module Core::Client
  end



  module Core::Client::ModuleMethods
    include PubSub::Emitter::ModuleMethods # necessary when e.g. CLI defines
  end                             # more granulated events



  module Core::Client::InstanceMethods

    include Headless::Client::InstanceMethods # floodgates

    include Core::SubClient::InstanceMethods   # ask for trouble by name

    extend PubSub::Emitter        # we want the instance methods this creates

    emits payload: :all, info: :all, error: :all # the PIE convention [#hl-037]
                                  # note that clients will add their own events

  private

    def services
      TanMan::Services.services   # this line should be duplicated only once,
    end                           # in tests.
  end
end
