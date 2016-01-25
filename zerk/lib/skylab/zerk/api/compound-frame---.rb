module Skylab::Zerk

  module API

    class Compound_Frame___

      # enhance what the sub-client performer normally uses as a stack frame:
      # a qualified knownness.

      def initialize qk

        @qualified_knownness = qk
      end

      def to_node_stream_
        st = ACS_::Reflection::To_node_stream[ @qualified_knownness.value_x ]
        x = __mask__
        if x
          self._ETC
        end
        st
      end

      def __mask__
        NOTHING_  # #during [#013]
      end

      def read asc  # result is qk. custodianship of this assoc is not validated
        @___rd ||= ACS_::Reflection_::Reader[ @qualified_knownness.value_x ]
        @___rd [ asc ]
      end

      attr_reader(
        :qualified_knownness,
      )

      # -- for sub-clients

      # ~ look like a kn

      def value_x
        @qualified_knownness.value_x
      end
    end
  end
end
