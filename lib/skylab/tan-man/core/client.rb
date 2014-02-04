module Skylab::TanMan

  module Core::Client
  end



  module Core::Client::ModuleMethods

    Callback[ self, :include_emitter_module_methods ]  # necessary when e.g. CLI defines
  end                             # more granulated events



  module Core::Client::InstanceMethods

    include Headless::Client::InstanceMethods # floodgates

    include Core::SubClient::InstanceMethods   # ask for trouble by name

    Callback[ self, :employ_DSL_for_emitter ]  # we want the i.m's from this

    emits payload: :all, info: :all, error: :all # the PIE convention [#hl-037]
                                  # note that clients will add their own events

  private

    def services
      TanMan::Services.services   # this line should be duplicated only once,
    end                           # in tests.
  end
end
