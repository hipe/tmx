module Skylab::PubSub::TestSupport

  class Fixtures::ZigZag

    extend PubSub::Emitter
    emits hacking: [ :business, :pleasure ]

    public :emit, :with_specificity

  end
end
