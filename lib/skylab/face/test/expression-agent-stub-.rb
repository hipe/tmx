module Skylab::Face

  module TestSupport

    class Expression_Agent_Stub_

      def lbl x
        "<<#{ x }>>"
      end

      def ick x
        "__#{ x }__"
      end

      def or_ a
        a * ' or '
      end
    end

    EXPRESSION_AGENT_STUB_ = Expression_Agent_Stub_.new

  end
end
