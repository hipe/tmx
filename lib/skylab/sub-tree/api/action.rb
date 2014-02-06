module Skylab::SubTree

  module API::Events  # #stowaway - avoiding #orphan

    MetaHell::Boxxy[ self ]  # events box modules are almost always boxified

    Structural = Callback::Event::Factory::Structural.new 5  # `structural`

    module Datapoint  # `datapoint` - just pass data objects through
      def self.event _, __, x
        x
      end
    end
  end

  class API::Action

    SubTree::Core::Action::Anchored_Normal_Name_[ self ]

    ACTIONS_ANCHOR_MODULE = SubTree::API::Actions

    Callback[ self, :employ_DSL_for_digraph_emitter ]

    event_factory Callback::Event::Factory::Isomorphic.new( API::Events )

    def initialize
      @error_was_emitted = false
      nil
    end

  private

    def error message_x
      @error_was_emitted ||= true
      call_digraph_listeners :error, message_x
      false
    end
  end
end
