module Skylab::CovTree

  module API::Events  # #stowaway - avoiding #orphan

    extend MetaHell::Boxxy  # events box modules are almost always boxified

    Structural = PubSub::Event::Factory::Structural.new 5  # `structural`

    module Datapoint  # `datapoint` - just pass data objects through
      def self.event _, __, x
        x
      end
    end
  end

  class API::Action

    extend CovTree::Core::Action

    ACTIONS_ANCHOR_MODULE = CovTree::API::Actions

    extend PubSub::Emitter

    event_factory PubSub::Event::Factory::Isomorphic.new( API::Events )

  protected

    def error msg
      @last_error_message = msg
      emit :error, msg
      false
    end
  end
end
