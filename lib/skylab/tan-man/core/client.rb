module Skylab::TanMan

  module Core::Client
  end



  module Core::Client::ModuleMethods
    include PubSub::Emitter::ModuleMethods # necessary when e.g. CLI defines
  end                             # more granulated events



  module Core::Client::InstanceMethods

    include Core::SubClient::InstanceMethods   # ask for trouble by name

    extend PubSub::Emitter        # we want the instance methods this creates

    emits payload: :all, info: :all, error: :all
                                  # #todo eventually make this PIE [#037]
                                  # note that clients will add their own events

  protected

    def config_singleton          # [#021]
      singletons.config
    end

    def service
      TanMan::Services.service
    end

    def singletons                # [#021]
      API.singletons
    end
  end
end
