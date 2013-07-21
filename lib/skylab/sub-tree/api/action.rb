module Skylab::SubTree

  module API::Events  # #stowaway - avoiding #orphan

    MetaHell::Boxxy[ self ]  # events box modules are almost always boxified

    Structural = PubSub::Event::Factory::Structural.new 5  # `structural`

    module Datapoint  # `datapoint` - just pass data objects through
      def self.event _, __, x
        x
      end
    end
  end

  class API::Action

    extend SubTree::Core::Action

    ACTIONS_ANCHOR_MODULE = SubTree::API::Actions

    extend PubSub::Emitter

    event_factory PubSub::Event::Factory::Isomorphic.new( API::Events )

  private

    def error msg
      @last_error_message = msg
      emit :error, msg
      false
    end
  end
end
