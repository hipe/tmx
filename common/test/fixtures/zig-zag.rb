module Skylab::Callback::TestSupport

  class Fixtures::ZigZag

    Home_[ self, :employ_DSL_for_digraph_emitter ]

    listeners_digraph hacking: [ :business, :pleasure ]

    public :call_digraph_listeners, :with_specificity

    def build_digraph_event * x_a, channel_i, esg
      Mock_Old_Event___.new x_a
    end

    class Mock_Old_Event___

      def initialize _x_a
        @_argies_ = _x_a
      end

      def is_event
        true
      end
    end
  end
end
