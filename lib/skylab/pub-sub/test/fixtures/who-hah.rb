module Skylab::PubSub::TestSupport

  module Fixtures::WhoHah

    extend PubSub::Emitter
    emits hacking: [ :business, :pleasure ]

  end
end
