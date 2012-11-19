module Skylab::TanMan

  module Core::Client
  end


  module Core::Client::ModuleMethods
    include PubSub::Emitter::ModuleMethods # necessary when e.g. CLI defines
  end                             # more granulated events


  module Core::Client::InstanceMethods
    extend PubSub::Emitter        # we want the instance methods this creates

    emits :all, out: :all, info: :all
                                  # #todo eventually make this PIE [#037]
                                  # note that clients will add their own events
  end
end
