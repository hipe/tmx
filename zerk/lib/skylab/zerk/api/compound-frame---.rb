module Skylab::Zerk

  module API

    class Compound_Frame___

      # enhance what the sub-client performer normally uses as a stack frame:
      # a qualified knownness.

      def initialize qk

        @qualified_knownness = qk

        @_has_last_written = false
      end

      # -- write

      def accept_new_component_value__ kn, asc

        _p = ACS_::Interpretation::Accept_component_change[
          kn.value_x,
          asc,
          @qualified_knownness.value_x,
        ]

        @_has_last_written = true
        @_last_written_kn = kn
        @_last_written_asc = asc

        _p
      end

      # -- read

      def to_node_stream_
        st = ACS_::Reflection::To_node_stream[ @qualified_knownness.value_x ]
        x = __mask__
        if x
          self._ETC
        end
        st
      end

      def qualified_knownness_as_invocation_result__

        # (implement the relevant half of the graph of [#012]/figure-2)

        if @_has_last_written
          Callback_::Qualified_Knownness.via_value_and_association(
            @_last_written_kn.value_x,  # ..
            @_last_written_asc )
        else
          @qualified_knownness
        end
      end

      def qualified_knownness_for_assoc__ asc

        # NOTE custodianship of this assoc to our compound component is not validated

        @___qkn_p ||= ___build_qkn_p
        @___qkn_p[ asc ]
      end

      def component_association_via_token x
        @___asc_p ||= ___build_asc_p
        @___asc_p.call x do
          NIL_
        end
      end

      def ___build_qkn_p

        ACS_::Reflection_::Component_qualified_knownness_reader.call(  # #violation
          @qualified_knownness.value_x,
        )
      end

      def ___build_asc_p
        ACS_::Component_association_reader[ @qualified_knownness.value_x ]
      end

      def __mask__
        NOTHING_  # #during [#013]
      end

      # -- for sub-clients

      # ~ look like a kn

      def value_x
        @qualified_knownness.value_x
      end

      def name  # [ac] for contextualized normalization failure expression
        @qualified_knownness.name
      end
    end
  end
end
