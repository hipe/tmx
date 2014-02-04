module Skylab::Callback

  module Event::Factory::Datapoint

    def self.event _, __, x       # as a resolved factory
      x                           # just emit x as the event
    end

    class << self
      alias_method :call, :event  # as an unresolved factory, same
    end
  end
end
